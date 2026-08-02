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

Antes de executar cada task, o script gera um UUID e salva em `.progress/N.session`. Se o script for interrompido e relançado:

1. Detecta o arquivo `.session` da task interrompida
2. Usa `--resume <uuid>` para retomar a sessão do Claude de onde parou
3. Se a retomada falhar, inicia uma execução limpa da task
4. Tasks já concluídas (`.progress/N.done`) são sempre puladas

## Comportamento após cada task

Após cada task concluída com sucesso, o script:

1. Marca a task como concluída em `.progress/N.done`
2. Faz `git add -A` + `git commit` em todos os repos com alterações
3. Faz `git push` (a menos que `--no-push` esteja ativo)

## Dependências

- `claude` — Claude Code CLI instalado e autenticado
- `uuidgen` — disponível por padrão no macOS
- `gtimeout` (opcional) — instale via `brew install coreutils` para proteção de timeout por task
