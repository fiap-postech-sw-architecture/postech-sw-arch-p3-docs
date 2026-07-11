# Desbloqueio 1 — Deploy real na AWS (Onda 4)

> **Para o agente executor** (pode ser um modelo simples): siga os steps NA ORDEM, um por vez. Cada step tem comando exato, resultado esperado e regra de parada. Se o resultado esperado não vier, PARE e reporte ao usuário — não improvise. Checkboxes marcam progresso.
> **Pré-requisito humano**: usuário ativou o AWS Academy e atualizou o perfil `academy` (runbook [aws-academy-setup.md](../../runbooks/aws-academy-setup.md) §1-§3). Sessão do lab ~4h: se expirar no meio, refaça §3 do runbook e continue do step onde parou.

**Paths**: workspace `/Users/jbamaral/git/fiap/postech-sw-architecture/`; repos `postech-sw-arch-p3{,-lambda,-infra-k8s,-infra-db}`; este repo = `postech-sw-arch-p3-docs`.

### Task 0: Sanidade da sessão

- [ ] `aws sts get-caller-identity --profile academy` → JSON com Account. Falhou = credenciais expiradas → runbook §3.
- [ ] `bash <p3-docs>/scripts/refresh-aws-secrets.sh` → "secrets atualizados nos 4 repos".

### Task 1: Banco (repo p3-infra-db)

- [ ] `cd postech-sw-arch-p3-infra-db && cp terraform.tfvars.example terraform.tfvars` e definir `db_password` forte (gerar com `openssl rand -base64 24`; guardar — vira secret depois).
- [ ] `make plan` → plano sem erro, ~5-8 recursos a criar. Erro de permissão/role = PARE (hipótese do Learner Lab falhou; reportar mensagem exata).
- [ ] `make apply` → `Apply complete`. Anotar `terraform output endpoint` e `port`.
- [ ] Montar `DATABASE_URL=postgresql://pytstop:<senha>@<endpoint>:5432/pytstop` (não commitar).
- [ ] `gh secret set RDS_DATABASE_URL -R fiap-postech-sw-architecture/postech-sw-arch-p3 --body "<DATABASE_URL>"`.

### Task 2: Cluster (repo p3-infra-k8s)

- [ ] `cd ../postech-sw-arch-p3-infra-k8s && make plan` → sem erro. **Primeira validação real das hipóteses do ADR-030** (LabRole como cluster role; addon metrics-server): erro citando IAM/role/addon = PARE e reporte a mensagem exata (decisão humana).
- [ ] `make apply` (EKS demora 10-15 min) → `Apply complete`.
- [ ] `make kubeconfig` e `kubectl get nodes` → 2 nodes `Ready`.
- [ ] `terraform output cluster_security_group_id` → anotar SG.
- [ ] De volta ao infra-db: acrescentar em `terraform.tfvars` `extra_security_group_ids = ["<SG>"]`; `make apply` → libera 5432 aos nodes.

### Task 3: Migrações + App (repo p3)

- [ ] `cd ../postech-sw-arch-p3` — criar secrets de runtime no cluster (espelha o job deploy-eks do cd.yml; leia o job e execute os mesmos `kubectl create secret` com os valores reais: postgres-credentials com a DATABASE_URL, ghcr-credentials, e o secret de app com JWT_SECRET/ENCRYPTION_KEY/ADMIN_PASSWORD fortes gerados agora — `openssl rand -base64 32` cada; gravar tambem como GitHub Secrets APP_JWT_SECRET/APP_ENCRYPTION_KEY/APP_ADMIN_PASSWORD no repo p3).
- [ ] Render + apply do overlay: seguir a MESMA sequência de 3 passes do job `deploy-eks` em `.github/workflows/cd.yml` (leia o job; execute os comandos kubectl equivalentes com a imagem do último SHA da main). Job de migração deve completar antes das cargas — o cd.yml documenta a ordem.
- [ ] `kubectl -n pytstop get pods` → todos Running/Completed. CrashLoop = PARE, colete `kubectl logs` do pod e reporte.
- [ ] `kubectl -n pytstop get svc pytstop-api` → EXTERNAL-IP (NLB; pode demorar ~3 min). `curl http://<EXTERNAL-IP>:8000/api/v1/saude` → `{"status":"ok"}`. Anotar URL pública.

### Task 4: Lambda + Gateway (repo p3-lambda)

- [ ] `cd ../postech-sw-arch-p3-lambda && cp terraform/terraform.tfvars.example terraform/terraform.tfvars` — preencher jwt_secret/encryption_key com OS MESMOS valores da Task 3 e database_url da Task 1.
- [ ] Configurar a rota protegida para a URL pública do app (variável Terraform da integração HTTP_PROXY — ver README/main.tf; se ainda for TODO da Onda 3, PARE e reporte "Onda 3 Step 1 pendente" com a URL anotada).
- [ ] `make build && terraform -chdir=terraform init && terraform -chdir=terraform apply` → `Apply complete`; anotar `terraform output` do endpoint da API.
- [ ] Smoke fim-a-fim: `curl -X POST <endpoint>/auth -d '{"cpf":"<cpf de cliente ativo criado via API do app>"}' -H 'Content-Type: application/json'` → 200 com `access_token`. CPF inválido → 400; CPF inexistente → 401.
- [ ] Rota protegida com o token → 200; sem token → 401/403.

### Task 5: Evidências + encerramento

- [ ] Capturar screenshots/saídas: `kubectl get pods,hpa`, dashboards Grafana (port-forward), resposta do gateway — salvar em `<p3-docs>/docs/evidencias/aws/` e commitar.
- [ ] Atualizar `docs/entrega/fase3/` no p3 (links de endpoints ficam no PDF só se ainda ativos na banca; senão a justificativa de efêmero já cobre).
- [ ] Registrar no MEMORY.md do p3: hipóteses do ADR-030 confirmadas/negadas + qualquer desvio.
- [ ] **Se não for gravar o vídeo em seguida**: `make destroy` no p3-lambda, depois infra-k8s, depois infra-db (ordem inversa) → budget preservado. Se for gravar: siga direto para o plano Desbloqueio 3.

**Regras de parada gerais**: budget do lab < US$20 → PARE e avise; qualquer `Error` de Terraform não previsto → PARE com a mensagem exata; NUNCA commitar tfvars/credenciais.
