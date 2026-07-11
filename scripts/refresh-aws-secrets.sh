#!/usr/bin/env bash
# Regrava os secrets AWS Academy nos 4 repos da fase 3.
# As credenciais do Learner Lab expiram a cada sessao (~4h) — rode este
# script depois de cada Start Lab, com o perfil `academy` ja atualizado
# em ~/.aws/credentials (runbook: docs/runbooks/aws-academy-setup.md).
set -euo pipefail

PROFILE="${AWS_PROFILE:-academy}"
REGION="${AWS_REGION:-us-east-1}"
ORG="fiap-postech-sw-architecture"
REPOS=(postech-sw-arch-p3 postech-sw-arch-p3-lambda postech-sw-arch-p3-infra-k8s postech-sw-arch-p3-infra-db)

AK="$(aws configure get aws_access_key_id --profile "$PROFILE")"
SK="$(aws configure get aws_secret_access_key --profile "$PROFILE")"
ST="$(aws configure get aws_session_token --profile "$PROFILE")"

[ -n "$AK" ] && [ -n "$SK" ] && [ -n "$ST" ] || {
  echo "ERRO: perfil '$PROFILE' incompleto em ~/.aws/credentials (precisa de key, secret e session token)." >&2
  exit 1
}

aws sts get-caller-identity --profile "$PROFILE" >/dev/null || {
  echo "ERRO: credenciais do perfil '$PROFILE' invalidas/expiradas — refaca o Start Lab." >&2
  exit 1
}

for repo in "${REPOS[@]}"; do
  echo ">> $ORG/$repo"
  gh secret set AWS_ACCESS_KEY_ID -R "$ORG/$repo" --body "$AK"
  gh secret set AWS_SECRET_ACCESS_KEY -R "$ORG/$repo" --body "$SK"
  gh secret set AWS_SESSION_TOKEN -R "$ORG/$repo" --body "$ST"
  gh secret set AWS_REGION -R "$ORG/$repo" --body "$REGION"
done
echo ">> secrets atualizados nos ${#REPOS[@]} repos. Validade: ate o fim da sessao do lab."
