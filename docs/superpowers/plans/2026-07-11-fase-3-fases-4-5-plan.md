# Fase 3 — Plano de Implementacao das Fases 4–5 (ondas de implementacao e entrega)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implementar a fase 3 conforme ADRs 026-033 e RFC-003 (repo p3), nos 4 repos entregaveis + docs, ate o limite do que nao exige credencial AWS nem cota de GitHub Actions. Tudo demonstravel localmente.

**Architecture:** Cada onda fecha com gate local verde (app: `make check`; lambda: `make check` + `tf-validate`; infra: `make gate`) e push. Cobertura ≥95% onde ha codigo. Revisao canonica antes de cada commit relevante. Sem auto-merge; durante o bootstrap push direto na main foi autorizado — apos a onda final, branch protection liga nos 4 repos e o fluxo volta a PR.

**Estado ao escrever este plano (bootstrap concluido):** repos criados e populados — p3 (snapshot p2 + docs fase 3 + Azure removido), p3-lambda (function + authorizer + Terraform gateway, cobertura 100%), p3-infra-k8s (EKS validate ok), p3-infra-db (RDS validate ok), p3-docs (spec, planos, fichamentos, runbook).

---

### Onda 1: App — metricas e observabilidade (ADR-032; RF-027, RNF-028/029)

**Repo:** p3. TDD; cobertura ≥95% mantida.

- [x] **Step 1: Metricas Prometheus na API** — middleware/instrumentacao de latencia (histograma por rota/status p50/p90/p99) + metricas de negocio: `os_criadas_total` (volume diario via increase), `os_tempo_medio_por_status` (a partir do endpoint `/metricas` existente ou gauge calculado), `integracao_falhas_total` (erros outbox/relay ja existem — reaproveitar ADR-024). Expor `/metrics` na API (hoje so o relay expoe).
- [x] **Step 2: Correlation id na borda** — middleware aceita `X-Request-ID` externo (gateway) em vez de sempre gerar (`src/compartilhado/interfaces/middleware.py:41`); scrub PII preservado; testes.
- [x] **Step 3: `OTEL_ENABLED` default on em demo** — overlays/valores de demo com OTel ligado (codigo permanece com default off; so config).
- [x] **Step 4: Prometheus scrape da API** + **kube-state-metrics + cAdvisor/kubelet** no `k8s/` (scrape configs); **Grafana** (deployment + dashboards JSON versionados: volume diario OS, tempo medio por status, erros de integracoes, latencia p50/p90/p99, CPU/mem por pod, NOC verde/amarelo/vermelho) ; **Loki + Promtail** (logs JSON, labels por contexto, consulta por request_id); **alertas Grafana** (CPU>80%/10min, p95>300ms/5min, erro>1%, `/api/v1/saude` fora, outbox dead>0).
- [x] **Step 5: `make k8s-up` local com a stack completa; smoke test de dashboards/alertas; gate verde; push.**

### Onda 2: App — deploy homolog/producao e overlay EKS (ADR-030/033; RNF-025)

**Repo:** p3.

- [x] **Step 1: Overlay kustomize `k8s/overlays/eks/`** (imagem por registry, Service LoadBalancer/Ingress, resources ajustados, DATABASE_URL do RDS via Secret, metrics-server ja no cluster — nao aplicar o manifest local).
- [x] **Step 2: Branch `homolog`** criada; `cd.yml` ganha trigger homolog (deploy homologacao) e main (producao); enquanto cota esgotada, `make cd-local` continua o espelho.
- [x] **Step 3: README do p3 reescrito para a fase 3** (proposito, tecnologias, diagrama proprio — reutilizar componente do RFC-003, execucao local, deploy, link Swagger; secao status/pendencias).

### Onda 3: Lambda — integracao com app (ADR-027/028)

**Repo:** p3-lambda (+ p3 config).

- [ ] **Step 1: Rota protegida real no gateway** — integracao HTTP_PROXY para o endpoint publico do app no EKS (URL via variavel Terraform; placeholder documentado ate o EKS existir).
- [x] **Step 2: Demo local integrada** (roteiro no README da lambda) — `sam local start-api` + app no kind: roteiro no README (token da lambda consumido numa rota do app validada pelo authorizer emulado).
- [x] **Step 3: `terraform.tfvars.example` no repo lambda** (faltou no bootstrap).

### Onda 4: Deploy real na AWS (BLOQUEADA: credenciais Academy)

**Repos:** infra-db → infra-k8s → lambda → p3 (ordem ADR-033). Pre-requisito: runbook `aws-academy-setup.md` executado pelo usuario.

- [ ] infra-db `apply`; capturar endpoint; migracoes Alembic apontando para o RDS.
- [ ] infra-k8s `apply`; `update-kubeconfig`; confirmar LabRole/metrics-server (primeiro plan valida as hipoteses do ADR-030).
- [ ] p3 deploy overlay EKS; smoke.
- [ ] lambda/gateway `apply` com URL real do app; teste fim-a-fim CPF→JWT→rota protegida.
- [ ] Secrets do Actions nos 4 repos (`scripts/refresh-aws-secrets.sh`); primeiro CD verde quando a cota renovar.
- [ ] `terraform destroy` pos-validacao (budget).

### Onda 5: Entrega (fase 5 da spec)

> Nota 2026-07-11: branch protection via API bloqueada — org free + repos privados (HTTP 403 "Upgrade to GitHub Pro"); o p2 tem a MESMA limitacao desde a fase 2. Opcoes: upgrade da org para Team, tornar repos publicos na entrega, ou documentar a convencao de PR obrigatorio (fluxo canonico) como mitigacao. Branches homolog criadas nos 4 repos.

- [ ] Diagrama de sequencia + componentes ja no RFC-003; conferir READMEs dos 4 repos (proposito, tecnologias, execucao, diagrama, Swagger/Postman).
- [ ] Collection Postman/Swagger export atualizado (rotas novas via gateway).
- [ ] Roteiro do video (≤15min): autenticacao CPF, pipeline, deploy automatico, APIs protegidas, dashboard ao vivo, logs/traces.
- [ ] PDF de submissao (links 4 repos + video + docs + confirmacao soat-architecture) — skill entrega-tech-challenge.
- [ ] Branch protection na main dos 4 repos + conferir colaborador `soat-architecture` (grant-access.sh, manual).

---

## Dependencias

```
Onda 1 → Onda 2 (README cita dashboards) → Onda 3 (demo integrada)
Onda 4 bloqueada por credenciais (independente de 1-3 no codigo, depende p/ URLs reais)
Onda 5 depende de 1-3 (local) e idealmente 4 (links de deploy ativos)
```
