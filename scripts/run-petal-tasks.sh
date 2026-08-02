#!/bin/bash
# Executa em sequencia as tasks pendentes do grafico de petalas via `claude -p /executar-task`.
# Le o estado em tasks.md (checkboxes), entao pode ser interrompido e retomado a qualquer momento.
# Se a sessao de 5h do Claude esgotar, espera o reset e continua de onde parou.
#
# Reinicio automatico: instale o LaunchAgent (scripts/install-petal-launchd.sh) e o launchd
# relanca este script sempre que ele sair com codigo != 0 (limite de espera estourado, crash,
# reboot da maquina). Saidas com codigo 0 (tudo concluido, HALT presente, instancia duplicada)
# nao sao relancadas. Falhas reais de task criam o arquivo HALT para nao reexecutar em loop
# uma task quebrada — remova o arquivo para retomar.

set -u

ORCH_DIR="/Volumes/SSD480GB/projects/claude-agents-orchestrator"
FRONTEND_DIR="/Volumes/SSD480GB/projects/controlai-frontend"
BACKEND_DIR="/Volumes/SSD480GB/projects/controlai"
LOG_DIR="$ORCH_DIR/scripts/logs"

# Ordem importa: a task 7 de "categoria" depende do PetalDistributionChart completo.
PRDS=(
  "prd-grafico-petalas-distribuicao"
  "prd-grafico-petalas-categoria"
)

# Flags passadas ao claude. Sem permissao automatica o modo -p trava/nega prompts,
# entao para rodar sem supervisao o skip e necessario. Sobrescreva com CLAUDE_FLAGS.
CLAUDE_FLAGS="${CLAUDE_FLAGS:---dangerously-skip-permissions}"
MAX_RETRIES_PER_TASK="${MAX_RETRIES_PER_TASK:-2}"
PROBE_INTERVAL_SECS="${PROBE_INTERVAL_SECS:-900}"   # 15 min entre sondagens quando a sessao esgota
MAX_WAIT_SECS=$((6 * 3600))                          # desiste de esperar apos 6h

HALT_FILE="$LOG_DIR/HALT"
PID_FILE="$LOG_DIR/petal-tasks.pid"

mkdir -p "$LOG_DIR"
cd "$ORCH_DIR" || exit 1

log() { printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"; }

# Falha que nao deve ser reexecutada automaticamente: cria o HALT e sai.
# O launchd ate relanca (exit != 0), mas a nova instancia ve o HALT e sai com 0.
halt() {
  log "$*"
  log "Criando $HALT_FILE para bloquear reinicio automatico. Remova o arquivo para retomar."
  touch "$HALT_FILE"
  exit 1
}

if [ -f "$HALT_FILE" ]; then
  log "Arquivo HALT presente ($HALT_FILE): execucao pausada apos falha anterior. Remova-o para retomar."
  exit 0
fi

# Garante instancia unica (launchd + execucao manual ao mesmo tempo)
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE" 2>/dev/null)" 2>/dev/null; then
  log "Ja existe uma instancia rodando (pid $(cat "$PID_FILE")). Saindo."
  exit 0
fi
echo $$ >"$PID_FILE"
trap 'rm -f "$PID_FILE"' EXIT

# Detecta no output se a sessao/limite de uso esgotou.
# Formato atual do CLI: "You've hit your session limit · resets 11:30pm (America/Sao_Paulo)"
hit_usage_limit() {
  grep -qiE 'usage limit|session limit|limit reached|rate.?limit|hour limit|hit your .* limit' "$1"
}

# Alguns formatos trazem o epoch do reset: "Claude AI usage limit reached|1712345678"
extract_reset_epoch() {
  grep -oE 'limit reached\|[0-9]{10}' "$1" | grep -oE '[0-9]{10}' | head -1
}

wait_for_session_reset() {
  local logfile="$1"
  local reset_epoch
  reset_epoch="$(extract_reset_epoch "$logfile" || true)"

  if [ -n "${reset_epoch:-}" ]; then
    local now wait_secs
    now=$(date +%s)
    wait_secs=$((reset_epoch - now + 120))   # 2 min de folga
    if [ "$wait_secs" -gt 0 ] && [ "$wait_secs" -le "$MAX_WAIT_SECS" ]; then
      log "Sessao esgotada. Reset em $(date -r "$reset_epoch" '+%H:%M:%S'). Aguardando ${wait_secs}s..."
      sleep "$wait_secs"
      return 0
    fi
  fi

  # Sem timestamp no output: sonda a cada PROBE_INTERVAL_SECS com uma chamada minima
  log "Sessao esgotada (sem horario de reset no output). Sondando a cada $((PROBE_INTERVAL_SECS / 60)) min..."
  local waited=0
  while [ "$waited" -lt "$MAX_WAIT_SECS" ]; do
    sleep "$PROBE_INTERVAL_SECS"
    waited=$((waited + PROBE_INTERVAL_SECS))
    local probe_out="$LOG_DIR/probe.log"
    if claude -p "Responda apenas OK" --model haiku >"$probe_out" 2>&1 && ! hit_usage_limit "$probe_out"; then
      log "Sessao liberada apos $((waited / 60)) min de espera."
      return 0
    fi
    log "Ainda limitado ($((waited / 60)) min de espera)..."
  done
  # Sai com codigo != 0 sem criar HALT: o launchd relanca e o script volta a sondar.
  log "Sessao nao liberou apos $((MAX_WAIT_SECS / 3600))h. Saindo para o launchd relancar."
  exit 75
}

# Lista os numeros das tasks nao concluidas ("- [ ] N.0 ...") de um tasks.md, em ordem
pending_tasks() {
  sed -nE 's/^- \[ \] ([0-9]+)\.0.*/\1/p' "$ORCH_DIR/tasks/$1/tasks.md"
}

task_done() {
  grep -qE "^- \[x\] $2\.0" "$ORCH_DIR/tasks/$1/tasks.md"
}

run_task() {
  local prd="$1" num="$2"
  local task_file="tasks/$prd/${num}_task.md"
  local attempt=0

  if [ ! -f "$ORCH_DIR/$task_file" ]; then
    halt "ERRO: $task_file nao existe."
  fi

  while true; do
    attempt=$((attempt + 1))
    local logfile="$LOG_DIR/${prd}_${num}_$(date '+%Y%m%d-%H%M%S').log"
    log ">>> Executando $prd task $num (tentativa $attempt) — log: $logfile"

    claude -p "/executar-task $task_file" \
      $CLAUDE_FLAGS \
      --add-dir "$FRONTEND_DIR" \
      --add-dir "$BACKEND_DIR" \
      >"$logfile" 2>&1
    local exit_code=$?

    if hit_usage_limit "$logfile"; then
      wait_for_session_reset "$logfile"
      log "Retomando $prd task $num apos reset da sessao."
      attempt=$((attempt - 1))   # espera por limite nao conta como tentativa
      continue
    fi

    if task_done "$prd" "$num"; then
      log "OK: $prd task $num concluida (marcada em tasks.md)."
      return 0
    fi

    log "AVISO: $prd task $num terminou (exit $exit_code) mas nao foi marcada como [x] em tasks.md."
    if [ "$attempt" -gt "$MAX_RETRIES_PER_TASK" ]; then
      halt "ERRO: $prd task $num falhou apos $attempt tentativas. Veja $logfile."
    fi
    log "Tentando novamente..."
  done
}

log "=== Iniciando execucao das tasks do grafico de petalas ==="
for prd in "${PRDS[@]}"; do
  # Reavalia o tasks.md a cada iteracao: e ele quem diz onde paramos
  while true; do
    next="$(pending_tasks "$prd" | head -1)"
    [ -z "$next" ] && break
    run_task "$prd" "$next"
  done
  log "PRD $prd: todas as tasks concluidas."
done
log "=== Todas as tasks do grafico de petalas foram concluidas. ==="
