# Fase 3 — Próximas etapas e pendências

Estado consolidado após o bootstrap e a super-revisão de 2026-07-11 (5 repos revisados: canônico deep + ponytail + transversal; pacote de entrega escrito e revisado; todos os testes locais sem AWS verdes, incluindo full-test E2E). Ordem recomendada de retomada.

> Atualização de 07/09/2026. O deploy automático completo foi executado em `us-east-1`: RDS, EKS, aplicação, Lambda e API Gateway estão operacionais. Os 5 repositórios são públicos e o acesso de leitura de `soat-architecture` foi confirmado. A proteção da `main` não está ativa: a conta operacional `Gryog` possui `write`, mas não `admin`; o fluxo por PR e checks foi mantido como mitigação. Os planos abaixo ficam como referência histórica.

## O que já está pronto (tudo verde localmente)

| Repo | Estado |
|---|---|
| [postech-sw-arch-p3](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3) | API, relay, UI e observabilidade no EKS; imagens por SHA; NLB interno; [CD de produção verde](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3/actions/runs/34178566291) |
| [postech-sw-arch-p3-lambda](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-lambda) | CPF→JWT, authorizer, API Gateway e VPC Link; `POST /auth` = 200, rota protegida = 200 e sem token = 401; [CD verde](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-lambda/actions/runs/34179043515) |
| [postech-sw-arch-p3-infra-k8s](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-infra-k8s) | EKS 1.34 `ACTIVE`, node group `ACTIVE` com 2 nodes; state remoto versionado; [CD verde](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-infra-k8s/actions/runs/34178105568) |
| [postech-sw-arch-p3-infra-db](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-infra-db) | RDS PostgreSQL 16.13 privado e `available`; state remoto versionado; [CD verde](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-infra-db/actions/runs/34177626665) |
| [postech-sw-arch-p3-docs](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-docs) | Spec, planos (fases 0-3 e 4-5), 4 fichamentos, runbooks |

## Pendências humanas e desbloqueios

1. ~~Ativar AWS Academy~~: concluído; credenciais `default` e região `us-east-1` validadas. Passo a passo de renovação e deploy: [aws-academy-setup.md](aws-academy-setup.md).
2. ~~Cota GitHub Actions~~: resolvida em 01/08/2026. Evidências: [CI](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3/actions/runs/30712167211), [Security](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3/actions/runs/30712167219), [CD main](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3/actions/runs/30712167204), [CD homolog](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3/actions/runs/30713618605) e [full-test](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3/actions/runs/30712167236) do `p3`; CI de [lambda](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-lambda/actions/runs/30706272676), [infra-k8s](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-infra-k8s/actions/runs/30706274897) e [infra-db](https://github.com/fiap-postech-sw-architecture/postech-sw-arch-p3-infra-db/actions/runs/30706273765). Repositórios públicos desde 03/09/2026.
3. ~~Colaborador `soat-architecture`~~: confirmado com acesso de leitura nos 5 repositórios.
4. Proteção da `main`: requer uma conta com permissão `admin`; até lá, PR, checks verdes e aprovação manual são obrigatórios por convenção.
5. Vídeo de até 15 minutos e submissão do PDF: infraestrutura e evidências técnicas já estão prontas.

## Próximas etapas técnicas

**Ponto de entrada para retomar: [plano orquestrador](../superpowers/plans/2026-07-11-orquestrador-desbloqueio.md)** — sequencia os 3 planos de desbloqueio (AWS, cota Actions, entrega final) com gates; escrito para ser executado por um modelo simples. Plano de contexto: [fases 4-5](../superpowers/plans/2026-07-11-fase-3-fases-4-5-plan.md).

1. Ondas 1-3 concluídas: aplicação, observabilidade e integração privada entre API Gateway e EKS estão implementadas.
2. Onda 4 concluída: os quatro merges na `main` acionaram os deploys automáticos; o smoke fim a fim confirmou autenticação e autorização em produção.
3. Onda 5: falta ativar a proteção técnica da `main`, gravar o vídeo, regenerar o PDF final e submeter.

## Riscos monitorados

- O token GitHub operacional não possui `admin`; a proteção técnica da `main` depende de um administrador da organização.
- Credenciais do lab expiram a cada ~4h — secrets de CI precisam re-gravação por sessão (`aws-academy-setup.md` §5).
- Budget Academy: EKS, RDS, NLB e VPC Link permanecem ligados até a gravação, por no máximo sete dias; depois devem ser desmontados na ordem inversa.
