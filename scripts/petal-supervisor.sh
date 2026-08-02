#!/bin/bash
# Supervisor do run-petal-tasks.sh: relanca o script sempre que ele sair com erro
# (limite de sessao alem do teto de espera, crash) ate que ele saia com 0
# (tudo concluido ou HALT presente).
#
# Por que nao launchd: processos spawnados pelo launchd sao barrados pelo TCC ao
# acessar /Volumes/SSD480GB ("Operation not permitted"). Este supervisor deve ser
# iniciado de uma sessao de usuario (Terminal/Claude Code), que ja tem o acesso,
# via: nohup scripts/petal-supervisor.sh >/dev/null 2>&1 &
# Sobrevive ao fechamento do terminal, mas nao a um reboot.

set -u

ORCH_DIR="/Volumes/SSD480GB/projects/claude-agents-orchestrator"
LOG_DIR="$ORCH_DIR/scripts/logs"
SUP_LOG="$LOG_DIR/supervisor.log"
SUP_PID_FILE="$LOG_DIR/petal-supervisor.pid"
RESTART_DELAY_SECS="${RESTART_DELAY_SECS:-300}"

mkdir -p "$LOG_DIR"

log() { printf '[%s] [supervisor] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$SUP_LOG"; }

# Instancia unica do supervisor
if [ -f "$SUP_PID_FILE" ] && kill -0 "$(cat "$SUP_PID_FILE" 2>/dev/null)" 2>/dev/null; then
  echo "Supervisor ja esta rodando (pid $(cat "$SUP_PID_FILE"))."
  exit 0
fi
echo $$ >"$SUP_PID_FILE"
trap 'rm -f "$SUP_PID_FILE"' EXIT

log "=== Supervisor iniciado (pid $$) ==="
while true; do
  bash "$ORCH_DIR/scripts/run-petal-tasks.sh" >>"$SUP_LOG" 2>&1
  code=$?
  if [ "$code" -eq 0 ]; then
    # Tudo concluido ou HALT presente: nada mais a fazer
    log "run-petal-tasks.sh saiu com 0. Encerrando supervisor."
    break
  fi
  log "run-petal-tasks.sh saiu com $code. Relancando em ${RESTART_DELAY_SECS}s..."
  sleep "$RESTART_DELAY_SECS"
done
log "=== Supervisor encerrado ==="
