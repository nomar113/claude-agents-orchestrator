#!/bin/bash
# Instala (ou reinstala) o LaunchAgent que mantem o run-petal-tasks.sh rodando.
# Atencao: ao instalar, o script comeca a executar imediatamente (RunAtLoad).
#
# Uso:
#   scripts/install-petal-launchd.sh            # instala e inicia
#   scripts/install-petal-launchd.sh uninstall  # para e remove

set -euo pipefail

LABEL="com.ramon.petal-tasks"
PLIST_SRC="$(cd "$(dirname "$0")" && pwd)/$LABEL.plist"
PLIST_DST="$HOME/Library/LaunchAgents/$LABEL.plist"
DOMAIN="gui/$(id -u)"

if [ "${1:-}" = "uninstall" ]; then
  launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true
  rm -f "$PLIST_DST"
  echo "LaunchAgent $LABEL removido."
  exit 0
fi

mkdir -p "$HOME/Library/LaunchAgents"
# Reinstala de forma idempotente: remove a versao carregada antes de copiar
launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true
cp "$PLIST_SRC" "$PLIST_DST"
launchctl bootstrap "$DOMAIN" "$PLIST_DST"

echo "LaunchAgent $LABEL instalado e iniciado."
echo "Requer Full Disk Access para /bin/bash (TCC bloqueia acesso ao volume externo sem isso)."
echo "Acompanhe:  tail -f ~/Library/Logs/petal-tasks.out.log"
echo "Status:     launchctl print $DOMAIN/$LABEL | head -20"
echo "Parar:      $0 uninstall"
