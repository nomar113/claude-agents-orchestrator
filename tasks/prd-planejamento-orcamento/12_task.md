# Tarefa 12.0: [BUGFIX MAJOR] Adicionar link Orcamento na Tab3 e corrigir httpRequest duplicada

<critical>Ler os arquivos de prd.md, techspec.md e review_all_tasks.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Corrigir dois problemas major identificados na review: (M1) o link "Orcamento Mensal" nao foi adicionado na Tab3 conforme exigido pela task 10, e (M5) a funcao `httpRequest` foi duplicada no `budgetService.ts` em vez de importar a versao compartilhada.

<skills>
### Conformidade com Skills Padroes

- `executar-bugfix` — Seguir o procedimento completo de correcao de bugs
- `executar-review` — Code review apos implementacao
</skills>

<requirements>
- Adicionar link "Orcamento Mensal" na Tab3 seguindo o mesmo padrao dos links existentes (Cartoes e Categorias)
- Remover a funcao `httpRequest` duplicada do `budgetService.ts`
- Importar a funcao `httpRequest` do modulo compartilhado existente
- Garantir que todos os endpoints do budgetService continuam funcionando com a versao importada
</requirements>

## Subtarefas

- [ ] 12.1 Adicionar link "Orcamento Mensal" na Tab3.tsx com icone e descricao adequados
- [ ] 12.2 Identificar o modulo compartilhado que exporta `httpRequest`
- [ ] 12.3 Remover funcao `httpRequest` local do `budgetService.ts` e importar a compartilhada
- [ ] 12.4 Verificar que todos os endpoints do budgetService funcionam corretamente

## Detalhes de Implementacao

### Tab3.tsx
```tsx
// Adicionar apos o link de Categorias, mesmo padrao visual
<button className="t3-item" onClick={() => history.push('/budget')}>
  <div className="t3-item-icon">
    <IonIcon icon={walletOutline} />
  </div>
  <div className="t3-item-info">
    <p className="t3-item-name">Orcamento Mensal</p>
    <p className="t3-item-desc">Planejar receitas e gastos por categoria</p>
  </div>
  <IonIcon icon={chevronForwardOutline} className="t3-chevron" />
</button>
```

### budgetService.ts
```typescript
// ANTES: funcao httpRequest local duplicada (linhas 16-46)
// DEPOIS: importar do modulo compartilhado
import { httpRequest } from './httpUtils'; // ou o path correto do utilitario existente
```

## Criterios de Sucesso

- Link "Orcamento Mensal" visivel na Tab3, navegando para /budget ao clicar
- Funcao `httpRequest` importada do modulo compartilhado, sem duplicacao
- Frontend compila sem erros
- Navegacao entre Tab3 e BudgetPage funciona corretamente
