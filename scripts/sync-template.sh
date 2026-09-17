#!/usr/bin/env bash
# sync-template.sh — propaga el conocimiento común de GdesProject/template/ a los subrepos.
#
# Uso:
#   scripts/sync-template.sh push [repo ...]   # copia template → subrepos (los SYNCED del template GANAN)
#   scripts/sync-template.sh --check           # reporta deriva sin tocar nada (exit 1 si hay deriva)
#
# NUNCA toca: feature_list.json, progress/, docs/tasks/ (salvo TEMPLATE.md),
# docs/changes_proposals/*.md (solo el README es SYNCED), ni docs locales del subrepo.

set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$(pwd)"

declare -A REPOS=(
  [mobile]=mobile_app_gdes
  [admin]=admin_web_app
  [backend]=backend_api_gdes
)

MODE="${1:---check}"
if [[ "$MODE" != "push" && "$MODE" != "--check" ]]; then
  echo "Uso: $0 push [app ...] | --check" >&2
  exit 2
fi
shift || true
APPS=("$@")
[[ ${#APPS[@]} -eq 0 ]] && APPS=(mobile admin backend)

drift=0

sync_file() { # $1 src (abs), $2 dst (abs)
  if [[ ! -f "$2" ]] || ! cmp -s "$1" "$2"; then
    if [[ "$MODE" == "push" ]]; then
      mkdir -p "$(dirname "$2")"
      cp "$1" "$2"
      echo "synced: ${2#$ROOT/}"
    else
      echo "DRIFT: ${2#$ROOT/}"
      drift=1
    fi
  fi
}

for app in "${APPS[@]}"; do
  repo="${REPOS[$app]:?app desconocida: $app}"
  [[ -d "$repo" ]] || { echo "AVISO: $repo no existe, se omite"; continue; }

  # leader.md con placeholders resueltos
  tmp="$(mktemp)"
  sed -e "s/{{IMPLEMENTER}}/implementer-$app/g" -e "s/{{APP}}/$repo/g" \
    template/common/.agents/agents/leader.md > "$tmp"
  sync_file "$tmp" "$ROOT/$repo/.agents/agents/leader.md"
  rm -f "$tmp"

  # resto de archivos comunes
  while IFS= read -r -d '' f; do
    rel="${f#template/common/}"
    [[ "$rel" == ".agents/agents/leader.md" ]] && continue
    sync_file "$ROOT/$f" "$ROOT/$repo/$rel"
  done < <(find template/common -type f -print0)

  # implementer propio del app
  while IFS= read -r -d '' f; do
    rel="${f#template/apps/$app/}"
    sync_file "$ROOT/$f" "$ROOT/$repo/$rel"
  done < <(find "template/apps/$app" -type f -print0)

  # asegurar dirs de trabajo local (no se pisan)
  if [[ "$MODE" == "push" ]]; then
    mkdir -p "$repo/progress/leader/inbox" "$repo/progress/implementer" "$repo/progress/reviewer" "$repo/docs/changes_proposals"
  fi
done

if [[ "$MODE" == "--check" ]]; then
  [[ $drift -eq 0 ]] && echo "OK: todos los repos están sincronizados" || { echo "Hay deriva: corré '$0 push'"; exit 1; }
fi
