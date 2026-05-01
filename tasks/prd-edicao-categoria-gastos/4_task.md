# Tarefa 4.0: Frontend — Edicao de categoria no PurchaseDetail

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Transformar o campo "Categoria" na pagina PurchaseDetail de exibicao read-only para campo clicavel que abre o `CategoryBottomSheet`. Ao selecionar uma categoria, salvar imediatamente via API e atualizar o estado local.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo de implementacao incremental
- `task-review` — Submeter para review apos conclusao
</skills>

<requirements>
- O campo "Categoria" (linhas 315-322 de PurchaseDetail.tsx) deve ser clicavel
- Ao clicar, abrir o `CategoryBottomSheet` com a categoria atual selecionada
- Ao selecionar categoria no bottom sheet, chamar `updatePaymentNotificationCategory(id, categoryId)`
- Atualizar o estado `notification` com a resposta da API (sem reload da pagina)
- Exibir o nome da categoria atualizada (vindo do campo `category` da resposta)
- Permitir remover categoria (selecionar "Nenhuma" → exibe "Sem categoria")
- Exibir estado de loading durante o save (opcional: spinner discreto no campo)
</requirements>

## Subtarefas

- [ ] 4.1 Adicionar estado `isCategorySheetOpen` no PurchaseDetail
- [ ] 4.2 Tornar o campo "Categoria" clicavel (similar ao campo descricao)
- [ ] 4.3 Integrar `CategoryBottomSheet` no PurchaseDetail
- [ ] 4.4 Implementar handler `handleCategorySelect` que salva via API e atualiza estado
- [ ] 4.5 Exibir nome da categoria atualizada apos save
- [ ] 4.6 Escrever testes unitarios

## Detalhes de Implementacao

Consultar a secao **"Sequenciamento de Desenvolvimento"** (etapa 4) da `techspec.md`.

**Padrao de referencia:** O fluxo de edicao de descricao (linhas 141-161 de PurchaseDetail.tsx) mostra o padrao de edicao inline com save via API e atualizacao de estado.

**Campo atual a modificar (PurchaseDetail.tsx, linhas 315-322):**
```tsx
<div className="pd-info-row">
  <span className="pd-info-key">Categoria</span>
  <div className="pd-info-val-row">
    <span className="pd-cat-dot" style={{ backgroundColor: cat.color }} />
    <span className="pd-info-val">
      {notification.category || 'Sem categoria'}
    </span>
  </div>
</div>
```

Este bloco deve virar um `<button>` clicavel que abre o bottom sheet.

## Criterios de Sucesso

- Campo "Categoria" e clicavel e abre o bottom sheet
- Selecionar categoria salva via API e atualiza a tela
- Selecionar "Nenhuma" remove a categoria e exibe "Sem categoria"
- Nenhuma regressao nas outras funcionalidades do PurchaseDetail
- Testes passam

## Testes da Tarefa

- [ ] Testes de unidade: campo categoria e clicavel e abre bottom sheet
- [ ] Testes de unidade: selecionar categoria chama API e atualiza estado
- [ ] Testes de unidade: selecionar "Nenhuma" limpa categoria
- [ ] Testes de integracao: fluxo completo com mock de API

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

**Modificar:**
- `src/pages/PurchaseDetail.tsx` (no projeto controlai-frontend)

**Dependencia:**
- `src/components/CategoryBottomSheet.tsx` (task 3.0)
- `src/services/purchaseService.ts` — funcao `updatePaymentNotificationCategory` (task 2.0)
