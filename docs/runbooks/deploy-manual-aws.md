# Runbook — deploy manual pelas pipelines na AWS

Passo a passo para outra pessoa renovar as credenciais do AWS Academy,
configurar os GitHub Secrets e executar o deploy atual da Fase 3 em
`us-east-1`.

> **Escopo desta versao:** este runbook descreve o estado atual da `main`, antes
> da separacao completa entre homologacao e producao. Hoje os tres backends
> Terraform apontam para o bucket `pytstop-terraform-state-924563550535`, na
> conta AWS `924563550535`. Se `aws sts get-caller-identity` mostrar outra conta,
> pare: o codigo precisa ser adaptado antes do deploy.

## 1. O que o operador precisa

- acesso de escrita aos quatro repositorios da organizacao
  `fiap-postech-sw-architecture`;
- acesso ao mesmo AWS Academy Learner Lab usado pelo projeto;
- AWS CLI, GitHub CLI (`gh`), `kubectl`, `jq` e `openssl`;
- sessao ativa do Learner Lab;
- para recriar tudo, os valores estaveis dos segredos ou autorizacao para gerar
  novos valores depois de destruir o ambiente anterior.

Autentique o GitHub CLI e valide a AWS:

```bash
gh auth status
aws configure set region us-east-1
aws sts get-caller-identity
```

O campo `Account` deve ser `924563550535`. Nunca copie credenciais para arquivos
do projeto, commits, logs, issues ou mensagens.

Confira tambem o backend remoto compartilhado:

```bash
aws s3api head-bucket --bucket pytstop-terraform-state-924563550535
```

Se o bucket ainda nao existir, mas a conta for exatamente a esperada, crie-o
uma unica vez antes das pipelines:

```bash
aws s3api create-bucket \
  --region us-east-1 \
  --bucket pytstop-terraform-state-924563550535
aws s3api put-public-access-block \
  --region us-east-1 \
  --bucket pytstop-terraform-state-924563550535 \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
aws s3api put-bucket-versioning \
  --region us-east-1 \
  --bucket pytstop-terraform-state-924563550535 \
  --versioning-configuration Status=Enabled
```

## 2. Escolher o tipo de operacao

### Ambiente existente: renovar apenas as credenciais AWS

Use este caminho para testar ou reaplicar o ambiente que ja esta criado. Os
GitHub Secrets estaveis permanecem salvos; outra pessoa nao precisa conhece-los
para disparar as pipelines.

Depois de renovar as credenciais, reexecute os CDs na ordem RDS → EKS →
aplicacao/NLB → Lambda/API Gateway. Como os states remotos sao preservados, o
Terraform reaplica apenas eventuais diferencas.

Nao gere novamente `APP_ENCRYPTION_KEY` enquanto preservar o RDS. Uma chave
diferente impede a aplicacao de consultar corretamente dados pessoais ja
criptografados. Alterar o JWT invalida tokens existentes, e alterar a senha do
banco exige atualizar o RDS e as duas URLs de conexao em conjunto.

### Ambiente limpo: gerar todos os segredos

Use este caminho somente depois de destruir integralmente os recursos anteriores
ou ao provisionar pela primeira vez na mesma conta. Guarde os valores gerados em
um gerenciador de senhas: o GitHub permite substituir um secret, mas nao ler seu
valor depois.

## 3. Renovar as credenciais temporarias AWS

Depois de **Start Lab**, copie o bloco AWS CLI para o perfil `default` em
`~/.aws/credentials`. Confirme novamente a identidade:

```bash
aws sts get-caller-identity
```

No clone de `postech-sw-arch-p3-docs`, distribua as credenciais aos quatro repos:

```bash
AWS_PROFILE=default AWS_REGION=us-east-1 bash scripts/refresh-aws-secrets.sh
```

O `AWS_PROFILE=default` e necessario porque a versao atual do script ainda usa
`academy` como valor padrao. Ele grava os tres secrets abaixo e tambem
`AWS_REGION=us-east-1` em cada repositorio. O secret de regiao e mantido pelo
script por compatibilidade, mas os workflows atuais ja fixam a regiao:

- `AWS_ACCESS_KEY_ID`;
- `AWS_SECRET_ACCESS_KEY`;
- `AWS_SESSION_TOKEN`.

Para conferir somente nomes e datas, sem revelar valores:

```bash
for repo in \
  postech-sw-arch-p3-infra-db \
  postech-sw-arch-p3-infra-k8s \
  postech-sw-arch-p3 \
  postech-sw-arch-p3-lambda
do
  gh secret list -R "fiap-postech-sw-architecture/$repo"
done
```

### Alternativa pela interface do GitHub

Em cada repositorio, abra **Settings → Secrets and variables → Actions →
Repository secrets**. Use **Update** para substituir os tres secrets AWS. Eles
expiram ao fim da sessao do Learner Lab e devem ser atualizados antes de cada
novo deploy.

## 4. Matriz completa de GitHub Secrets

| Repositorio | Secret | Origem | Rotacao |
|---|---|---|---|
| todos os quatro | `AWS_ACCESS_KEY_ID` | perfil AWS `default` | a cada Start Lab |
| todos os quatro | `AWS_SECRET_ACCESS_KEY` | perfil AWS `default` | a cada Start Lab |
| todos os quatro | `AWS_SESSION_TOKEN` | perfil AWS `default` | a cada Start Lab |
| `postech-sw-arch-p3-infra-db` | `TF_VAR_DB_PASSWORD` | senha PostgreSQL gerada | estavel |
| `postech-sw-arch-p3` | `APP_JWT_SECRET` | segredo JWT gerado | estavel |
| `postech-sw-arch-p3` | `APP_ENCRYPTION_KEY` | chave Fernet gerada | estavel |
| `postech-sw-arch-p3` | `APP_ADMIN_PASSWORD` | senha do admin gerada | estavel |
| `postech-sw-arch-p3` | `RDS_DATABASE_URL` | URL montada com endpoint e senha do RDS | estavel enquanto o RDS existir |
| `postech-sw-arch-p3` | `GHCR_PULL_TOKEN` | PAT classic com `read:packages` | conforme validade do PAT |
| `postech-sw-arch-p3-lambda` | `TF_VAR_JWT_SECRET` | mesmo valor de `APP_JWT_SECRET` | estavel |
| `postech-sw-arch-p3-lambda` | `TF_VAR_ENCRYPTION_KEY` | mesmo valor de `APP_ENCRYPTION_KEY` | estavel |
| `postech-sw-arch-p3-lambda` | `TF_VAR_DATABASE_URL` | mesmo valor de `RDS_DATABASE_URL` | estavel enquanto o RDS existir |
| `postech-sw-arch-p3-lambda` | `TF_VAR_APP_LISTENER_ARN` | listener TCP 8000 do NLB interno | muda ao recriar o NLB |

A regiao esta fixa em `us-east-1` nos workflows atuais; nao e necessario criar
um secret `AWS_REGION`.

Pela interface, todos os valores da tabela sao criados ou substituidos em
**Settings → Secrets and variables → Actions → Repository secrets**. Use
**New repository secret** para o primeiro cadastro e **Update** para rotacao.

## 5. Gerar e gravar segredos para um ambiente limpo

Execute em um terminal local. Os valores ficam apenas em variaveis da sessao e
nao sao impressos:

```bash
DB_PASSWORD="$(openssl rand -hex 24)"
JWT_SECRET="$(openssl rand -hex 32)"
ENCRYPTION_KEY="$(python3 -c 'import base64, os; print(base64.urlsafe_b64encode(os.urandom(32)).decode())')"
ADMIN_PASSWORD="$(openssl rand -hex 20)"
```

Grave os valores iniciais:

```bash
ORG="fiap-postech-sw-architecture"

printf '%s' "$DB_PASSWORD" | \
  gh secret set TF_VAR_DB_PASSWORD -R "$ORG/postech-sw-arch-p3-infra-db"

printf '%s' "$JWT_SECRET" | \
  gh secret set APP_JWT_SECRET -R "$ORG/postech-sw-arch-p3"
printf '%s' "$ENCRYPTION_KEY" | \
  gh secret set APP_ENCRYPTION_KEY -R "$ORG/postech-sw-arch-p3"
printf '%s' "$ADMIN_PASSWORD" | \
  gh secret set APP_ADMIN_PASSWORD -R "$ORG/postech-sw-arch-p3"

printf '%s' "$JWT_SECRET" | \
  gh secret set TF_VAR_JWT_SECRET -R "$ORG/postech-sw-arch-p3-lambda"
printf '%s' "$ENCRYPTION_KEY" | \
  gh secret set TF_VAR_ENCRYPTION_KEY -R "$ORG/postech-sw-arch-p3-lambda"
```

Crie um **personal access token (classic)** na conta que disparara o deploy, com
o escopo `read:packages`. Grave-o sem coloca-lo no historico do shell:

```bash
gh secret set GHCR_PULL_TOKEN -R "$ORG/postech-sw-arch-p3"
```

O comando solicitara o valor de forma interativa. Isso e importante porque o
workflow usa quem disparou a execucao como usuario do GHCR.

## 6. Disparar uma pipeline sem novo commit

Os CDs de RDS, EKS e Lambda ainda nao possuem `workflow_dispatch`. Reexecute a
ultima execucao da `main`:

```bash
REPO="fiap-postech-sw-architecture/postech-sw-arch-p3-infra-db"
RUN_ID="$(gh run list -R "$REPO" --workflow cd.yml --branch main --limit 1 \
  --json databaseId --jq '.[0].databaseId')"
gh run rerun "$RUN_ID" -R "$REPO"
gh run watch "$RUN_ID" -R "$REPO" --exit-status
```

Troque `REPO` conforme a etapa. Antes do `rerun`, confirme que o run encontrado
e da branch `main` e do workflow CD. A aplicacao aceita disparo manual direto:

```bash
REPO="fiap-postech-sw-architecture/postech-sw-arch-p3"
gh workflow run cd.yml -R "$REPO" --ref main
gh run list -R "$REPO" --workflow cd.yml --branch main --limit 3
```

Abra o run exibido e aguarde todos os jobs, especialmente `deploy-eks`.

## 7. Ordem para provisionar do zero

Nao execute dois `terraform apply` do mesmo repositorio ao mesmo tempo.

### 7.1 RDS

Dispare o CD de `postech-sw-arch-p3-infra-db` pela `main` e aguarde sucesso.
Depois obtenha o endpoint:

```bash
DB_ENDPOINT="$(aws rds describe-db-instances \
  --region us-east-1 \
  --db-instance-identifier pytstop \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text)"
DATABASE_URL="postgresql://pytstop:${DB_PASSWORD}@${DB_ENDPOINT}:5432/pytstop"
```

Grave a mesma URL na aplicacao e na Lambda:

```bash
printf '%s' "$DATABASE_URL" | \
  gh secret set RDS_DATABASE_URL -R "$ORG/postech-sw-arch-p3"
printf '%s' "$DATABASE_URL" | \
  gh secret set TF_VAR_DATABASE_URL -R "$ORG/postech-sw-arch-p3-lambda"
```

### 7.2 EKS

Dispare o CD de `postech-sw-arch-p3-infra-k8s` pela `main` e aguarde sucesso.
Valide:

```bash
aws eks describe-cluster --region us-east-1 --name pytstop-p3 \
  --query 'cluster.status' --output text
aws eks update-kubeconfig --region us-east-1 --name pytstop-p3
kubectl get nodes
```

O status esperado e `ACTIVE`, e os nodes devem estar `Ready`.

### 7.3 Aplicacao e NLB interno

Dispare manualmente o CD de `postech-sw-arch-p3` na `main`. Depois valide os
pods e obtenha o listener do NLB criado pelo Service:

```bash
kubectl -n pytstop get pods

LB_HOST="$(kubectl -n pytstop get service pytstop-api \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
LB_ARN="$(aws elbv2 describe-load-balancers --region us-east-1 \
  --query "LoadBalancers[?DNSName=='${LB_HOST}'].LoadBalancerArn | [0]" \
  --output text)"
LISTENER_ARN="$(aws elbv2 describe-listeners --region us-east-1 \
  --load-balancer-arn "$LB_ARN" \
  --query 'Listeners[?Port==`8000`].ListenerArn | [0]' \
  --output text)"

test -n "$LISTENER_ARN" && test "$LISTENER_ARN" != "None"
printf '%s' "$LISTENER_ARN" | \
  gh secret set TF_VAR_APP_LISTENER_ARN -R "$ORG/postech-sw-arch-p3-lambda"
```

### 7.4 Lambda e API Gateway

Dispare o CD de `postech-sw-arch-p3-lambda` pela `main`. O mesmo Terraform cria
as Lambdas, o API Gateway, o VPC Link e os stages `homolog` e `prod`.

Obtenha a URL atual sem depender de um ID fixo:

```bash
API_ENDPOINT="$(aws apigatewayv2 get-apis --region us-east-1 \
  --query 'Items[?Name==`pytstop-autenticacao`].ApiEndpoint | [0]' \
  --output text)"
printf '%s\n' "$API_ENDPOINT/prod"
```

## 8. Smoke test final

O deploy executa a migracao e o seed. Use um CPF sintetico do seed:

```bash
TOKEN="$(curl --fail-with-body --silent \
  -X POST "$API_ENDPOINT/prod/auth" \
  -H 'Content-Type: application/json' \
  -d '{"cpf":"11144477735"}' | jq -r '.access_token')"

test -n "$TOKEN" && test "$TOKEN" != "null"

curl --fail-with-body --silent \
  -H "Authorization: Bearer $TOKEN" \
  "$API_ENDPOINT/prod/api/v1/minhas-ordens" | jq .

curl --silent --output /dev/null --write-out '%{http_code}\n' \
  "$API_ENDPOINT/prod/api/v1/minhas-ordens"
```

Resultados esperados: autenticar retorna `200`, a rota com token retorna `200`
e a ultima chamada, sem token, imprime `401`. Ao terminar, remova o token da
sessao:

```bash
unset TOKEN
```

## 9. Falhas mais comuns

- `ExpiredToken` ou `InvalidClientTokenId`: reinicie o Learner Lab e atualize os
  tres secrets AWS nos quatro repositorios.
- `NoSuchBucket` no `terraform init`: a conta nao possui o bucket de state
  esperado; nao continue em outra conta sem adaptar os backends.
- falha de pull no GHCR: renove `GHCR_PULL_TOKEN` com `read:packages` e dispare o
  workflow com a mesma conta dona do token.
- Lambda sem acesso ao app: confira se `TF_VAR_APP_LISTENER_ARN` corresponde ao
  NLB atual e a porta `8000`.
- autenticacao falha depois de trocar segredos: confirme que JWT, chave de
  criptografia e URL do banco sao identicos entre aplicacao e Lambda.

## 10. Encerramento e custo

O **End Lab** nao destroi EKS, RDS, NLB, API Gateway ou VPC Link. Ao final da
gravacao, destrua na ordem inversa: Lambda/Gateway/VPC Link → aplicacao/NLB → EKS
→ RDS. Preserve o bucket versionado de state ate confirmar que todo o restante
foi removido.
