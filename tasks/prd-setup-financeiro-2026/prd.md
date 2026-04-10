# PRD: Setup Financeiro 2026

## Visao Geral

O Controlai atualmente permite registrar compras via notificacoes de pagamento e leitura de notas fiscais, mas as categorias de gastos sao inseridas como texto livre, sem padronizacao ou gerenciamento. Isso impede o usuario de organizar e filtrar compras de forma consistente, reproduzindo um problema que ja existia na planilha Google Sheets utilizada anteriormente.

Esta funcionalidade introduz o gerenciamento de categorias de gastos no Controlai: uma entidade dedicada com CRUD completo, lista pre-populada com as categorias ja utilizadas pelo casal, e vinculacao estruturada com as compras registradas. O objetivo e substituir o campo de texto livre por uma selecao padronizada, mantendo flexibilidade para o usuario criar e editar categorias.

Cartoes de credito (Payment Methods) ja estao implementados no backend e frontend e servem como referencia de entidade configuravel no app.

## Objetivos

- **Padronizar categorias**: Eliminar o campo de texto livre e substituir por selecao de categorias cadastradas, garantindo consistencia nos registros.
- **Facilitar a organizacao**: Permitir que o usuario gerencie suas categorias de gastos (criar, editar, excluir) diretamente no app mobile.
- **Reduzir atrito no registro**: Oferecer lista pre-populada com 15 categorias genericas, evitando configuracao manual inicial.
- **Metrica de sucesso**: 100% das compras registradas com categoria vinculada (vs texto livre ou nulo).

## Historias de Usuario

1. **Como** usuario do Controlai, **eu quero** ver uma lista de categorias pre-cadastradas ao abrir o app pela primeira vez **para que** eu nao precise configurar tudo do zero.

2. **Como** usuario, **eu quero** selecionar uma categoria de uma lista ao registrar uma compra manual **para que** meus gastos fiquem organizados de forma padronizada.

3. **Como** usuario, **eu quero** criar novas categorias personalizadas **para que** eu possa adaptar o app as minhas necessidades especificas.

4. **Como** usuario, **eu quero** editar o nome de uma categoria existente **para que** eu possa corrigir ou renomear categorias sem perder o historico de compras vinculadas.

5. **Como** usuario, **eu quero** excluir uma categoria que nao uso mais **para que** a lista de selecao fique limpa e relevante.

6. **Como** usuario, **eu quero** que compras importadas via nota fiscal tambem sejam associadas a uma categoria **para que** todos os registros tenham classificacao, independente da origem.

## Funcionalidades Principais

### F1. CRUD de Categorias de Gastos

Gerenciamento completo de categorias de gastos no app mobile.

- **O que faz**: Permite criar, listar, editar e excluir categorias de gastos.
- **Por que e importante**: Substitui o campo de texto livre atual, garantindo consistencia e reutilizacao.
- **Como funciona em alto nivel**: Tela dedicada no app com lista de categorias e acoes de criar/editar/excluir. Cada categoria tem um nome unico.

**Requisitos funcionais:**
1. RF-01: O sistema deve permitir criar uma categoria com nome (obrigatorio, texto, max 50 caracteres).
2. RF-02: O sistema deve impedir a criacao de categorias com nomes duplicados (case-insensitive).
3. RF-03: O sistema deve permitir editar o nome de uma categoria existente.
4. RF-04: O sistema deve permitir excluir uma categoria, desde que nao esteja vinculada a nenhuma compra.
5. RF-05: Ao tentar excluir uma categoria vinculada a compras, o sistema deve exibir mensagem informando a quantidade de compras vinculadas e impedir a exclusao.
6. RF-06: O sistema deve listar todas as categorias em ordem alfabetica.

### F2. Categorias Pre-populadas

Lista inicial de categorias baseada no uso real do casal.

- **O que faz**: Ao inicializar o sistema, popula automaticamente as categorias padrao.
- **Por que e importante**: Elimina o atrito de configuracao inicial, ja que o casal ja tem categorias bem definidas.

**Requisitos funcionais:**
7. RF-07: O sistema deve incluir as seguintes categorias pre-populadas: Gastos Gerais, Mercado, Veiculos, Pets, Moradia, Remedios, Medicos, Transporte, Viagens, Assinaturas, Lazer, Educacao, Vestuario, Beleza, Presentes.
8. RF-08: As categorias pre-populadas devem ser criadas apenas se nao existirem categorias no banco de dados (idempotente).
9. RF-09: Categorias pre-populadas podem ser editadas e excluidas pelo usuario da mesma forma que categorias criadas manualmente.

### F3. Vinculacao de Categoria com Compras

Integrar categorias ao fluxo de registro de compras.

- **O que faz**: Substitui o campo de texto livre por selecao de categoria cadastrada no registro de compras.
- **Por que e importante**: Garante que todas as compras tenham categoria padronizada, permitindo filtros e agrupamentos futuros.

**Requisitos funcionais:**
10. RF-10: O formulario de registro manual de compra deve exibir um seletor de categorias (dropdown ou lista) em vez do campo de texto livre.
11. RF-11: A selecao de categoria no registro manual deve ser obrigatoria.
12. RF-12: Compras importadas via nota fiscal devem permitir atribuicao de categoria apos a importacao.
13. RF-13: Compras existentes com categoria em texto livre devem continuar funcionando (retrocompatibilidade) ate serem recategorizadas pelo usuario.
14. RF-14: A listagem de compras deve exibir o nome da categoria vinculada.

## Experiencia do Usuario

### Personas

- **Ramon (usuario primario)**: Gerencia os gastos do casal, registra compras manualmente e via QR code. Precisa de categorias organizadas para controle financeiro.
- **Aline (usuario secundario eventual)**: Pode usar o app no celular do Ramon para registrar compras.

### Fluxos Principais

1. **Gerenciar categorias**: Tab de configuracoes > Categorias > Lista com opcoes de criar/editar/excluir.
2. **Registrar compra manual**: Formulario existente (ManualEntryPage) com seletor de categoria substituindo o campo texto.
3. **Categorizar compra importada**: Apos importacao via QR/nota fiscal, tela de detalhe da compra com opcao de selecionar categoria.

### Consideracoes de UI/UX

- A tela de categorias deve seguir o mesmo padrao visual da tela de Payment Methods (PaymentMethodsPage), mantendo consistencia.
- O seletor de categoria no formulario de compra deve ser um componente Ionic nativo (IonSelect ou similar).
- Categorias devem ser facilmente acessiveis — maximo 2 toques para chegar a tela de gerenciamento.
- Feedback visual ao criar, editar ou excluir categorias (toast de confirmacao).

### Acessibilidade

- Labels adequados em todos os campos de formulario.
- Contraste suficiente para leitura em ambiente externo (uso mobile).
- Suporte a navegacao por gestos padrao do Ionic.

## Restricoes Tecnicas de Alto Nivel

- **Backend**: Spring Boot 3.5.7 + Kotlin 1.9.25, arquitetura hexagonal existente. Nova entidade deve seguir os padroes de domain/gateway/provider.
- **Frontend**: React 19 + Ionic React 8 + Capacitor 8. Comunicacao via HTTP (CapacitorHttp nativo / fetch web).
- **Banco de dados**: MySQL 8.0 com Flyway para migracoes. Nova tabela de categorias + FK nas tabelas de compras.
- **API existente**: Backend em `https://api.opencod3.com.br`. Novos endpoints de categorias devem seguir o padrao REST existente.
- **Retrocompatibilidade**: Compras com campo `category` texto livre (VARCHAR 50) devem continuar funcionando durante a transicao.

## Fora de Escopo

- **Importacao de dados da planilha Google Sheets**: Migracao de historico fica para um PRD futuro.
- **Relatorios e dashboards**: Visualizacoes de gastos por categoria, graficos e comparativos nao fazem parte deste PRD.
- **Multi-usuario/compartilhamento**: Login separado, perfis de usuario ou compartilhamento de dados entre contas.
- **Orcamento por categoria**: Definicao de metas/limites de gasto por categoria (equivalente a aba PL da planilha).
- **Melhorias em cartoes**: A funcionalidade de Payment Methods ja esta implementada e nao sera alterada neste escopo.
- **Categorizacao automatica**: Sugestao automatica de categoria baseada em historico ou nome do estabelecimento.
