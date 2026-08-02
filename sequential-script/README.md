# Sequential Task Runner

Executa tasks de uma PRD sequencialmente com Claude Code, resistente à janela de 5h.

## Como usar

```bash
# Executar todas as tasks de uma PRD
./sequential-script/run.sh tasks/prd-login-autenticacao/

# Com repos adicionais para commit/push (backend + frontend)
./sequential-script/run.sh tasks/prd-login-autenticacao/ \
  --repos /Volumes/SSD480GB/projects/controlai,/Volumes/SSD480GB/projects/controlai-frontend

# Reiniciar do zero (ignorar progresso salvo)
./sequential-script/run.sh tasks/prd-login-autenticacao/ --reset

# Também aceita o prefixo @
./sequential-script/run.sh @tasks/prd-login-autenticacao/
```

## Opções

| Opção | Descrição |
|-------|-----------|
| `<task-dir>` | Pasta da PRD com os arquivos `N_task.md` (obrigatório) |
| `--repos dir1,dir2` | Repos adicionais para commit/push, separados por vírgula |
| `--reset` | Limpa o progresso salvo e recomeça do zero |
| `--no-push` | Faz commit mas não executa `git push` |

## Resistência à janela de 5h

Antes de executar cada task, o script gera um UUID e salva em `.progress/N.session`. Quando a janela de 5h expira e o Claude encerra com erro, o script:

1. Aguarda `RETRY_DELAY_SECS` (padrão: 5 minutos) e tenta novamente automaticamente
2. Repete até `MAX_RETRIES` vezes (padrão: 5 tentativas)
3. Em cada tentativa, verifica se há sessão salva e usa `--resume <uuid>` para retomar
4. Se a retomada falhar, inicia uma execução limpa da task
5. Tasks já concluídas (`.progress/N.done` ou `[x]` no `tasks.md`) são sempre puladas

Os parâmetros podem ser ajustados no topo do script:

```bash
MAX_RETRIES=5         # tentativas por task
RETRY_DELAY_SECS=300  # segundos entre tentativas (5 minutos)
```

## Comportamento após cada task

Após cada task concluída com sucesso, o script:

1. Marca a task como concluída em `.progress/N.done`
2. Faz `git add -A` + `git commit` em todos os repos com alterações
3. Faz `git push` (a menos que `--no-push` esteja ativo)

## Rodando em background (recomendado)

Use `nohup` para que o processo rode independente da sessão do terminal:

```bash
nohup ./sequential-script/run.sh tasks/prd-login-autenticacao/ \
  --repos /Volumes/SSD480GB/projects/controlai,/Volumes/SSD480GB/projects/controlai-frontend \
  > tasks/prd-login-autenticacao/run.log 2>&1 &

echo "PID: $!"
```

## Monitorando a execução

```bash
# Acompanhar o log em tempo real
tail -f tasks/prd-login-autenticacao/run.log

# Ver apenas as últimas linhas
tail -50 tasks/prd-login-autenticacao/run.log

# Verificar se o processo ainda está vivo
pgrep -fa "run.sh"

# Ver quais tasks já concluíram ou estão rodando
grep "Executando task\|concluída\|Falhas" tasks/prd-login-autenticacao/run.log

# Verificar estado local (.progress)
ls tasks/prd-login-autenticacao/.progress/
```

Para parar o processo:

```bash
pkill -f "run.sh"
```

## Dependências

- `claude` — Claude Code CLI instalado e autenticado
- `uuidgen` — disponível por padrão no macOS
- `gtimeout` (opcional) — instale via `brew install coreutils` para proteção de timeout por task
