# Desbloqueio 2 — Validação do CI/CD quando a cota do Actions renovar

> **Para o agente executor** (modelo simples): steps na ordem, comando exato, resultado esperado, regra de parada. Independente do Desbloqueio 1 (não precisa de AWS) — os jobs de deploy ficam no-op verde sem secrets AWS, por design.

**Pré-requisito humano**: cota de GitHub Actions da org renovada (conferir em Settings → Billing, ou simplesmente ver se um run novo sai de "queued").

### Task 1: Disparar CI nos 4 repos

Para cada repo em `postech-sw-arch-p3 postech-sw-arch-p3-lambda postech-sw-arch-p3-infra-k8s postech-sw-arch-p3-infra-db`:

- [ ] `gh workflow run ci.yml -R fiap-postech-sw-architecture/<repo> --ref main` (se o ci.yml não tiver `workflow_dispatch`, criar branch `ci/smoke-cota` com commit vazio `git commit --allow-empty` e abrir PR — o push dispara).
- [ ] `gh run list -R fiap-postech-sw-architecture/<repo> --limit 3` → aguardar conclusão (`gh run watch`).
- [ ] Verde → próximo repo. Vermelho → `gh run view <id> --log-failed`, diagnosticar:
  - Falha de ambiente do runner (apt/setup/action version) → fix pontual no workflow, commit, re-run. São permitidos ATÉ 2 ciclos de fix por repo; mais que isso = PARE e reporte.
  - Falha de teste/lint que passa localmente → PARE e reporte o log (diferença de ambiente é decisão humana).

### Task 2: CD do p3 (job kind — roda sem AWS)

- [ ] Push vazio na `homolog` do p3 (`git commit --allow-empty -m "ci: smoke da cota" && git push origin homolog`) → cd.yml roda: jobs `image` + `deploy` (kind no runner) verdes; job `deploy-eks` termina com o notice "pulado — secrets AWS ausentes" (comportamento correto, NÃO é falha).
- [ ] Conferir no summary que a imagem foi publicada no GHCR.

### Task 3: Claude workflows (p3)

- [ ] Verificar que `claude-code-review.yml`/`claude-on-demand.yml` têm o secret `ANTHROPIC_API_KEY` configurado (`gh secret list -R ...p3`). Ausente → reportar ao usuário (secret é dele), não é bloqueio.

### Task 4: Registro

- [ ] Atualizar `docs/runbooks/proximas-etapas.md` (este repo): pendência "cota Actions" → resolvida, com data e links dos runs verdes.
- [ ] MEMORY.md do p3: entrada com o resultado (runs verdes + qualquer fix de workflow que foi preciso).
- [ ] Commit + push (este repo e o que tiver fix de workflow).
