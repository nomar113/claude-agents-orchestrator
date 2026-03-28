# CLAUDE.md

Guia para agentes de IA ao trabalhar com este orquestrador de skills.

Este repositório contém um conjunto de **skills, commands e agents** para orquestrar o ciclo completo de desenvolvimento de software com Claude Code.

## Workflow de Desenvolvimento

O fluxo segue uma ordem lógica e sequencial:

```
1. cria-prd          → Cria o PRD (Documento de Requisitos de Produto)
2. cria-techspec     → Cria a Tech Spec a partir do PRD
3. criar-tasks       → Quebra PRD + Tech Spec em tarefas incrementais
4. executar-task     → Implementa cada tarefa (com review automático via task-reviewer)
5. executar-review   → Code review completo da branch/feature
6. executar-qa       → QA com Playwright MCP, acessibilidade e visual
7. executar-bugfix   → Corrige bugs documentados pelo QA
```

## Como Usar

### Via Slash Commands (recomendado)

```
/cria-prd            → Inicia criação de PRD
/cria-techspec       → Inicia criação de Tech Spec
/criar-tasks         → Inicia criação de tarefas
/executar-task       → Implementa uma tarefa
/executar-review     → Executa code review
/executar-qa         → Executa QA
/executar-bugfix     → Corrige bugs
```

### Estrutura de Saída

Todos os artefatos são salvos em `./tasks/prd-[feature-slug]/`:

```
tasks/prd-[feature-slug]/
├── prd.md           # Documento de Requisitos
├── techspec.md      # Especificação Técnica
├── tasks.md         # Resumo das tarefas
├── 1_task.md        # Tarefa individual
├── 2_task.md
├── ...
├── bugs.md          # Bugs documentados pelo QA
├── 1_task_review.md # Review da tarefa 1
└── ...
```

## Prioridades

- **Sempre ative a skill correspondente** ao executar um command
- **Siga o workflow na ordem** — cada etapa depende da anterior
- **Não pule etapas** — o PRD é pré-requisito da Tech Spec, que é pré-requisito das Tasks
- **Execute os checks** antes de concluir tarefas: `typecheck`, `test`, `build`, `lint`
- **Não use workarounds** — prefira correções de causa raiz

## Estrutura do Repositório

```
├── CLAUDE.md                          # Este arquivo
├── README.md                          # Documentação de uso
├── .agents/
│   └── skills/                        # Skills (procedimentos completos)
│       ├── cria-prd/
│       │   ├── SKILL.md
│       │   └── assets/prd-template.md
│       ├── cria-techspec/
│       │   ├── SKILL.md
│       │   └── assets/techspec-template.md
│       ├── criar-tasks/
│       │   ├── SKILL.md
│       │   └── assets/
│       │       ├── tasks-template.md
│       │       └── task-template.md
│       ├── executar-task/
│       │   └── SKILL.md
│       ├── executar-review/
│       │   ├── SKILL.md
│       │   ├── assets/review-report-template.md
│       │   └── references/code-quality-checklist.md
│       ├── executar-qa/
│       │   ├── SKILL.md
│       │   ├── assets/qa-report-template.md
│       │   └── references/playwright-tools.md
│       ├── executar-bugfix/
│       │   ├── SKILL.md
│       │   └── assets/bugfix-report-template.md
│       └── task-review/
│           ├── SKILL.md
│           ├── assets/review-artifact-template.md
│           └── references/code-standards.md
├── .claude/
│   ├── commands/                      # Slash commands (atalhos)
│   │   ├── cria-prd.md
│   │   ├── cria-techspec.md
│   │   ├── criar-tasks.md
│   │   ├── executar-task.md
│   │   ├── executar-review.md
│   │   ├── executar-qa.md
│   │   └── executar-bugfix.md
│   └── agents/                        # Agents (sub-agentes)
│       └── task-reviewer.md
```

## Anti-padroes

1. Pular ativacao de skill
2. Executar etapa sem a anterior estar completa
3. Esquecer verificacao antes de marcar tarefa concluida
4. Aplicar workarounds em vez de correcoes de causa raiz
5. Nao criar testes para cada tarefa
6. Ignorar o task-reviewer apos completar uma task
