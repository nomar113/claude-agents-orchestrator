# Claude Agents Orchestrator

Conjunto de **skills, commands e agents** para orquestrar o ciclo completo de desenvolvimento de software com [Claude Code](https://claude.com/claude-code).

## O que e isso?

Este repositorio contem um workflow completo de desenvolvimento de software orientado por IA. Cada etapa do ciclo de vida de uma feature -- desde a definicao de requisitos ate a correcao de bugs -- e conduzida por uma **skill** especializada com procedimentos, templates e checklists de qualidade.

## Workflow

```
PRD → Tech Spec → Tasks → Implementacao → Review → QA → Bugfix
```

| Etapa | Command | Skill | Descricao |
|-------|---------|-------|-----------|
| 1 | `/cria-prd` | `cria-prd` | Cria o Documento de Requisitos de Produto |
| 2 | `/cria-techspec` | `cria-techspec` | Cria a Especificacao Tecnica a partir do PRD |
| 3 | `/criar-tasks` | `criar-tasks` | Quebra PRD + Tech Spec em tarefas incrementais |
| 4 | `/executar-task` | `executar-task` | Implementa uma tarefa (com review automatico) |
| 5 | `/executar-review` | `executar-review` | Code review completo da branch/feature |
| 6 | `/executar-qa` | `executar-qa` | QA com Playwright, acessibilidade e visual |
| 7 | `/executar-bugfix` | `executar-bugfix` | Corrige bugs documentados pelo QA |

Alem dos commands, existe o **agent `task-reviewer`** que e acionado automaticamente apos a conclusao de cada tarefa para validar qualidade do codigo.

## Instalacao

### Opcao 1: Copiar para o seu projeto

Copie as pastas `.agents/` e `.claude/` para a raiz do seu projeto:

```bash
# Clone este repositorio
git clone <url-do-repo> claude-agents-orchestrator

# Copie para o seu projeto
cp -r claude-agents-orchestrator/.agents/ /caminho/do/seu/projeto/
cp -r claude-agents-orchestrator/.claude/ /caminho/do/seu/projeto/
```

### Opcao 2: Usar como referencia

Mantenha este repositorio separado e copie apenas as skills que precisa.

## Como Usar

### Pre-requisitos

- [Claude Code](https://claude.com/claude-code) instalado e configurado
- (Opcional) [Playwright MCP](https://github.com/anthropics/claude-code) para testes E2E no QA
- (Opcional) [Context7 MCP](https://github.com/context7/context7) para pesquisa de documentacao

### Passo a passo para uma nova feature

#### 1. Criar o PRD

No Claude Code, execute:

```
/cria-prd
```

O agente vai:
- Fazer perguntas de clarificacao sobre a feature
- Apresentar um plano do PRD para alinhamento
- Gerar o PRD usando o template padronizado
- Salvar em `./tasks/prd-[nome-da-feature]/prd.md`

#### 2. Criar a Tech Spec

```
/cria-techspec
```

O agente vai:
- Ler o PRD existente
- Explorar o codebase do projeto
- Pesquisar documentacao tecnica (Context7 MCP + Web Search)
- Fazer perguntas tecnicas de clarificacao
- Gerar a Tech Spec com decisoes arquiteturais
- Salvar em `./tasks/prd-[nome-da-feature]/techspec.md`

#### 3. Criar as Tasks

```
/criar-tasks
```

O agente vai:
- Analisar o PRD e a Tech Spec
- Apresentar uma lista high-level de tarefas para aprovacao
- Gerar arquivos individuais para cada tarefa
- Salvar em `./tasks/prd-[nome-da-feature]/tasks.md` e `[num]_task.md`

#### 4. Implementar cada Task

```
/executar-task
```

O agente vai:
- Ler a tarefa, PRD e Tech Spec
- Carregar skills necessarias para as tecnologias envolvidas
- Analisar dependencias e planejar a implementacao
- Implementar com testes
- Marcar a tarefa como completa
- Executar o `task-reviewer` automaticamente

#### 5. Code Review

```
/executar-review
```

O agente vai:
- Analisar todas as mudancas via git diff
- Verificar conformidade com rules do projeto e Tech Spec
- Executar testes e typecheck
- Gerar relatorio com status: APROVADO / APROVADO COM RESSALVAS / REPROVADO

#### 6. QA (Quality Assurance)

```
/executar-qa
```

O agente vai:
- Verificar cada requisito funcional do PRD
- Executar testes E2E via Playwright MCP
- Verificar acessibilidade (WCAG 2.2)
- Capturar screenshots de evidencia
- Documentar bugs em `bugs.md`
- Gerar relatorio de QA

#### 7. Corrigir Bugs

```
/executar-bugfix
```

O agente vai:
- Ler todos os bugs documentados
- Analisar causa raiz de cada bug
- Corrigir por ordem de severidade (alta → media → baixa)
- Criar testes de regressao
- Validar visualmente fixes de frontend
- Atualizar `bugs.md` com status de correcao

## Estrutura de Artefatos

Cada feature gera a seguinte estrutura:

```
tasks/prd-[feature-slug]/
├── prd.md                # Documento de Requisitos
├── techspec.md           # Especificacao Tecnica
├── tasks.md              # Resumo das tarefas (checklist)
├── 1_task.md             # Tarefa 1
├── 1_task_review.md      # Review da tarefa 1
├── 2_task.md             # Tarefa 2
├── 2_task_review.md      # Review da tarefa 2
├── ...
├── bugs.md               # Bugs encontrados pelo QA
└── bugfix-report.md      # Relatorio de correcao
```

## Estrutura do Repositorio

```
├── CLAUDE.md                              # Guia principal para agentes
├── README.md                              # Este arquivo
├── .agents/
│   └── skills/                            # Skills (procedimentos completos)
│       ├── cria-prd/
│       │   ├── SKILL.md                   # Procedimento da skill
│       │   └── assets/prd-template.md     # Template do PRD
│       ├── cria-techspec/
│       │   ├── SKILL.md
│       │   └── assets/techspec-template.md
│       ├── criar-tasks/
│       │   ├── SKILL.md
│       │   └── assets/
│       │       ├── tasks-template.md      # Template do resumo
│       │       └── task-template.md       # Template da tarefa individual
│       ├── executar-task/
│       │   └── SKILL.md
│       ├── task-review/
│       │   ├── SKILL.md
│       │   ├── assets/review-artifact-template.md
│       │   └── references/code-standards.md
│       ├── executar-review/
│       │   ├── SKILL.md
│       │   ├── assets/review-report-template.md
│       │   └── references/code-quality-checklist.md
│       ├── executar-qa/
│       │   ├── SKILL.md
│       │   ├── assets/qa-report-template.md
│       │   └── references/playwright-tools.md
│       └── executar-bugfix/
│           ├── SKILL.md
│           └── assets/bugfix-report-template.md
├── .claude/
│   ├── commands/                          # Slash commands
│   │   ├── cria-prd.md
│   │   ├── cria-techspec.md
│   │   ├── criar-tasks.md
│   │   ├── executar-task.md
│   │   ├── executar-review.md
│   │   ├── executar-qa.md
│   │   └── executar-bugfix.md
│   └── agents/                            # Sub-agentes
│       └── task-reviewer.md
```

## Conceitos

### Skills

Uma **skill** e um procedimento completo com passos, templates, checklists e tratamento de erros. Seguem a especificacao [agentskills.io](https://agentskills.io). Cada skill tem:

- `SKILL.md` - Procedimento principal
- `assets/` - Templates e arquivos estaticos
- `references/` - Documentacao de referencia
- `scripts/` - Scripts auxiliares

### Commands

Um **command** (slash command) e um atalho que ativa uma skill. Sao arquivos `.md` em `.claude/commands/` que definem o papel do agente e instrucoes criticas para execucao.

### Agents

Um **agent** e um sub-agente especializado que pode ser invocado pelo agente principal. O `task-reviewer` e acionado automaticamente apos a conclusao de cada tarefa.

## Personalizacao

### Adaptar para seu projeto

1. **CLAUDE.md**: Edite o `CLAUDE.md` na raiz do seu projeto para incluir suas regras especificas (stack, padroes, comandos de build/test)
2. **Templates**: Modifique os templates em `assets/` de cada skill para atender suas necessidades
3. **Code Standards**: Atualize `references/code-standards.md` da skill `task-review` com os padroes do seu projeto
4. **Comandos de teste**: As skills referenciam `bun run test`, `bun run typecheck`, etc. Ajuste para o seu toolchain

### Adicionar novas skills

Cada skill segue a estrutura:

```
.agents/skills/[nome-da-skill]/
├── SKILL.md              # Procedimento (frontmatter YAML + markdown)
├── assets/               # Templates
├── references/           # Documentacao
└── scripts/              # Scripts auxiliares
```

O `SKILL.md` deve ter o frontmatter:

```yaml
---
name: nome-da-skill
description: Descricao detalhada de quando usar e quando nao usar.
---
```

## Licenca

MIT
