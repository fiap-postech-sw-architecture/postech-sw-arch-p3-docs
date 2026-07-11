# Fase 3 — Próximas etapas e pendências

Estado consolidado após o bootstrap de 2026-07-11. Ordem recomendada de retomada.

## O que já está pronto (tudo verde localmente)

| Repo | Estado |
|---|---|
| [postech-sw-arch-p3](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3) | Snapshot do p2 (cobertura 97.5%), Azure removido, docs fase 3 completos (desafio, gap analysis, ADRs 026-033, RFC-003); Onda 1 (métricas + monitoramento) em andamento |
| [postech-sw-arch-p3-lambda](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-lambda) | Function auth CPF→JWT + authorizer + Terraform do gateway; 28 testes, cobertura 100%, terraform validate ok; emulação local pytest + SAM |
| [postech-sw-arch-p3-infra-k8s](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-infra-k8s) | Terraform EKS (LabRole, addons, metrics-server); fmt+validate ok |
| [postech-sw-arch-p3-infra-db](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-infra-db) | Terraform RDS PostgreSQL 16; fmt+validate ok |
| [postech-sw-arch-p3-docs](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-docs) | Spec, planos (fases 0-3 e 4-5), 4 fichamentos, runbooks |

## Pendências do usuário (ninguém mais consegue fazer)

1. **Ativar AWS Academy** — passo a passo completo: [aws-academy-setup.md](aws-academy-setup.md). Sem isso a Onda 4 (deploy real) fica bloqueada.
2. **Cota GitHub Actions** — aguardar renovação (pipelines já commitados nos 4 repos; validar no primeiro dia de cota).
3. **Colaborador `soat-architecture`** nos 4 repos novos — rodar `local/postech-bootstrap/scripts/grant-access.sh` (manual, exigência da entrega).
4. **Vídeo (≤15min) e submissão do PDF** — fase 5 do plano; depende das ondas 1-4.

## Próximas etapas técnicas (plano detalhado: [fases 4-5](../superpowers/plans/2026-07-11-fase-3-fases-4-5-plan.md))

1. **Onda 1 (em andamento)**: métricas Prometheus na API + Grafana/Loki/Promtail/kube-state-metrics no k8s/ + dashboards e alertas exigidos (RF-027, RNF-028/029).
2. **Onda 2**: overlay kustomize EKS, branch `homolog` + cd.yml homolog/produção, README do p3 reescrito.
3. **Onda 3**: rota protegida real no gateway (integração com app), demo local integrada (SAM + kind).
4. **Onda 4 (bloqueada por credenciais)**: applies na ordem infra-db → infra-k8s → lambda → app; secrets do Actions; smoke fim-a-fim; `terraform destroy` pós-demo (budget).
5. **Onda 5**: branch protection nos 4 repos, collection, roteiro do vídeo, PDF (skill entrega-tech-challenge).

## Riscos monitorados

- Hipóteses do ADR-030 (LabRole funciona como cluster/node role; addon metrics-server disponível) só se confirmam no primeiro `terraform plan` com credenciais.
- Credenciais do lab expiram a cada ~4h — secrets de CI precisam re-gravação por sessão (`aws-academy-setup.md` §5).
- Budget Academy: EKS+RDS ligados consomem rápido; sempre `terraform destroy` após validar/gravar.
