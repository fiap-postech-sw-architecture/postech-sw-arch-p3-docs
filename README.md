# postech-sw-arch-p3-docs

Documentacao e planejamento da **Fase 3** do Tech Challenge — FIAP Pos Tech, Arquitetura de Software (15SOAT).

Este repositorio guarda os artefatos de **processo** da fase 3 (specs, planos, fichamentos de estudo, runbooks e pendencias). Os artefatos **entregaveis** (codigo, ADRs, RFC, READMEs com diagramas) vivem nos 4 repositorios exigidos pelo challenge:

| Repo | Papel |
|---|---|
| [postech-sw-arch-p3](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3) | Aplicacao principal (Kubernetes) |
| [postech-sw-arch-p3-lambda](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-lambda) | Function Serverless de autenticacao (CPF → JWT) |
| [postech-sw-arch-p3-infra-k8s](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-infra-k8s) | Infraestrutura Kubernetes (Terraform) |
| [postech-sw-arch-p3-infra-db](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-infra-db) | Infraestrutura do banco gerenciado (Terraform) |

## Estrutura

```
docs/
  superpowers/
    specs/      # designs aprovados (brainstorming → spec)
    plans/      # planos de implementacao (writing-plans)
    research/   # fichamentos dos modulos da fase 3
  runbooks/     # passo a passo operacionais (AWS Academy, deploy, refresh de credenciais)
```

Ponto de partida: [`docs/superpowers/specs/2026-07-11-fase-3-bootstrap-design.md`](docs/superpowers/specs/2026-07-11-fase-3-bootstrap-design.md).

## Processo

Mesmo framework das fases anteriores: superpowers (brainstorming → spec → plan → execucao) com revisao canonica de `postech-ai-helper/ai/canonical/`. Regras de agente: `postech-ai-helper/ai/agent-bootstrap.md`.
