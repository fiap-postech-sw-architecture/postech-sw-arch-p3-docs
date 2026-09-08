# Runbook — AWS Academy (Learner Lab): ativacao e credenciais

Passo a passo para habilitar a conta AWS Academy da FIAP, renovar as credenciais e executar os pipelines. O fluxo completo foi validado em `us-east-1` em 07/09/2026.

## 1. Ativar a conta (uma unica vez)

1. Abrir o e-mail de convite do **AWS Academy** enviado pela FIAP e aceitar o convite.
2. Criar conta no Canvas do AWS Academy (ou entrar com conta existente) — o convite vincula ao curso *AWS Academy Learner Lab*.
3. Entrar no curso e aceitar os termos na primeira execucao.

## 2. Iniciar uma sessao do lab (a cada uso)

1. No curso, abrir **Modules → Launch AWS Academy Learner Lab**.
2. Clicar **Start Lab** e aguardar o indicador AWS ficar **verde**.
3. Observacoes importantes do Learner Lab:
   - Sessao dura **~4 horas** (relogio no topo); recursos continuam existindo entre sessoes, mas instancias EC2 param.
   - **Budget limitado** (tipicamente US$ 50–100, visivel no topo). Esgotou = conta encerrada sem aviso. Monitorar.
   - Regiao adotada pelo projeto: **us-east-1**.
   - **IAM restrito**: nao e possivel criar usuarios/roles; tudo roda com a role pre-existente **`LabRole`** (e instance profile `LabInstanceProfile`). O Terraform da fase 3 ja assume isso.

## 3. Obter credenciais (a cada Start Lab — elas mudam sempre)

1. Com o lab verde, clicar **AWS Details** (canto superior direito).
2. Em **AWS CLI**, clicar **Show** e copiar o bloco:

   ```ini
   [default]
   aws_access_key_id=ASIA...
   aws_secret_access_key=...
   aws_session_token=...
   ```

3. Colar em `~/.aws/credentials` sob o perfil **`default`**, sem renomear.
4. Persistir a regiao e conferir a identidade:

   ```bash
   aws configure set region us-east-1
   aws sts get-caller-identity
   ```

> As tres chaves **expiram ao fim da sessao**. Refazer este passo a cada Start Lab.

## 4. Entregar ao agente / configurar pipelines

Com as credenciais `default` validas:

1. Validar com AWS CLI os recursos criados pelo usuario, sempre em `us-east-1`.
2. Um operador autorizado configura os secrets de deploy nos 4 repos GitHub (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`) — **precisam ser re-gravados a cada sessao do lab**. A regiao `us-east-1` esta fixa nos workflows.
3. Rodar smoke tests contra os recursos criados.

Nunca commitar credenciais; apenas `~/.aws/credentials` local e GitHub Secrets.

## 5. Refresh rapido (sessoes seguintes)

```bash
# 1. Start Lab no Canvas; 2. copiar bloco AWS CLI; 3. atualizar [default]; entao:
aws sts get-caller-identity   # sanity
gh secret set AWS_ACCESS_KEY_ID -R fiap-postech-sw-architecture/<repo> --body "..."
gh secret set AWS_SECRET_ACCESS_KEY -R fiap-postech-sw-architecture/<repo> --body "..."
gh secret set AWS_SESSION_TOKEN -R fiap-postech-sw-architecture/<repo> --body "..."
```

O script [`scripts/refresh-aws-secrets.sh`](../../scripts/refresh-aws-secrets.sh) automatiza o loop das credenciais pelos 4 repos.

## 6. Provisionar e validar a integracao privada

As acoes de criacao, `apply`, atualizacao de secrets e `destroy` exigem autorizacao explicita do usuario. A validacao usa AWS CLI e `kubectl` em modo somente leitura.

Ordem obrigatoria:

1. Criar e validar o bucket S3 versionado usado pelos states Terraform.
2. Aplicar o RDS.
3. Aplicar o EKS, incluindo `172.31.240.0/24` em `us-east-1a` e `172.31.241.0/24` em `us-east-1b`, sem NAT ou rota default.
4. Implantar o app e aguardar o Service criar o NLB interno.
5. Obter o hostname criado para o Service, localizar o mesmo NLB no inventario interno e obter o ARN do listener TCP 8000:

   ```bash
   kubectl -n pytstop get service pytstop-api \
     -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

   aws elbv2 describe-load-balancers --region us-east-1 \
     --query 'LoadBalancers[?Scheme==`internal`].[LoadBalancerArn,DNSName,State.Code]'

   aws elbv2 describe-listeners --region us-east-1 \
     --load-balancer-arn <NLB_ARN> \
     --query 'Listeners[?Port==`8000`].ListenerArn' --output text
   ```

   Compare o `DNSName` retornado pela AWS com o hostname do Service antes de usar o respectivo `LoadBalancerArn` no segundo comando.

6. Informar o ARN como `app_listener_arn` no uso local ou o usuario atualizar o GitHub Secret `TF_VAR_APP_LISTENER_ARN`.
7. Aplicar o Terraform de Lambda/Gateway, que cria o VPC Link.
8. Validar `POST /auth` e as rotas protegidas pelo endpoint HTTPS publico do API Gateway. O NLB permanece privado.

O deploy automatico de producao foi validado em 07/09/2026 por merges na `main`, nesta ordem:

- [RDS](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-infra-db/actions/runs/34177626665)
- [EKS](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-infra-k8s/actions/runs/34178105568)
- [aplicacao](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3/actions/runs/34178566291)
- [Lambda e API Gateway](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-lambda/actions/runs/34179043515)

Ao recriar o NLB, obtenha o novo listener ARN e atualize a entrada antes de reaplicar Lambda/Gateway.

## 7. Encerrar

- A infraestrutura pode permanecer durante a preparacao e gravacao por no maximo sete dias, com verificacao diaria do budget. Desmonte imediatamente se houver risco de esgotamento ou nao existir nova atividade programada.
- Ao final da gravacao, destruir na ordem inversa: Lambda/Gateway/VPC Link → app/NLB → EKS/subnets privadas → RDS.
- Preserve por padrao o bucket versionado de state, cujo custo sem atividade e minimo. Qualquer remocao futura exige autorizacao explicita, backup dos states e verificacao somente leitura de objetos e versoes.
- Depois do teardown validado, usar **End Lab**. O End Lab isoladamente nao elimina custos de EKS, RDS, NLB ou VPC Link.
