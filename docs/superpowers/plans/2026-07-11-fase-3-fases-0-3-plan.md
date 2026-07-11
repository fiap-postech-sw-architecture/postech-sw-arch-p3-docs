# Fase 3 — Plano de Implementacao das Fases 0–3 (repos, fichamentos, gap analysis, decisoes)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Executar as Fases 0–3 da spec `../specs/2026-07-11-fase-3-bootstrap-design.md`: criar os repos da fase 3, fichar os 4 modulos, produzir a gap analysis (challenge × codigo p2) e formalizar as decisoes (ADRs 026+ e RFC-003) — tudo antes do codigo de implementacao.

**Architecture:** Trabalho documental e de git ops. Artefatos de processo → repo `postech-sw-arch-p3-docs` (push direto na main durante o bootstrap). Artefatos entregaveis (challenge copy, gap analysis, ADRs, RFC-003) → repo `postech-sw-arch-p3` (push direto na main enquanto o bootstrap corre; branch protection + fluxo PR ativados ao final do bootstrap — exigencia do challenge). Revisao canonica (`postech-ai-helper/ai/canonical/code-review.md`) antes de cada commit: deep para artefatos maiores; secoes 8+9 para docs triviais.

**Tech Stack:** git, gh CLI, sub-agentes paralelos (fichamentos), markdown (MADR 3.0 para ADRs, mermaid para diagramas).

**Paths fixos:**
- Workspace: `/Users/jbamaral/git/fiap/postech-sw-architecture/`
- p2 (fonte, intocado): `<workspace>/postech-sw-arch-p2` (origin/main @ de4d0c6)
- p3 app: `<workspace>/postech-sw-arch-p3`
- Repos novos: `postech-sw-arch-p3-{lambda,infra-k8s,infra-db,docs}`
- Material: `/Users/jbamaral/git/local/postech-bootstrap/lessons/phase3/`
- Fichamentos (saida): `<p3-docs>/docs/superpowers/research/`
- IDs da F2 (continuar a partir de): RF-024, RNF-024, RN-020 → novos comecam em **RF-025, RNF-025, RN-021**; ADRs em **026**; **RFC-003**

---

### Task 1: Fase 0 — Repos e base

- [x] **Step 1: Criar os 4 repos novos na org** (`gh repo create fiap-postech-sw-architecture/postech-sw-arch-p3-{lambda,infra-k8s,infra-db,docs} --private`) — feito 2026-07-11.
- [x] **Step 2: Corrigir remote do p3** (transferencia jbamaral → org): `git remote set-url origin git@github.com:fiap-postech-sw-architecture/postech-sw-arch-p3.git`.
- [x] **Step 3: Bootstrap do p3-docs**: README + spec de design + runbook AWS Academy; push na main.
- [x] **Step 4: Snapshot p2 → p3**: `git rm -rq . && git -C ../postech-sw-arch-p2 archive origin/main | tar -x -C . && git add -A && git commit` (commit com proveniencia `p2 @ de4d0c6`); push. Sem heranca de historico (decisao da spec). os subdiretorios Azure de `infra/` (azure-aks, azure-vm) vieram no snapshot e foram removidos ainda no bootstrap (commit 947fe17); `infra/` raiz (kind local) permanece — rastreio no gap analysis §4.
- [x] **Step 5: Gate local baseline no p3**: `make check` verde (lint, lint-arch, mypy, bandit, testes) — confirmado 2026-07-11.

### Task 2: Fase 1 — Fichamentos (4 sub-agentes paralelos)

- [x] **Step 1: Despachar 4 sub-agentes** (API-Gateway, Serverless, Monitoramento, Monitoramento-Avancado), mesma estrutura da fase 2 + perguntas obrigatorias por modulo (gateway local?, emulacao lambda?, ferramentas de monitoramento exigidas?). Welcome sem conteudo tecnico — nao fichado.
- [x] **Step 2: Verificar estrutura** (>= 5 secoes `## ` por arquivo, secao "Perguntas obrigatorias" presente).
- [x] **Step 3: Revisao canonica (secoes 8+9) + commit no p3-docs.**

**Veredito dos fichamentos (insumo dos ADRs):** Serverless = AWS API Gateway + Lambda + **SAM CLI com emulacao local**; API-Gateway = Kong/APIM (zero AWS) — a trilha AWS do modulo Serverless + conta Academy decide o gateway; Monitoramento = stack aberta (Zabbix/**Loki/Grafana**/Prometheus); Monitoramento-Avancado = Datadog/New Relic como veiculo didatico, open source reconhecido como alternativa (aula 04) — tecnicas (SLO, alertas acionaveis, dashboards p50/p90/p99 versionados em JSON) portaveis para a stack aberta.

### Task 3: Fase 2 — Challenge copy + Gap analysis (p3)

- [x] **Step 1: `docs/requisitos/fase3/desafio-tech-fase-3.md`** (copia fiel + PDF versionado) — commitado.
- [x] **Step 2: Levantar realidade do codigo p2** (sub-agente read-only; evidencias file:line): autenticacao/JWT atual, consulta cliente por CPF, rotas protegidas, Terraform/k8s atuais, observabilidade (OTel/Prometheus/logs), healthchecks, workflows CI, modelagem do banco/ER, cobertura.
- [x] **Step 3: Escrever `docs/requisitos/fase3/gap-analysis-fase-3.md`** — tabela de gaps (ID novo RF-025+/RNF-025+/RN-021+ × exigencia × estado no p2 com evidencia × acao), secoes: autenticacao via gateway+lambda × JWT proprio; segregacao 4 repos × monorepo; Terraform Azure × AWS Academy; observabilidade atual × dashboards/alertas exigidos; modelagem ER/justificativa formal do banco; destino de componentes (infra/ Azure, ui/, relay/, k8s/ local).
- [x] **Step 4: Revisao canonica deep (2 HIGH corrigidos: renumeracao RNF-025+, secao RNF-030 documentacao arquitetural); commit.**

### Task 4: Fase 3 — ADRs 026-033 (p3, `docs/arquitetura/adr/fase3/`)

Padrao MADR do projeto (copiar secoes de `docs/arquitetura/adr/fase2/025-*.md`). Conteudo minimo por ADR conforme spec. Revisao canonica deep no conjunto.

- [x] **Step 1: ADR-026 — Cloud alvo AWS Academy** (restricoes LabRole/sessao 4h/budget/regioes; consequencias para Terraform e CI).
- [x] **Step 2: ADR-027 — API Gateway** (AWS API Gateway vs Kong; criterio: challenge + material Serverless + Academy + emulacao local SAM).
- [x] **Step 3: ADR-028 — Autenticacao serverless** (lambda CPF → cliente → JWT; emissor unico; compatibilidade com autenticacao do app; segredo compartilhado).
- [x] **Step 4: ADR-029 — Emulacao local da lambda** (pytest direto + SAM local vs RIE vs shim; criterio: zero credencial).
- [x] **Step 5: ADR-030 — Cluster K8s AWS** (EKS via Terraform no Academy; kind continua alvo local).
- [x] **Step 6: ADR-031 — Banco gerenciado** (RDS PostgreSQL; justificativa formal + ER exigidos pelo challenge; paridade local Docker).
- [x] **Step 7: ADR-032 — Monitoramento** (Grafana+Loki+Prometheus sobre OTel da fase 2 vs Datadog/New Relic free tier; dashboards/alertas exigidos; demo local).
- [x] **Step 8: ADR-033 — CI/CD multi-repo** (deploy automatico homolog/producao, branch protection, secrets Academy rotativos, gate local espelho da cota esgotada).
- [x] **Step 9: Revisao canonica deep nos 8 (1 HIGH + 5 MEDIUM corrigidos); commit 49fd4ff.**

### Task 5: RFC-003 — Design integrado da fase 3

- [x] **Step 1: `docs/arquitetura/rfc/fase3/rfc-003-gateway-serverless-observabilidade.md`** — secoes: resumo/objetivos; topologia AWS (gateway, lambda, EKS, RDS, monitoramento) + topologia local espelho (kind, SAM, compose); **diagrama de componentes** (mermaid, reusavel nos READMEs); **diagrama de sequencia da autenticacao CPF→JWT→rota protegida e da abertura de OS** (exigencia do challenge); fluxo de deploy multi-repo (ordem: infra-db → infra-k8s → lambda → app); correlacao logs/traces; riscos.
- [x] **Step 2: Mermaid validado (mermaid-cli); commit 62c9ff2.**

### Task 6: Encerramento das Fases 0–3

- [x] **Step 1: MEMORY.md do p3** — secao fase 3 (spec, fichamentos, gap, ADRs, RFC) + correcoes de referencias herdadas do p2.
- [x] **Step 2: MEMORY.md (bootstrap) nos 3 repos satelites** + README inicial de cada um (proposito, diagrama, status).
- [x] **Step 3: Atualizar status da spec; invocar writing-plans para o plano das fases 4–5** (implementacao em ondas: app, lambda, infra-db, infra-k8s, CI/CD, monitoramento, docs de entrega).

---

## Dependencias

```
T1 → T2 → T4 (fichamentos alimentam ADRs)
T1 → T3 (gap precisa do snapshot p3)
T3, T4 → T5 (RFC integra decisoes) → T6
```
