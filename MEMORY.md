# Project Memory -- postech-sw-arch-p3-docs

<!-- last-consolidated: 2026-09-07 -->

Add-only log of project-specific learnings. New entries go to the top of each section. Never edit historical entries -- add a contradicting entry instead.

Updated by AI agents at task end per `postech-ai-helper/ai/canonical/task-end-review.md`. The `last-consolidated` marker above is updated only when `/consolidate-memory` runs, not on every append.

## Recent decisions

- 2026-09-07 - O ciclo AWS usa credenciais `default` em `us-east-1` e segue RDS → EKS/subnets privadas → app/NLB interno → Lambda/Gateway/VPC Link; o listener TCP 8000 alimenta `TF_VAR_APP_LISTENER_ARN`, a validacao externa usa apenas o API Gateway HTTPS e a desmontagem ocorre na ordem inversa ao final da gravacao

## Discovered conventions

## Gotchas

## Tech debt / TODO

## Review lessons
