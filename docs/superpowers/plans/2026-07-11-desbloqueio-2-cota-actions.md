# Desbloqueio 2 — Validação do CI/CD quando a cota do Actions renovar

> **Para o agente executor** (modelo simples): steps na ordem, comando exato, resultado esperado, regra de parada. Independente do Desbloqueio 1 (não precisa de AWS) — os jobs de deploy ficam no-op verde sem secrets AWS, por design.

**Pré-requisito humano**: cota de GitHub Actions da org renovada (conferir em Settings → Billing, ou simplesmente ver se um run novo sai de "queued").

> **Executado em 01/08/2026** (registro fechado em 03/09/2026). As falhas de julho eram de billing ("The job was not started because recent account payments have failed or your spending limit needs to be increased"), não de código. Desde 03/09/2026 os repos são públicos (minutos ilimitados).

### Task 1: Disparar CI nos 4 repos

Para cada repo em `postech-sw-arch-p3 postech-sw-arch-p3-lambda postech-sw-arch-p3-infra-k8s postech-sw-arch-p3-infra-db`:

- [x] `gh workflow run ci.yml -R fiap-postech-sw-architecture/<repo> --ref main` (`workflow_dispatch` adicionado aos 4 repos em 2026-07-11; fallback: commit vazio + push): runs verdes em [lambda](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-lambda/actions/runs/30706272676), [infra-k8s](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-infra-k8s/actions/runs/30706274897), [infra-db](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-infra-db/actions/runs/30706273765); no `p3` o push na `main` disparou [CI](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3/actions/runs/30712167211), [Security](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3/actions/runs/30712167219) e [full-test](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3/actions/runs/30712167236).
- [x] `gh run list -R fiap-postech-sw-architecture/<repo> --limit 3` → aguardar conclusão (`gh run watch`).
- [x] Verde → próximo repo. Vermelho → `gh run view <id> --log-failed`, diagnosticar (não foi preciso em 01/08; em 03/09 o Security do `p3` precisou do [PR #14](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3/pull/14), pip da imagem base):
  - Falha de ambiente do runner (apt/setup/action version) → fix pontual no workflow, commit, re-run. São permitidos ATÉ 2 ciclos de fix por repo; mais que isso = PARE e reporte.
  - Falha de teste/lint que passa localmente → PARE e reporte o log (diferença de ambiente é decisão humana).

### Task 2: CD do p3 (job kind — roda sem AWS)

- [x] Push na `homolog` do p3 → cd.yml roda: jobs `image` + `deploy` (kind no runner) verdes; job `deploy-eks` termina com o notice "pulado — secrets AWS ausentes" (comportamento correto, NÃO é falha): [CD homolog](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3/actions/runs/30713618605) e [CD main](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3/actions/runs/30712167204).
- [x] Conferir no summary que a imagem foi publicada no GHCR: pacotes `postech-sw-arch-p3-app` e `postech-sw-arch-p3-ui` existem na org desde 01/08/2026 (visibilidade privada).

### Task 3: Claude workflows (p3)

- [x] Verificar que `claude-code-review.yml`/`claude-on-demand.yml` têm o secret configurado: ausente; `claude-code-review.yml` foi removido em 01/08/2026 por decisão do usuário e `claude-on-demand.yml` ficou (só dispara manual/comentário). Não é bloqueio.

### Task 4: Registro

- [x] Atualizar `docs/runbooks/proximas-etapas.md` (este repo): pendência "cota Actions" → resolvida, com data e links dos runs verdes (03/09/2026).
- [x] MEMORY.md do p3: entrada com o resultado (runs verdes + fix do Security no PR #14), 03/09/2026.
- [x] Commit + push (este repo e o que tiver fix de workflow).
