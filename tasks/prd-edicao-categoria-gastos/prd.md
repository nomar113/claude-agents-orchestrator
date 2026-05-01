# PRD — Edicao de Categoria em Gastos

## Visao Geral

Atualmente, gastos registrados via SMS (Bradesco/Nubank) chegam sem categoria, e gastos criados manualmente recebem categoria apenas no momento da criacao. Nao existe forma de editar a categoria de um gasto apos o registro, o que impede a organizacao financeira adequada e distorce os valores reais do orcamento mensal.

Esta funcionalidade permite que o usuario edite a categoria de qualquer gasto (payment_notification) tanto na tela de detalhe quanto diretamente na listagem, com feedback visual sobre o vinculo da categoria selecionada com o planejamento orcamentario do mes.

## Objetivos

1. **Aumentar gastos categorizados**: Elevar o percentual de payment_notifications com `categoryId` preenchido de forma significativa, especialmente os vindos de SMS que hoje chegam sem categoria.
2. **Melhorar precisao do orcamento**: Garantir que o resumo do orcamento mensal (budget summary) reflita os gastos reais por categoria, sem depender da categorizacao no momento da criacao.
3. **Reduzir friccao do usuario**: Permitir editar a categoria com no maximo 2 toques, sem navegacao desnecessaria.
4. **Integrar com planejamento**: Informar o usuario quando a categoria escolhida nao esta no orcamento do mes e oferecer caminho para adicioná-la.

## Historias de Usuario

### HU-1: Editar categoria na tela de detalhe
Como usuario, eu quero alterar a categoria de um gasto na tela de detalhes da compra, para que eu possa corrigir ou definir a categoria de um gasto ja registrado.

**Criterios de aceite:**
- O campo "Categoria" na PurchaseDetail e clicavel
- Ao clicar, exibe um seletor com todas as categorias cadastradas
- A categoria selecionada e salva imediatamente
- A tela atualiza para refletir a nova categoria

### HU-2: Editar categoria na listagem
Como usuario, eu quero alterar a categoria de um gasto diretamente na listagem de gastos, para que eu possa categorizar rapidamente varios gastos sem abrir cada detalhe.

**Criterios de aceite:**
- Na listagem (Tab1), cada gasto exibe a categoria atual (ou indicador de "sem categoria")
- O usuario pode tocar na categoria para abrir o seletor
- A alteracao e salva sem recarregar a listagem inteira
- Feedback visual confirma a alteracao

### HU-3: Feedback de vinculo com orcamento
Como usuario, eu quero ser informado quando a categoria que escolhi nao esta no orcamento do mes, para que eu possa adicioná-la e manter meu planejamento financeiro atualizado.

**Criterios de aceite:**
- Apos selecionar uma categoria, o sistema verifica se ela existe como item do orcamento do mes correspondente ao gasto
- Se nao existir, exibe um aviso informativo com CTA "Adicionar ao orcamento"
- O CTA direciona o usuario para adicionar a categoria ao orcamento (sem bloquear a selecao)
- Se ja existir no orcamento, nao exibe nenhum aviso

## Funcionalidades Principais

### F1: Atualizacao de categoria via API

**O que faz:** Permite atualizar o `categoryId` de um payment_notification existente.

**Por que e importante:** Hoje so e possivel definir categoria na criacao manual. Gastos de SMS ficam permanentemente sem categoria.

**Requisitos funcionais:**
- RF-01: O sistema deve disponibilizar um endpoint para atualizar a categoria de um payment_notification
- RF-02: O endpoint deve aceitar o `categoryId` (podendo ser `null` para remover a categoria)
- RF-03: O sistema deve validar que o `categoryId` informado corresponde a uma categoria existente
- RF-04: O sistema deve retornar o payment_notification atualizado apos a operacao
- RF-05: O campo legado `category` (string) deve ser atualizado com o nome da categoria selecionada para manter compatibilidade

### F2: Seletor de categoria na tela de detalhe

**O que faz:** Transforma o campo "Categoria" da PurchaseDetail em um seletor interativo.

**Por que e importante:** E o local mais intuitivo para o usuario revisar e corrigir a categoria de um gasto individual.

**Requisitos funcionais:**
- RF-06: O campo "Categoria" deve ser clicavel e abrir um seletor de categorias
- RF-07: O seletor deve exibir todas as categorias cadastradas com nome e icone
- RF-08: A categoria atualmente selecionada deve ser destacada visualmente
- RF-09: O usuario deve poder remover a categoria (voltar para "Sem categoria")
- RF-10: Apos a selecao, a categoria deve ser salva automaticamente (sem botao "Salvar")

### F3: Edicao inline de categoria na listagem

**O que faz:** Permite alterar a categoria de um gasto diretamente na listagem principal (Tab1).

**Por que e importante:** Permite categorizar rapidamente varios gastos em sequencia, otimizando o tempo do usuario.

**Requisitos funcionais:**
- RF-11: Cada item da listagem deve exibir a categoria atual ou indicador visual de "sem categoria"
- RF-12: Ao tocar na area da categoria, deve abrir o seletor de categorias
- RF-13: A alteracao deve ser salva e refletida na listagem sem recarregar todos os dados
- RF-14: Deve haver feedback visual (ex: breve destaque) confirmando a alteracao

### F4: Indicador de vinculo com orcamento

**O que faz:** Informa o usuario se a categoria selecionada faz parte do orcamento mensal e oferece opcao de adicioná-la.

**Por que e importante:** Gastos com categorias fora do orcamento nao aparecem no acompanhamento financeiro, o que pode causar surpresas no final do mes.

**Requisitos funcionais:**
- RF-15: Apos selecionar uma categoria, o sistema deve verificar se ela consta como item do orcamento do mes correspondente a data do gasto
- RF-16: Se a categoria NAO estiver no orcamento, exibir um aviso nao-bloqueante (ex: banner ou tooltip)
- RF-17: O aviso deve conter um CTA "Adicionar ao orcamento" que direcione para a tela/fluxo de adicao de item ao orcamento
- RF-18: Se a categoria JA estiver no orcamento, nao exibir nenhum aviso adicional

## Experiencia do Usuario

### Personas

**Usuario principal:** Pessoa que gerencia gastos pessoais/do casal e acompanha orcamento mensal. Usa o app regularmente para revisar gastos que chegam via SMS.

### Fluxos principais

**Fluxo 1 — Categorizar gasto na listagem:**
1. Usuario abre a listagem de gastos (Tab1)
2. Identifica gasto sem categoria (indicador visual)
3. Toca na area da categoria
4. Seletor de categorias aparece (chips ou bottom sheet)
5. Seleciona a categoria desejada
6. Categoria e salva; indicador visual confirma
7. Se categoria nao esta no orcamento: banner com CTA aparece brevemente

**Fluxo 2 — Categorizar gasto no detalhe:**
1. Usuario abre detalhe de um gasto
2. Toca no campo "Categoria"
3. Seletor aparece com categorias disponiveis
4. Seleciona categoria
5. Campo atualiza imediatamente
6. Aviso de orcamento aparece se aplicavel

### Consideracoes de UI/UX

- Reutilizar o componente `CategoryChips` ja existente no projeto
- O seletor deve ter scroll horizontal ou grid para acomodar todas as categorias
- Categorias devem exibir icone quando disponivel
- A acao de "remover categoria" deve estar acessivel (ex: chip "Nenhuma" ou botao limpar)
- O aviso de orcamento deve ser discreto e nao atrapalhar o fluxo de categorizacao

### Acessibilidade

- O seletor de categorias deve ser navegavel por teclado
- Labels descritivos para leitores de tela (ex: "Selecionar categoria: Mercado")
- Contraste adequado nos indicadores de "sem categoria"

## Restricoes Tecnicas de Alto Nivel

- O modelo `PaymentNotification` ja possui os campos `categoryId` (Long, nullable) e `category` (String, nullable) — nao requer alteracao de schema
- A verificacao de vinculo com orcamento depende da API de budget existente (`GET /budgets?month=YYYY-MM`)
- O componente `CategoryChips` ja existe e lista categorias via `GET /categories`
- Manter compatibilidade com o campo legado `category` (string) ao atualizar via `categoryId`

## Fora de Escopo

- **Auto-categorizacao por merchant:** Categorizar automaticamente gastos com base no nome do estabelecimento (ex: "Carrefour" → "Mercado"). Registrada como evolucao futura.
- **Edicao de categoria em notas fiscais (purchase_invoices):** Esta feature cobre apenas payment_notifications. Notas fiscais poderao ser incluidas em versao futura.
- **Criacao de categorias inline:** O usuario nao podera criar uma nova categoria a partir do seletor. Deve usar a tela de categorias existente.
- **Edicao em lote:** Nao sera possivel selecionar multiplos gastos para categorizar de uma vez.
- **Regras de categorizacao automatica:** Definicao de regras customizaveis pelo usuario para auto-categorizacao futura.
