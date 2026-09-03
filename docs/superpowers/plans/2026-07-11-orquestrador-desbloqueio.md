# Orquestrador — Fechamento da Fase 3 (goal final pós-desbloqueio)

> **Para o agente executor** (modelo simples): este é o plano-mestre. Execute os três planos de desbloqueio como sub-planos, na ordem e com os gates abaixo. NUNCA pule um gate. Ao retomar uma sessão, releia este arquivo e os checkboxes dos sub-planos para saber onde parou.

## Estado de entrada (o que já está pronto — não refazer)

- 5 repos completos e revisados (revisão canônica deep + ponytail + transversal, 2026-07-11); gates locais verdes: p3 `make check` (1834 testes, 96.34%) + test-integ (162), lambda 100% cobertura + tf-validate, infra fmt+validate.
- Documento de entrega em `postech-sw-arch-p3/docs/entrega/fase3/` (revisado; placeholders: link do vídeo, evidências AWS).
- Runbook AWS Academy + script `scripts/refresh-aws-secrets.sh` neste repo.

## Sequência e gates

```
[G0] usuário ativou AWS Academy?
 ├─ sim → Desbloqueio 1 (deploy AWS)  ──[G1: smoke fim-a-fim ok]──┐
 └─ não → aguardar (Desbloqueio 2 pode rodar antes, se cota ok)   │
[G2] cota Actions renovada? → Desbloqueio 2 (CI/CD verde)  ───────┤
                                                                  ▼
                                    Desbloqueio 3 (vídeo + PDF + submissão)
```

1. **Desbloqueio 1** — [2026-07-11-desbloqueio-1-aws-deploy.md](2026-07-11-desbloqueio-1-aws-deploy.md). Gate G1: `curl` do gateway devolve JWT e rota protegida responde 200 com token. Falha de hipótese do Learner Lab (IAM/EKS/addon) = parar e reportar — decisão humana antes de qualquer workaround.
2. **Desbloqueio 2** — [2026-07-11-desbloqueio-2-cota-actions.md](2026-07-11-desbloqueio-2-cota-actions.md). Gate G2: CI verde nos 4 repos + CD kind verde no p3. G2 satisfeito em 01/08/2026 (registro em 03/09/2026). Pode rodar antes/depois/em paralelo ao Desbloqueio 1 (não compartilham estado), mas o vídeo (Desbloqueio 3) idealmente mostra os dois.
3. **Desbloqueio 3** — [2026-07-11-desbloqueio-3-entrega-final.md](2026-07-11-desbloqueio-3-entrega-final.md). Só inicia com G1 OU o fallback local decidido pelo usuário (demo em kind + SAM, prevista no roteiro), E com o documento de entrega sem placeholders além do link do vídeo.

## Regras permanentes do executor

- Gate local antes de QUALQUER push: `make check`/`make gate` do repo tocado. Cota do Actions não substitui o gate local.
- Sem `gh pr merge --auto`; merges só com tudo verde e dentro do que os planos autorizam.
- Segredos: nunca em git; fluxo = runbook §3-§5 + `refresh-aws-secrets.sh`. Credenciais expiram ~4h — re-rodar o script a cada Start Lab.
- Budget: ao final de qualquer sessão de AWS sem gravação iminente, `terraform destroy` na ordem inversa (lambda → infra-k8s → infra-db) e End Lab.
- Qualquer desvio do esperado: parar, reportar com a mensagem exata, aguardar humano. Não improvisar em infra paga.
- Ao concluir cada task: marcar checkbox no sub-plano, commit no repo correspondente (mensagem `docs(plans): progresso ...` neste repo).

## Critério de conclusão do goal

PDF submetido no portal + comprovante guardado + recursos AWS destruídos + MEMORY.md do p3 com o registro final da fase.
