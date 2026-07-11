# Desbloqueio 3 — Entrega final (vídeo, PDF, submissão)

> **Para o agente executor** (modelo simples onde marcado; passos de vídeo/portal são humanos): steps na ordem. Pré-requisitos: Desbloqueio 1 executado (ou ambiente local pronto para demo em kind como fallback), documento de entrega em `postech-sw-arch-p3/docs/entrega/fase3/` já revisado.

### Task 1: Colaborador e acesso (humano + agente)

- [ ] Usuário roda `local/postech-bootstrap/scripts/grant-access.sh` (ou agente via gh se autorizado): `soat-architecture` como colaborador de leitura nos 4 repos + p3-docs.
- [ ] Agente confere: `gh api repos/fiap-postech-sw-architecture/<repo>/collaborators --jq '.[].login'` contém `soat-architecture` nos 4.

### Task 2: Collection da API (agente)

- [ ] No p3 com o app rodando (`make up`): exportar OpenAPI (`curl localhost:8000/openapi.json > docs/entrega/fase3/openapi-fase3.json`).
- [ ] Gerar/atualizar collection Postman a partir do OpenAPI + rota `/auth` da lambda (adicionar manualmente ao JSON da collection); salvar em `docs/entrega/fase3/`.
- [ ] Substituir os placeholders de Swagger/Postman nos READMEs (p3 e lambda) por links reais para esses arquivos.

### Task 3: Roteiro do vídeo (agente escreve; humano grava, ≤15 min)

- [ ] Escrever `docs/entrega/fase3/roteiro-video.md` no p3 cobrindo, NESTA ordem (exigências do challenge): (1) autenticação com CPF (POST /auth no gateway — AWS se Desbloqueio 1 ativo, senão SAM local + app kind); (2) pipeline CI/CD executando (run verde do Desbloqueio 2; senão `make cd-local` como espelho documentado); (3) deploy automatizado (job deploy/deploy-eks); (4) consumo das APIs protegidas com o token; (5) dashboard Grafana ao vivo (volume OS, tempo por status, latência, CPU/mem — gerar carga com `make seed-demo` + loop de requests); (6) logs estruturados no Loki filtrados por request_id + trace no Jaeger.
- [ ] Cada bloco do roteiro: comando exato a digitar + o que falar (1-2 frases) + tempo alvo. Total ≤ 13 min (margem).
- [ ] Humano grava, sobe no YouTube/Vimeo (não listado), fornece o link.

### Task 4: PDF de submissão (agente — skill entrega-tech-challenge)

- [ ] Preencher o link do vídeo no documento de entrega (`VIDEO-LINK-FASE-3`).
- [ ] Gerar o PDF com o pipeline do repo (`scripts/build-entrega-pdf.sh`, adaptado à fase 3 se ainda não foi) — capa ABNT, links absolutos, mermaid renderizado, sem seção de pendências internas.
- [ ] Checklist final do PDF: links dos 4 repos abrem; link do vídeo abre em janela anônima; confirmação do soat-architecture presente; justificativa "deploys ativos: n/a (Academy efêmero)" presente.

### Task 5: Branch protection (decisão humana registrada)

- [ ] Perguntar ao usuário qual mitigação executar (adendo do ADR-033): (a) manter convenção de PR documentada (nada a fazer); (b) upgrade da org para Team → aí ativar proteção nos 4 repos via `gh api`; (c) tornar repos públicos na entrega → aí ativar proteção (grátis em público).
- [ ] Executar a escolhida e registrar no MEMORY.md do p3.

### Task 6: Submissão (humano)

- [ ] Portal do aluno: upload do PDF único. Guardar comprovante.
- [ ] Pós-entrega: `terraform destroy` se algo ficou de pé (budget) e End Lab.
