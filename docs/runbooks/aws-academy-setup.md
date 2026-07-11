# Runbook — AWS Academy (Learner Lab): ativacao e credenciais

Passo a passo do lado do usuario para habilitar a conta AWS Academy da FIAP e fornecer credenciais ao agente/pipelines. Enquanto estes passos nao forem executados, todo o trabalho de nuvem fica em modo "pronto para aplicar" (Terraform validado localmente, pipelines commitados).

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
   - Regioes permitidas: normalmente **us-east-1** (as vezes us-west-2). Confirmar na tela do lab.
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

3. Colar em `~/.aws/credentials` sob o perfil **`academy`** (renomear `[default]` → `[academy]`).
4. Conferir: `aws sts get-caller-identity --profile academy` deve responder com o account id do lab.

> As tres chaves **expiram ao fim da sessao**. Refazer este passo a cada Start Lab.

## 4. Entregar ao agente / configurar pipelines

Com o perfil `academy` valido, o agente consegue:

1. `terraform plan/apply` nos repos `postech-sw-arch-p3-infra-db` e `postech-sw-arch-p3-infra-k8s` (`AWS_PROFILE=academy`).
2. Configurar os secrets de deploy nos 4 repos GitHub (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`, `AWS_REGION`) — **precisam ser re-gravados a cada sessao do lab** (limitacao aceita; runbook de refresh abaixo).
3. Rodar smoke tests contra os recursos criados.

Nunca commitar credenciais; apenas `~/.aws/credentials` local e GitHub Secrets.

## 5. Refresh rapido (sessoes seguintes)

```bash
# 1. Start Lab no Canvas; 2. copiar bloco AWS CLI; 3. atualizar perfil academy; entao:
aws sts get-caller-identity --profile academy   # sanity
gh secret set AWS_ACCESS_KEY_ID -R fiap-postech-sw-architecture/<repo> --body "..."
gh secret set AWS_SECRET_ACCESS_KEY -R fiap-postech-sw-architecture/<repo> --body "..."
gh secret set AWS_SESSION_TOKEN -R fiap-postech-sw-architecture/<repo> --body "..."
gh secret set AWS_REGION -R fiap-postech-sw-architecture/<repo> --body "us-east-1"
```

(o script [`scripts/refresh-aws-secrets.sh`](../../scripts/refresh-aws-secrets.sh) deste repo automatiza o loop pelos 4 repos, incluindo `AWS_REGION`.)

## 6. Encerrar

- **End Lab** ao terminar (para o relogio e as instancias). Recursos RDS/EKS continuam consumindo budget enquanto existirem — rodar `terraform destroy` ao fim de cada ciclo de demonstracao se nao for gravar o video em seguida.
