# Design: Bootstrap da Fase 3 (postech-sw-arch-p3 + repos satelites)

- **Data**: 2026-07-11
- **Status**: FASES 0-3 CONCLUIDAS em 2026-07-11 (repos criados e populados, fichamentos, gap analysis, ADRs 026-033, RFC-003 — tudo com revisao canonica). Ondas 1-2 do plano de implementacao tambem concluidas (metricas+monitoramento verificados ao vivo no kind; overlay EKS + pipeline homolog/producao + README). Pendencias: credenciais AWS Academy (onda 4), cota GitHub Actions, branch protection (org free + repos privados — mesma limitacao da fase 2; upgrade Team ou repo publico), soat-architecture, video/PDF.
- **Escopo**: processo completo de geracao da fase 3 do Tech Challenge FIAP Pos Tech (Arquitetura de Software), evoluindo o PytStop da fase 2 em **quatro repositorios separados** (exigencia do challenge) mais um repositorio de documentacao e planejamento.

## Objetivo

Atender ao Tech Challenge da fase 3 (60% da nota da fase): API Gateway com autenticacao via CPF por Function Serverless (JWT), segregacao em 4 repositorios com CI/CD completo e deploy automatico, infraestrutura como codigo (Terraform: cluster Kubernetes + banco gerenciado), monitoramento e observabilidade (latencia, recursos, healthchecks, alertas, logs estruturados com correlacao, dashboards), e documentacao arquitetural completa (diagrama de componentes, diagrama de sequencia, RFCs, ADRs, justificativa formal do banco com diagrama ER).

## Contexto

- **p2 (PytStop 0.2.x)**: completo e entregue — Python 3.14, FastAPI, SQLAlchemy 2.0 imperativa, PostgreSQL 16, DDD + arquitetura da fase 2 (ADR-015), K8s com HPA, Terraform, OTel + Jaeger + Prometheus, cobertura 97.5%, ADRs 000-025, RFC-001/002. **Nao sera modificado** (decisao do usuario).
- **Material da fase 3**: 5 modulos com texto integralmente extraido em `local/postech-bootstrap/lessons/phase3/` (API-Gateway, Monitoramento, Monitoramento-Avancado, Serverless, Welcome) + Challenge.
- **Repos**: org `fiap-postech-sw-architecture`, todos privados, colaborador `soat-architecture` (leitura) a conferir por repo.
- **Conta cloud**: AWS Academy (convite FIAP), **ainda nao configurada** — nenhuma credencial disponivel nesta etapa.
- **Cota GitHub Actions esgotada**: pipelines CI/CD sao escritos e commitados, mas nao rodam ate a cota renovar; os mesmos checks rodam localmente (gate local obrigatorio antes de cada push).

## Decisoes do brainstorming

Decisoes dadas pelo usuario no pedido; itens tecnicos em aberto ficam para ADRs apos os fichamentos (mesmo padrao da fase 2).

1. **Cinco repositorios, mesma org, nomes novos**:

   | Repo | Papel (challenge) |
   |---|---|
   | `postech-sw-arch-p3` (existente) | Aplicacao principal executando em Kubernetes |
   | `postech-sw-arch-p3-lambda` | Function Serverless de autenticacao (CPF → JWT) |
   | `postech-sw-arch-p3-infra-k8s` | Infraestrutura Kubernetes (Terraform) |
   | `postech-sw-arch-p3-infra-db` | Infraestrutura do banco gerenciado (Terraform) |
   | `postech-sw-arch-p3-docs` | Documentacao e planejamento (artefatos de processo: specs, plans, research, runbooks) — fora dos 4 exigidos |

2. **Sem seed de historico**: a fase 2 permanece intocada e o p3 **nao herda o historico git do p2**. A aplicacao principal parte de um **snapshot da tree do p2 main** como commit inicial ("Import do PytStop 0.2.x (tree do p2 @ <sha>)"), com proveniencia registrada no commit e no README. Entregaveis novos em cada repo.
3. **Cloud: AWS via AWS Academy.** O bootstrap produz tudo que nao depende de credencial: Terraform completo (validado com `terraform validate` + `terraform plan` onde possivel sem credencial), pipelines, e um **passo a passo documentado** do que o usuario faz para ativar o Learner Lab e fornecer credenciais, mais o runbook do que executar quando elas existirem.
4. **Local-first**: tudo roda localmente na medida do possivel — app em kind (como na fase 2), banco em Docker/kind, **lambda emulada localmente** (mecanismo decidido em ADR: invocacao direta em pytest + emulador, candidatos SAM CLI / Lambda RIE / shim proprio), gateway local se o ADR de gateway permitir. CI/CD replicado por gate local (`make gate`): ruff check + ruff format --check + mypy + bandit + pytest com cobertura.
5. **Framework de processo: superpowers** — brainstorming → spec → plan → execucao, com revisao canonica (`postech-ai-helper/ai/canonical/code-review.md`): deep para artefatos maiores (esta spec, ADRs, RFC-003), secoes 8+9 para docs triviais. Artefatos de processo agora no repo `postech-sw-arch-p3-docs` (substitui `local/postech-bootstrap/docs/superpowers/` da fase 2).
6. **Cobertura de testes > 95%** em todo repo com codigo (app e lambda); mesmos scans da fase 2 (bandit, pip-audit).
7. **Push continuo autorizado** pelo usuario. Bootstrap inicial: push direto na main dos repos novos enquanto vazios; apos o bootstrap, ativar branch protection (exigencia do challenge: main protegida, PRs obrigatorios) e voltar ao fluxo branch → PR. Sem auto-merge em PRs (regra permanente do usuario).
8. **Numeracao continua**: requisitos novos a partir de **RF-025 / RNF-025 / RN-021** (fase 2 terminou em RF-024/RNF-024/RN-020); ADRs a partir de **026**; **RFC-003**. ADRs e RFC vivem no repo da aplicacao principal (`docs/arquitetura/`), como nas fases anteriores; cada repo satelite tem README com diagrama proprio (exigencia do challenge) e aponta para os ADRs do repo principal.

## Fases do processo (mesma ordem da fase 2)

### Fase 0 — Repos e planejamento
Criar os 4 repos novos na org (feito em 2026-07-11), corrigir remote do p3 (transferencia jbamaral → org), bootstrap do `p3-docs` com esta spec. Pendencias manuais do usuario listadas ao final.

### Fase 1 — Estudo do material (research)
Fichamentos por sub-agentes em paralelo, um por modulo (API-Gateway, Serverless, Monitoramento, Monitoramento-Avancado; Welcome so se tiver conteudo tecnico), salvos em `postech-sw-arch-p3-docs/docs/superpowers/research/<slug>.md`. Mesma estrutura da fase 2 (resumo por aula, ferramentas obrigatorias vs opcionais, implicacoes para o PytStop, sinais de avaliacao). Perguntas obrigatorias:

- **Serverless**: qual runtime/formato de lambda o material usa? Cobre emulacao local (SAM, LocalStack, RIE)? Integracao com API Gateway?
- **API-Gateway**: o material foca AWS API Gateway ou gateways auto-hospedados (Kong/Traefik)? Como trata autenticacao/authorizers?
- **Monitoramento(-Avancado)**: quais ferramentas o material enfatiza (Datadog, New Relic, Prometheus/Grafana, CloudWatch)? Ha exigencia implicita de SaaS ou stack livre?

### Fase 2 — Gap analysis (challenge × p2)
No repo principal p3, `docs/requisitos/`: copia do challenge (`desafio-tech-fase-3.md`, fonte: `lessons/phase3/Challenge/Phase3_Tech_Challenge.txt` — fonte de verdade e o enunciado oficial) + `gap-analysis-fase-3.md` confrontando cada exigencia com o estado real do p2 (evidencia file:line). Itens minimos: autenticacao atual JWT proprio × exigida via gateway + lambda por CPF; segregacao mono-repo × 4 repos; Terraform atual (Azure) × AWS Academy; observabilidade atual (OTel/Jaeger/Prometheus) × exigencias de dashboards/alertas; modelagem ER documentada e justificativa formal do banco.

### Fase 3 — Decisoes formais (ADRs 026+ e RFC-003)
ADRs no p3 (`docs/arquitetura/adr/fase3/`), decididos com base nos fichamentos e nas restricoes do AWS Academy:

- **ADR-026 — Cloud alvo: AWS Academy** (restricoes: sessao Learner Lab ~4h, credenciais temporarias por sessao, `LabRole` fixo sem criar IAM roles/users, budget limitado, regioes restritas us-east-1/us-west-2) e consequencias para Terraform (sem gestao de IAM; providers com credenciais de sessao);
- **ADR-027 — API Gateway** (AWS API Gateway vs Kong/Traefik; criterio: exigencias do challenge, material, executavel local, custo Academy);
- **ADR-028 — Autenticacao serverless** (lambda Python CPF → consulta cliente → JWT; compatibilidade com JWT do app; segredo compartilhado vs JWKS);
- **ADR-029 — Emulacao local da lambda** (pytest direto + SAM local vs RIE vs shim FastAPI; criterio: rodar sem credencial AWS);
- **ADR-030 — Cluster Kubernetes na AWS** (EKS via Terraform no Academy vs alternativa; kind continua o alvo local);
- **ADR-031 — Banco gerenciado** (RDS PostgreSQL; justificativa formal exigida pelo challenge + ER; local: Postgres em Docker/kind);
- **ADR-032 — Monitoramento** (ferramenta conforme fichamento: Datadog/New Relic free tier vs Prometheus/Grafana/CloudWatch; criterio: dashboards exigidos, custo zero, demo no video);
- **ADR-033 — Estrategia CI/CD multi-repo** (deploy automatico homolog/producao, branch protection, orquestracao entre os 4 repos, secrets de credencial temporaria Academy).

Numeros podem ser fundidos/desdobrados na execucao; a lista acima e o escopo minimo. **RFC-003** (`docs/arquitetura/rfc/fase3/`): design integrado da fase 3 — topologia AWS (gateway + lambda + EKS + RDS + monitoramento), fluxo de autenticacao (diagrama de sequencia exigido pelo challenge), fluxo de deploy multi-repo, correlacao de logs/traces, diagrama de componentes reutilizavel nos READMEs.

### Fase 4 — Implementacao (ondas, plano writing-plans proprio)
Plano detalhado escrito apos ADRs/RFC (dois estagios, como na fase 2). Ondas previstas:

1. **App (p3)**: snapshot do p2, remocao do que migra para repos satelites (`infra/` Terraform, autenticacao propria onde o gateway assume), adaptacoes de configuracao; gate local verde, cobertura > 95%;
2. **Lambda**: handler Python (validar CPF, consultar cliente, emitir JWT), testes unitarios + emulacao local, empacotamento (zip/imagem), cobertura > 95%;
3. **Infra-db**: Terraform RDS + esquema/migracoes de responsabilidade do app; `terraform validate` local; paridade local via Docker;
4. **Infra-k8s**: Terraform EKS + manifests/kustomize do cluster; overlay local kind funcional;
5. **CI/CD nos 4 repos**: build → checks → imagem → deploy homolog/producao (workflows completos; execucao real pendente de cota + credenciais); gate local espelhando cada pipeline;
6. **Monitoramento**: instrumentacao conforme ADR-032, dashboards exigidos (volume diario de OS, tempo medio por status, erros de integracao), alertas, logs JSON correlacionados — demonstravel localmente;
7. **Docs de entrega**: READMEs por repo (proposito, tecnologias, execucao/deploy, diagrama proprio, link Swagger/Postman), diagrama de sequencia da autenticacao, justificativa do banco + ER.

### Fase 5 — Entrega
Roteiro do video (ate 15min: autenticacao CPF, pipeline, deploy automatico, APIs protegidas, dashboard ao vivo, logs/traces), PDF de submissao (links dos 4 repos + video + docs + confirmacao `soat-architecture`). Depende de credenciais AWS e cota CI — documentada como proximas etapas.

## AWS Academy — passo a passo do usuario (pre-requisito da fase de deploy)

Mantido em runbook proprio para nao driftar: [aws-academy-setup.md](../../runbooks/aws-academy-setup.md) (ativacao, credenciais por sessao, refresh de secrets via `scripts/refresh-aws-secrets.sh`).


## Riscos e pontos abertos

- **Restricoes do Academy** podem bloquear EKS/API Gateway/monitoramento SaaS — mitigacao: ADRs so fecham apos fichamentos; fallback local (kind) mantem a demo possivel, como na fase 2 (ADR-025 teve fallback identico);
- **Cota GitHub Actions**: pipelines nao validaveis no CI ate renovar — mitigacao: gate local identico + `act` opcional; validar no primeiro dia de cota;
- **Credenciais temporarias × Terraform state**: sessions de 4h exigem re-auth; state local ou backend simples (decidir no ADR-026);
- **JWT gateway × app**: risco de duplicidade de emissores de token — resolver no ADR-028 (fonte unica de verdade da autenticacao).

## Fora de escopo

- Qualquer mudanca no p2 (repos, tags, docs);
- Mudanca de stack da aplicacao (mantem Python/FastAPI/SQLAlchemy/PostgreSQL);
- Hackathon e fase 4;
- Execucao de deploy real na AWS e gravacao do video (dependem do usuario: credenciais + cota).

## Criterios de sucesso

1. 5 repos na org com conteudo completo ate o limite do que nao exige credencial AWS nem cota CI;
2. Fichamentos, gap analysis, ADRs 026+ e RFC-003 escritos e revisados (revisao canonica, deep nos maiores);
3. App e lambda rodando e testados localmente, cobertura > 95% cada, gate local verde (ruff, mypy, bandit, pytest);
4. Terraform dos dois repos infra validado localmente (`terraform validate`/`fmt`);
5. Pipelines CI/CD completos commitados nos 4 repos; branch protection ficou INVIAVEL (org free + repos privados, HTTP 403) — mitigacao registrada em adendo do ADR-033;
6. Runbook AWS Academy + documento de proximas etapas/pendencias claros o suficiente para retomar com credenciais na mao.
