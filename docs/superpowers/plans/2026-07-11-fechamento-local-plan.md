# Fase 3 — Plano de Fechamento Local (gaps de execução × afirmação) — v2 revisado

> **Status**: APROVADO E EXECUTADO em 2026-07-11 — 12/12 gaps fechados com evidência (A1-A8 e B0-B5 concluídos; A7 documentado, pendência humana = PAT). Detalhes das execuções nos commits 1ac2d35 (lambda) e 961b30d (p3). (v2 — revisado por 6 lentes em 2 grupos: staff engineer + staff architect + test engineer; security + devops/SRE + PM/TPM. 2 ALTA + 8 MÉDIA + 6 LOW aplicados; 0 rejeitados).
> Origem: super-revisão de 2026-07-11 — um gap real (demo SAM nunca executada; authorizer local possível) levou a caçada sistemática que achou os 12 gaps do inventário abaixo. Este plano fecha todos os que não exigem AWS.
> **Executor**: sessão atual (Claude). Cada task fecha com evidência de execução real; nada é marcado done por inspeção estática.

**Paths**: workspace `/Users/jbamaral/git/fiap/postech-sw-architecture/`; app = `postech-sw-arch-p3`; lambda = `postech-sw-arch-p3-lambda`. Cluster kind `pytstop` no ar com dados semeados (8 OS; métricas de negócio populadas — verificado ao vivo).

## Inventário auditável: gap → task

| # | Gap (documentado × nunca exercitado) | Task |
|---|---|---|
| 1 | `make build` da lambda quebrado (docopt sdist × `--only-binary :all:`) | A1 |
| 2 | `make sam-local` sem env e sem deps vendorizadas — demo do README não funciona como escrita | A2 (dep: A1) |
| 3 | Premissa "authorizer sem emulação local" falsa (adendos ADR-027/029 já commitados) — falta a rota protegida no template + prova | A3 + B1 |
| 4 | Default `EKS_CLUSTER_NAME` errado no cd.yml (`pytstop` × `pytstop-p3`) | A4 |
| 5 | Roteiro bloco 6: `seed-demo` contra kind → 401 (senha do cluster ≠ default) | A5 |
| 6 | Roteiro bloco 7: e-mail `admin@pytstop.com.br` inexistente → 401 | A5 |
| 7 | `gh workflow run ci.yml` falha nos 4 repos (sem `workflow_dispatch`) | A6 |
| 8 | Imagens GHCR `p3-app`/`p3-ui` não existem — deploy EKS travaria no pull | A7 |
| 9 | RFC-003 §3/entrega §7: paridade desatualizada + "overlay local" inexistente | A8 |
| 10 | Demo integrada fim-a-fim nunca executada (`sam local`, invoke, token no kind) | B1 |
| 11 | Collection Postman nunca executada | B2 |
| 12 | `make dast` e `make codeql-quality` sem evidência na fase 3 | B3 + B4 |

---

## Fase A — Correções

### A1: `make build` da lambda (QUEBRADO) — pré-requisito de A2/B1

- [x] Reproduzir a falha (docopt, dep transitiva brutils→num2words, é sdist-only e colide com `--only-binary :all:`).
- [x] Fix — caminho primário: etapa separada `uv pip install --target build/lambda docopt==0.6.2 --no-deps` (sdist puro-Python, independente de plataforma), mantendo `--only-binary :all:` + wheels `manylinux2014` para o resto (psycopg binário do runtime). Fallback: `--no-binary docopt` se a etapa separada tiver aresta.
- [x] Evidência: zip gerado; `unzip -l`: psycopg binário linux presente, `docopt` presente, sem `__pycache__`.

### A2: `make sam-local` funcional (env + deps) — depende de A1

- [x] `env.json.example` versionado com valores de demo do cluster kind e **`DATABASE_URL` usando `host.docker.internal:15432`** (o SAM roda a function em container — `localhost` seria o próprio container; mesmo padrão do default do template). Nota de rationale "demo only" no README (JSON não aceita comentário; equivalente do `gitleaks:allow` do `k8s/secret.yaml` do app registrado no README — o CI da lambda não roda gitleaks, mas o precedente fica documentado). `env.json` no `.gitignore`.
- [x] `template.yaml`: `CodeUri` da function aponta para `build/lambda` (deps vendorizadas por A1); alvo `sam-local` do Makefile passa a depender de `build` e a passar `--env-vars env.json`.
- [x] Alinhar as 3 cópias do fluxo demo: README da lambda (seção "Demo local integrada": port-forward passa a `15432`, passo `cp env.json.example env.json`) e roteiro do vídeo §2 (mesma porta/env).

### A3: Rota protegida com Lambda authorizer no template SAM

- [x] Recurso explícito `AWS::Serverless::HttpApi` com `Auth` (Lambda authorizer payload v2 simple response, mesma function `authorizer.py`) + rota protegida de exemplo espelhando o Terraform — evento implícito não aceita authorizer.
- [x] `sam validate --lint` verde (a prova de execução é B1).

### A4: Default de cluster errado no `cd.yml` do app

- [x] `vars.EKS_CLUSTER_NAME || 'pytstop'` → `|| 'pytstop-p3'` (fonte: `variables.tf:10` do infra-k8s); comentário citando a fonte.

### A5: Credenciais erradas no roteiro do vídeo (401 ao vivo na gravação)

- [x] Bloco 6: `make seed-demo` contra o kind ganha `ADMIN_PASSWORD=<do Secret pytstop-secrets>` (verificado ao vivo: sem isso, 401; `ADMIN_EMAIL` default já é o certo — citar mesmo assim por clareza).
- [x] Bloco 7: e-mail `admin@pytstop.com.br` → `admin@pytstop.dev`.

### A6: `workflow_dispatch` ausente nos 4 `ci.yml`

- [x] Adicionar `workflow_dispatch:` ao `on:` dos 4 repos (p3, lambda, infra-k8s, infra-db) — o Desbloqueio 2 usa `gh workflow run ci.yml` como caminho primário.

### A7: Imagens GHCR `p3-app`/`p3-ui` não existem

- [x] Desbloqueio 1 (plano) ganha Task 2.5: publicar as imagens manualmente — `docker login ghcr.io -u <user> --password-stdin` (PAT `write:packages` via stdin, nunca em arquivo/histórico) + `docker build`/`push` com o **SHA completo de 40 chars** (o sed do CD usa `GITHUB_SHA` completo). **Pendência humana (dono: usuário): criar o PAT.**
- [x] Alternativa documentada: rodar o Desbloqueio 2 antes (job `image` do CD publica) — com nota: exige `homolog` sincronizada com a `main` no mesmo SHA.

### A8: Docs de paridade desatualizados

- [x] RFC-003 §3: authorizer/rota protegida ganham emulação local (SAM); corrigir "kind (overlay local)" (não existe overlay local — o fluxo kind aplica `k8s/*.yaml`).
- [x] Entrega §7 (subseção paridade): mesma atualização.
- [x] Desbloqueio 2: nota de que `workflow_dispatch` agora existe (fallback de commit vazio permanece).
- [x] Critério de verificação: links/afirmações novas conferidas contra os arquivos alterados em A2/A3.

## Fase B — Testes manuais completos (execução comprovada)

### B0 (novo): Pré-voo de cada bloco B

- [x] (Re)armar port-forwards no início de B1/B2 (`kubectl port-forward` morre em restart de pod; não há alvo Makefile persistente): API `18000:8000`, Postgres `15432:5432`; verificação `GET /api/v1/saude` → 200.

### B1: Demo integrada fim-a-fim (o que nunca rodou) — depende de A1+A2+A3

- [x] `sam local start-api --env-vars env.json` (porta 3000).
- [x] Registrar: `POST /auth` CPF semeado `11144477735` → 200 + token; CPF malformado → 400; CPF válido inexistente → 401.
- [x] Cliente inativo → 401: **criar cliente descartável via POST** (API do kind) e desativá-lo — NÃO tocar nos semeados (não existe reativação; `11144477735` é o cliente do roteiro e da collection). Registrar qual foi. Mutação restrita ao descartável.
- [x] Rota protegida emulada: sem token → 401; com token da lambda → 200 (authorizer local).
- [x] Token da lambda na API do kind com **evidência discriminante** para RN-021: (a) requisição com token da lambda → observar o log do app (motivo = RBAC/papel, não assinatura); (b) contraste com token de assinatura adulterada → motivo = assinatura. Registrar os dois logs. Anotar pendência conhecida (rotas de papel `cliente` = Onda 3/4).
- [x] `sam local invoke AutenticacaoCpfFunction -e events/auth.json` → 200 no evento de exemplo.

### B2: Collection Postman executada

- [x] `npx newman run docs/entrega/fase3/postman-collection-fase3.json` (environment: kind 18000) — fluxos nomeados para o aceite: (1) login interno + refresh; (2) ciclo de OS: criar cliente/veículo → criar OS → diagnóstico → orçamento → aprovação; (3) leitura de catálogo/estoque. Verde ou collection corrigida (ex.: variável de token no flow) e re-rodada.

### B3: `make dast` (ZAP baseline) — pesado

- [x] Sequência EXATA (portas 8000/5432/8080/8025/16686 colidem com o compose do p2; o alvo `dast` NÃO derruba a própria stack ao final): `docker stop` dos containers do p2 (stop, não down — preserva volume, dispensa re-seed) → `make dast` no p3 → `make down` no p3 → `docker start` dos containers do p2 → **verificação pós-restauro**: `GET /api/v1/saude` do p2 (8000) → 200 e login admin ok.
- [x] Evidência: relatório ZAP sem FAIL (padrão fase 2); anexar resultado à entrega §5.1.

### B4: `make codeql-quality` — pesado

- [x] Rodar na HEAD (primeira execução baixa bundle ~1GB — exige rede/disco; ~15min). Evidência: 0 findings de qualidade (ou triagem dos que vierem); citar na entrega §5.1.

### B5: Fecho documental

- [x] Entrega §5.1 (dast/codeql com data) e §7 (paridade) atualizados; roteiro com evidências observadas (não previstas).
- [x] MEMORY do p3 e da lambda: entradas das execuções + gotchas.
- [x] Regenerar o PDF draft; push tudo; sync homolog ×4.
- [x] Critério de verificação: diff das edições revisado contra as evidências registradas nos blocos B.

## Riscos e limites

- B3 derruba temporariamente o ambiente dev do p2 (stop/start com volume preservado + verificação pós-restauro).
- B1 muta o cluster kind (1 cliente descartável criado e desativado — dataset de demo semeado fica intacto).
- B3/B4 são demorados (~15min cada; B4 baixa ~1GB na primeira run).
- A7 fica bloqueado na pendência humana do PAT (ou na cota do Actions).
- Nada aqui toca AWS nem consome budget.

## Critério de conclusão

Os 12 gaps do inventário acima fechados com evidência de execução registrada, OU classificados "requer AWS/cota/PAT" com dono nomeado — auditável linha a linha contra a tabela.
