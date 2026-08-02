#!/usr/bin/env bash
# run.sh — Executa tasks de uma PRD sequencialmente com Claude Code
#
# Resistente à janela de 5h: salva o session ID de cada task e retoma
# de onde parou em caso de interrupção.
#
# Uso:
#   ./sequential-script/run.sh <task-dir> [opções]
#
# Exemplos:
#   ./sequential-script/run.sh tasks/prd-login-autenticacao/
#   ./sequential-script/run.sh tasks/prd-login-autenticacao/ --repos /Volumes/SSD480GB/projects/controlai,/Volumes/SSD480GB/projects/controlai-frontend
#   ./sequential-script/run.sh tasks/prd-login-autenticacao/ --reset

set -uo pipefail

# ──────────────────────────────────────────────────────────────────────────────
# Argumentos
# ──────────────────────────────────────────────────────────────────────────────

usage() {
    echo ""
    echo "Uso: $0 <task-dir> [--repos dir1,dir2,...] [--reset] [--no-push]"
    echo ""
    echo "  <task-dir>   Pasta da PRD (ex: tasks/prd-login-autenticacao/)"
    echo "               Pode ser prefixado com @ (será ignorado)"
    echo ""
    echo "  --repos      Repos adicionais para commit/push, separados por vírgula."
    echo "               Esses repos também recebem acesso via --add-dir no claude."
    echo ""
    echo "  --reset      Limpa o progresso salvo e recomeça do zero."
    echo ""
    echo "  --no-push    Faz commit mas não executa git push."
    echo ""
    exit 1
}

TASK_DIR=""
EXTRA_REPOS=()
RESET=false
NO_PUSH=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --repos)
            IFS=',' read -ra EXTRA_REPOS <<< "$2"
            shift 2
            ;;
        --reset)
            RESET=true
            shift
            ;;
        --no-push)
            NO_PUSH=true
            shift
            ;;
        --help|-h)
            usage
            ;;
        -*)
            echo "Opção desconhecida: $1"
            usage
            ;;
        *)
            if [[ -z "$TASK_DIR" ]]; then
                TASK_DIR="$1"
            else
                echo "Argumento inesperado: $1"
                usage
            fi
            shift
            ;;
    esac
done

[[ -n "$TASK_DIR" ]] || usage

TASK_DIR="${TASK_DIR#@}"   # Remove prefixo @ se presente
TASK_DIR="${TASK_DIR%/}"   # Remove trailing slash

# ──────────────────────────────────────────────────────────────────────────────
# Configuração
# ──────────────────────────────────────────────────────────────────────────────

# Repo raiz onde o script está sendo executado
MAIN_REPO="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Todos os repos onde checaremos alterações para commit
ALL_REPOS=("${MAIN_REPO}")
for r in "${EXTRA_REPOS[@]+"${EXTRA_REPOS[@]}"}"; do
    ALL_REPOS+=("$r")
done

# Diretório de estado (dentro da pasta da PRD, ignorado pelo .gitignore)
PROGRESS_DIR="${TASK_DIR}/.progress"

# Arquivo de resumo de tasks (fonte autoritativa de tasks concluídas)
TASKS_MD="${TASK_DIR}/tasks.md"

# Timeout por task em segundos (4h 45min — abaixo da janela de 5h do Claude)
TASK_TIMEOUT_SECS=17100

# Detectado em runtime pelo main() — não altere aqui
TIMEOUT_CMD=""

# Prompt enviado ao retomar uma sessão interrompida
RESUME_PROMPT="Continue e complete a task. Retome exatamente de onde parou e execute todos os passos restantes até a conclusão completa, incluindo testes e o task-reviewer."

# ──────────────────────────────────────────────────────────────────────────────
# Logging
# ──────────────────────────────────────────────────────────────────────────────

_ts() { date '+%H:%M:%S'; }
log()  { echo "[$(_ts)] $*"; }
ok()   { echo "[$(_ts)] ✓ $*"; }
warn() { echo "[$(_ts)] ⚠ $*"; }
err()  { echo "[$(_ts)] ✗ $*" >&2; }
sep()  { echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; }

# ──────────────────────────────────────────────────────────────────────────────
# Gerenciamento de estado
# ──────────────────────────────────────────────────────────────────────────────

ensure_progress_dir() { mkdir -p "${PROGRESS_DIR}"; }

# Verifica se a task está marcada como [x] no tasks.md
is_done_in_tasks_md() {
    local task_num="$1"
    [[ -f "${TASKS_MD}" ]] || return 1
    # Linha esperada: - [x] N.0 ... (onde N é o número da task)
    grep -qE "^\- \[x\] ${task_num}\." "${TASKS_MD}"
}

# Considera concluída se marcada no tasks.md OU no arquivo .done local
is_completed() {
    [[ -f "${PROGRESS_DIR}/${1}.done" ]] || is_done_in_tasks_md "${1}"
}

mark_completed() { touch "${PROGRESS_DIR}/${1}.done"; }

save_session() {
    local task_num="$1" session_id="$2"
    echo "${session_id}" > "${PROGRESS_DIR}/${task_num}.session"
}

get_saved_session() {
    local f="${PROGRESS_DIR}/${1}.session"
    [[ -f "$f" ]] && cat "$f" || echo ""
}

clear_session() { rm -f "${PROGRESS_DIR}/${1}.session"; }

reset_progress() {
    rm -rf "${PROGRESS_DIR}"
    ensure_progress_dir
    log "Progresso resetado. Todas as tasks serão re-executadas."
}

# ──────────────────────────────────────────────────────────────────────────────
# Descoberta de tasks
# ──────────────────────────────────────────────────────────────────────────────

find_tasks() {
    # Encontra arquivos N_task.md, exclui reviews (N_task_review.md)
    find "${TASK_DIR}" -maxdepth 1 \
        -name "[0-9]*_task.md" \
        ! -name "*_review*" \
        | sort -V
}

get_task_num() {
    basename "$1" | sed 's/_task\.md$//'
}

get_task_title() {
    grep -m1 '^#' "$1" 2>/dev/null | sed 's/^#\+ *//' || basename "$1"
}

# ──────────────────────────────────────────────────────────────────────────────
# Git — commit e push após cada task
# ──────────────────────────────────────────────────────────────────────────────

commit_and_push() {
    local task_num="$1" task_title="$2"
    local any_committed=false

    for repo in "${ALL_REPOS[@]}"; do
        [[ -d "${repo}/.git" ]] || continue

        local status
        status=$(git -C "${repo}" status --porcelain 2>/dev/null || echo "")

        if [[ -z "$status" ]]; then
            warn "Sem alterações em: ${repo}"
            continue
        fi

        log "Commitando em: ${repo}"
        git -C "${repo}" add -A

        if git -C "${repo}" diff --staged --quiet 2>/dev/null; then
            warn "Nada staged em: ${repo}"
            continue
        fi

        git -C "${repo}" commit -m "task ${task_num}: ${task_title}"

        if $NO_PUSH; then
            ok "Commit feito em: ${repo} (--no-push ativo)"
        else
            git -C "${repo}" push
            ok "Commit + push em: ${repo}"
        fi

        any_committed=true
    done

    if ! $any_committed; then
        warn "Nenhum repo com alterações para commitar (task ${task_num})"
    fi
}

# ──────────────────────────────────────────────────────────────────────────────
# Execução de task via Claude Code
# ──────────────────────────────────────────────────────────────────────────────

# Monta a lista de flags --add-dir para repos extras
build_add_dir_flags() {
    local flags=()
    for repo in "${EXTRA_REPOS[@]+"${EXTRA_REPOS[@]}"}"; do
        [[ -d "$repo" ]] && flags+=(--add-dir "${repo}")
    done
    echo "${flags[@]+"${flags[@]}"}"
}

run_claude() {
    local prompt="$1"
    local session_id="${2:-}"
    local resume_mode="${3:-false}"

    local cmd=(
        claude
        --print
        --dangerously-skip-permissions
    )

    # Adiciona acesso aos repos extras
    local add_dirs
    read -ra add_dirs <<< "$(build_add_dir_flags)"
    [[ ${#add_dirs[@]} -gt 0 ]] && cmd+=("${add_dirs[@]}")

    if [[ "$resume_mode" == "true" && -n "$session_id" ]]; then
        # Retoma sessão existente (quando há interrupção por janela de 5h)
        cmd+=(--resume "${session_id}")
    elif [[ -n "$session_id" ]]; then
        # Inicia nova sessão com ID pré-definido (para poder retomar depois)
        cmd+=(--session-id "${session_id}")
    fi

    cmd+=("${prompt}")

    if [[ -n "${TIMEOUT_CMD}" ]]; then
        "${TIMEOUT_CMD}" "${TASK_TIMEOUT_SECS}" "${cmd[@]}"
    else
        "${cmd[@]}"
    fi
}

execute_task() {
    local task_file="$1" task_num="$2"
    local exit_code

    local saved_session
    saved_session=$(get_saved_session "${task_num}")

    # ── Tentativa de retomada (sessão interrompida anteriormente) ──────────
    if [[ -n "$saved_session" ]]; then
        warn "Sessão anterior encontrada: ${saved_session}"
        warn "Tentando retomar de onde parou..."

        if run_claude "${RESUME_PROMPT}" "${saved_session}" "true"; then
            clear_session "${task_num}"
            return 0
        fi

        exit_code=$?
        if [[ $exit_code -eq 124 ]]; then
            err "Timeout (4h45m) ao retomar sessão ${saved_session}. Task excede a janela de contexto."
        else
            warn "Não foi possível retomar sessão ${saved_session} (código: ${exit_code}). Iniciando nova execução..."
        fi
        clear_session "${task_num}"
    fi

    # ── Execução inicial ou re-execução ────────────────────────────────────
    local new_session
    new_session=$(uuidgen | tr '[:upper:]' '[:lower:]')
    save_session "${task_num}" "${new_session}"

    log "Iniciando claude (session: ${new_session})"

    if run_claude "/executar-task @${task_file}" "${new_session}" "false"; then
        clear_session "${task_num}"
        return 0
    fi

    exit_code=$?

    if [[ $exit_code -eq 124 ]]; then
        # Timeout: sessão provavelmente ainda existe no histórico do Claude.
        # O próximo restart tentará retomá-la via --resume.
        err "Task ${task_num} atingiu o timeout (4h45m)."
        err "A sessão ${new_session} foi salva. Ao reiniciar o script, a task será retomada."
    else
        err "Task ${task_num} falhou com código de saída: ${exit_code}"
        clear_session "${task_num}"
    fi

    return 1
}

# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────

main() {
    sep
    log "Sequential Task Runner"
    log "PRD:   ${TASK_DIR}"
    log "Repos: ${ALL_REPOS[*]}"
    $RESET && log "Modo: RESET (progresso será apagado)"
    sep

    [[ -d "${TASK_DIR}" ]] || { err "Diretório não encontrado: ${TASK_DIR}"; exit 1; }

    command -v claude &>/dev/null || { err "'claude' não encontrado no PATH. Instale o Claude Code CLI."; exit 1; }
    command -v uuidgen &>/dev/null || { err "'uuidgen' não encontrado. Instale as ferramentas de sistema base."; exit 1; }

    # Detecta o comando de timeout disponível (macOS usa gtimeout via coreutils)
    if command -v timeout &>/dev/null; then
        TIMEOUT_CMD="timeout"
    elif command -v gtimeout &>/dev/null; then
        TIMEOUT_CMD="gtimeout"
    else
        warn "'timeout'/'gtimeout' não encontrado. Execução sem timeout de segurança."
        warn "Para instalar: brew install coreutils"
        TIMEOUT_CMD=""
    fi

    ensure_progress_dir

    $RESET && reset_progress

    # ── Coleta tasks ────────────────────────────────────────────────────────
    local tasks=()
    while IFS= read -r t; do
        [[ -n "$t" ]] && tasks+=("$t")
    done < <(find_tasks)

    if [[ ${#tasks[@]} -eq 0 ]]; then
        err "Nenhuma task encontrada em: ${TASK_DIR}"
        err "Esperado: arquivos no formato N_task.md (ex: 1_task.md)"
        exit 1
    fi

    [[ -f "${TASKS_MD}" ]] && log "tasks.md: ${TASKS_MD}" || warn "tasks.md não encontrado — usando apenas estado local (.progress/)"
    log "Tasks encontradas: ${#tasks[@]}"
    for t in "${tasks[@]}"; do
        local num
        num=$(get_task_num "$t")
        local status="pendente"
        if [[ -f "${PROGRESS_DIR}/${num}.done" ]]; then
            status="concluída (local)"
        elif is_done_in_tasks_md "${num}"; then
            status="concluída (tasks.md)"
        fi
        [[ -n "$(get_saved_session "$num")" ]] && status="interrompida (será retomada)"
        log "  task ${num}: $(get_task_title "$t") [${status}]"
    done
    sep

    # ── Execução sequencial ─────────────────────────────────────────────────
    local total=${#tasks[@]} completed=0 skipped=0 failed=0

    for task_file in "${tasks[@]}"; do
        local task_num
        task_num=$(get_task_num "${task_file}")

        if is_completed "${task_num}"; then
            warn "Task ${task_num} já concluída — pulando"
            ((skipped++)) || true
            continue
        fi

        sep
        log "Executando task ${task_num}/${total}: $(get_task_title "${task_file}")"
        log "Arquivo: ${task_file}"
        sep

        if execute_task "${task_file}" "${task_num}"; then
            mark_completed "${task_num}"

            local title
            title=$(get_task_title "${task_file}")
            commit_and_push "${task_num}" "${title}"

            ok "Task ${task_num} concluída"
            ((completed++)) || true
        else
            err "Task ${task_num} falhou."
            err ""
            err "Para retomar: execute o script novamente — tasks concluídas serão puladas"
            err "e tasks interrompidas serão retomadas de onde pararam."
            ((failed++)) || true
            break
        fi
    done

    # ── Resumo ───────────────────────────────────────────────────────────────
    sep
    log "Resultado:"
    log "  Total:      ${total}"
    ok  "  Concluídas: ${completed}"
    warn "  Puladas:    ${skipped} (já estavam prontas)"
    [[ $failed -gt 0 ]] && err "  Falhas:     ${failed}"
    sep

    [[ $failed -eq 0 ]]
}

main "$@"
