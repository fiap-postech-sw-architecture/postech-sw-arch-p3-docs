# Project Memory -- postech-sw-arch-p3-docs

<!-- last-consolidated: 2026-09-07 -->

Add-only log of project-specific learnings. New entries go to the top of each section. Never edit historical entries -- add a contradicting entry instead.

Updated by AI agents at task end per `postech-ai-helper/ai/canonical/task-end-review.md`. The `last-consolidated` marker above is updated only when `/consolidate-memory` runs, not on every append.

## Recent decisions

- 2026-09-08 - O deploy manual distingue reaplicacao do ambiente existente, que rotaciona somente credenciais AWS, de provisionamento limpo, que gera segredos estaveis e respeita a ordem RDS → EKS → app/NLB → Lambda/Gateway
- 2026-09-07 - Deploy automatico de producao validado pelos merges RDS → EKS → app → Lambda; runs 34177626665, 34178105568, 34178566291 e 34179043515 ficaram verdes e o smoke externo confirmou auth 200, rota protegida 200 e ausência de token 401
- 2026-09-07 - O ciclo AWS usa credenciais `default` em `us-east-1` e segue RDS → EKS/subnets privadas → app/NLB interno → Lambda/Gateway/VPC Link; o listener TCP 8000 alimenta `TF_VAR_APP_LISTENER_ARN`, a validacao externa usa apenas o API Gateway HTTPS e a desmontagem ocorre na ordem inversa ao final da gravacao

## Discovered conventions

## Gotchas

- 2026-09-09 - A entrada de 2026-09-07 abaixo tirou a conclusao errada: a protecao da `main` ESTA ativa nos 5 repos desde 2026-09-03 (verificada com conta admin). `GET/PUT .../branches/main/protection` retornam 404 para quem tem so `write` mesmo com protecao ativa; `GET /repos/{o}/{r}/branches/main` expoe `.protected` a qualquer leitor. Convites de leitura para `soat-architecture` enviados nos 5 repos em 2026-09-09 (antes nao havia convite nem colaboracao; 'acesso confirmado' era so a visibilidade publica).
- 2026-09-08 - Os backends Terraform atuais fixam o bucket da conta 924563550535, portanto credenciais de outra conta Academy nao bastam para o deploy; sobre RDS preservado, regenerar a chave de criptografia tambem quebra a leitura dos dados existentes
- 2026-09-07 - Repos publicos nao bastam para configurar branch protection: o token precisa de permissao `admin`; a conta `Gryog` tem apenas `write` nos cinco repos e os endpoints de protection/rulesets retornam 404

## Tech debt / TODO

## Review lessons
