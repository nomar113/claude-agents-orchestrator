# Tech Spec: Atualizacao Automatica de Listas

## Resumo Executivo

A solucao utiliza o hook `useIonViewWillEnter` do Ionic React para disparar recarregamento de dados toda vez que uma tela fica visivel. Este hook e chamado pelo Ionic sempre que a view e (re)apresentada, resolvendo o problema de tabs cacheadas onde `useEffect([])` so executa uma vez. Para evitar skeleton/loading durante o refresh, sera introduzido um padrao de "silent refresh" que mantem os dados existentes visiveis enquanto busca os novos. Nao serao adicionadas dependencias externas — apenas hooks nativos do Ionic e React.

## Arquitetura do Sistema

### Visao Geral dos Componentes

Componentes que serao **modificados**:

- **Tab1.tsx** — Adicionar `useIonViewWillEnter` para recarregar notificacoes, cartoes e projecao. Adaptar loading para modo silencioso.
- **Tab2.tsx** — Adicionar `useIonViewWillEnter` para recarregar purchase invoices. Adaptar loading para modo silencioso.
- **BudgetPage.tsx** — Adicionar `useIonViewWillEnter` para recarregar budget summary. Adaptar loading para modo silencioso.
- **CategoriesPage.tsx** — Adicionar `useIonViewWillEnter` para recarregar categorias. Adaptar loading para modo silencioso.
- **PaymentMethodsPage.tsx** — Adicionar `useIonViewWillEnter` para recarregar holders e payment methods. Adaptar loading para modo silencioso.
- **PurchaseDetail.tsx** — Adicionar `useIonViewWillEnter` para recarregar dados do detalhe.
- **BudgetSummaryCard.tsx** — Adaptar loading para modo silencioso (componente filho da Tab1).

Fluxo de dados:

1. Usuario navega para uma tela de mutacao (ManualEntryPage, PurchaseDetail edit, etc.)
2. Realiza insert/update/delete via service calls existentes
3. Navega de volta (goBack, tab click, etc.)
4. `useIonViewWillEnter` dispara na tela de destino
5. Funcao de reload existente e chamada em modo silencioso (sem setar `isLoading = true`)
6. Dados sao atualizados no state sem flicker, scroll mantido

## Design de Implementacao

### Interfaces Principais

Padrao de silent refresh a ser aplicado em cada pagina:

```tsx
// Padrao a aplicar em cada componente de listagem
import { useIonViewWillEnter } from '@ionic/react';

const ExamplePage: React.FC = () => {
  const [data, setData] = useState<Data[]>([]);
  const [isLoading, setIsLoading] = useState(true); // apenas carga inicial
  const hasLoadedRef = useRef(false);

  const loadData = useCallback(async (silent = false) => {
    if (!silent) setIsLoading(true);
    try {
      const result = await fetchData();
      setData(result);
    } catch {
      // em modo silent, manter dados anteriores (nao setar erro)
      if (!silent) setError('...');
    } finally {
      if (!silent) setIsLoading(false);
    }
  }, []);

  // Carga inicial
  useEffect(() => {
    void loadData();
    hasLoadedRef.current = true;
  }, [loadData]);

  // Refresh ao retornar a tela
  useIonViewWillEnter(() => {
    if (hasLoadedRef.current) {
      void loadData(true); // silent refresh
    }
  });
};
```

O parametro `silent` controla se o loading skeleton e exibido. Na carga inicial (`useEffect`), `silent = false` exibe skeleton. Ao retornar via `useIonViewWillEnter`, `silent = true` mantem dados existentes visiveis.

O `hasLoadedRef` evita double-fetch na primeira renderizacao (quando `useEffect` e `useIonViewWillEnter` disparam simultaneamente).

### Modelos de Dados

Nenhuma alteracao em modelos de dados. Todos os tipos existentes (`PaymentNotification`, `PurchaseInvoice`, `BudgetSummary`, `Category`, `PaymentMethod`, etc.) permanecem inalterados.

### Endpoints de API

Nenhum endpoint novo. Serao reutilizados os endpoints existentes:

- `GET /payments/notifications` — Tab1
- `GET /payments/methods/summary?month=` — Tab1 (cartoes)
- `GET /installments/projection` — Tab1 (parcelas)
- `GET /purchases/invoices` — Tab2
- `GET /budgets/summary?month=` — BudgetPage
- `GET /categories` — CategoriesPage
- `GET /payments/methods` + `GET /holders` — PaymentMethodsPage
- `GET /purchases/invoice/:id` ou `GET /payments/notifications/:id` — PurchaseDetail

## Pontos de Integracao

Nenhuma integracao externa nova. A solucao e puramente client-side, utilizando hooks do framework Ionic ja presente no projeto.

**Consideracao importante:** O `useIonViewWillEnter` so dispara em componentes diretamente mapeados por rotas do `IonRouterOutlet`. Componentes filhos (como `BudgetSummaryCard` dentro de Tab1) nao recebem este evento — o refresh deles e tratado pelo componente pai que repassa novos dados via props ou re-executa a funcao de load que atualiza o state compartilhado.

## Abordagem de Testes

### Testes Unitarios

- **Cada pagina modificada:** Verificar que `useIonViewWillEnter` e registrado e chama a funcao de reload.
- **Silent refresh:** Testar que ao chamar `loadData(true)`, `isLoading` nao e setado para `true` e dados anteriores permanecem visiveis.
- **Erro em silent mode:** Testar que erro durante silent refresh nao substitui dados existentes por tela de erro.
- **hasLoadedRef:** Testar que na primeira renderizacao, o refresh via `useIonViewWillEnter` nao causa double-fetch.

### Testes E2E

- **Fluxo completo com Playwright:**
  1. Navegar para Tab1, verificar lista de compras.
  2. Ir para ManualEntryPage, inserir gasto.
  3. Voltar para Tab1, verificar que novo gasto aparece sem refresh manual.
  4. Verificar que scroll position e mantida (se havia scroll antes).

- **Fluxo de delete:**
  1. Tab2, excluir nota fiscal.
  2. Navegar para Tab1 e voltar para Tab2, verificar que item excluido nao reaparece.

- **Fluxo de edicao:**
  1. Tab1, abrir PurchaseDetail, editar categoria.
  2. Voltar para Tab1, verificar que categoria atualizada aparece na lista.

## Sequenciamento de Desenvolvimento

### Ordem de Construcao

1. **Tab1 + Tab2 (paginas de tabs)** — Sao as telas principais e onde o problema e mais visivel. Validar o padrao de silent refresh + `useIonViewWillEnter` nessas duas telas primeiro.
2. **BudgetPage** — Tela com dados derivados (totais por categoria). Aplicar o mesmo padrao.
3. **CategoriesPage + PaymentMethodsPage** — Telas de configuracao. Mesmo padrao, menor complexidade.
4. **PurchaseDetail** — Pagina de detalhe, aplica o padrao para refresh ao retornar.
5. **BudgetSummaryCard** — Componente filho da Tab1. O refresh e delegado pelo pai (Tab1 ja recarrega os dados que o card consome).
6. **Testes unitarios** — Para cada pagina modificada.
7. **Testes E2E** — Fluxos completos de insert/update/delete com verificacao de refresh.

### Dependencias Tecnicas

- `@ionic/react` >= 8.x (ja presente como `^8.5.0`) — `useIonViewWillEnter` esta disponivel.
- Nenhuma infraestrutura ou dependencia nova necessaria.

## Monitoramento e Observabilidade

Nao se aplica. Esta funcionalidade e puramente client-side e nao requer metricas de backend adicionais. A validacao de sucesso sera feita via testes E2E e feedback do usuario.

## Consideracoes Tecnicas

### Decisoes Principais

1. **`useIonViewWillEnter` vs event bus/context:** Escolhido `useIonViewWillEnter` por ser nativo do Ionic, ja usado no projeto (ScannerPage), sem adicionar complexidade ou dependencias. Cada tela e responsavel pelo proprio refresh.

2. **Silent refresh vs optimistic update:** Escolhido silent refresh (re-fetch do servidor) por ser mais simples e confiavel. Optimistic updates foram explicitamente excluidos do escopo no PRD.

3. **`hasLoadedRef` para evitar double-fetch:** Na montagem inicial, tanto `useEffect` quanto `useIonViewWillEnter` podem disparar. O ref garante que o `useIonViewWillEnter` so faca refresh a partir da segunda visita.

4. **Sem TanStack Query:** Apesar de ser a solucao moderna recomendada para server state, adicionaria uma dependencia significativa e exigiria refactoring de todos os services. O padrao com hooks Ionic resolve o problema com mudancas minimas.

### Riscos Conhecidos

1. **Stale state em `useIonViewWillEnter`:** Ha issues reportados no Ionic (#23388) sobre state stale dentro do callback. Mitigacao: usar `useCallback` com dependencias corretas e refs para valores que precisam ser current.

2. **Performance em Tab1:** Tab1 faz 3 fetches paralelos (notificacoes, cartoes, projecao). Em silent refresh, os 3 serao re-executados toda vez que a tab fica visivel. Mitigacao: como sao chamadas leves e o backend e local/rapido, o impacto e aceitavel. Se necessario futuramente, pode-se adicionar debounce ou cache por tempo.

3. **Scroll position em `IonContent`:** O Ionic preserva scroll position em tabs cacheadas naturalmente. O silent refresh (que nao altera `isLoading`) nao deve causar re-render que resete o scroll, pois os dados sao substituidos no state sem exibir skeleton.

### Conformidade com Skills Padroes

- **executar-task** — Cada tarefa gerada a partir desta tech spec deve seguir o workflow padrao com review automatico.
- **executar-review** — Code review apos implementacao completa.
- **executar-qa** — QA com Playwright para validar fluxos E2E.

### Arquivos relevantes e dependentes

**Frontend (controlai-frontend/src/):**

- `pages/Tab1.tsx` — Tela principal, 3 funcoes de load
- `pages/Tab2.tsx` — Lista de purchase invoices
- `pages/BudgetPage.tsx` — Orcamento mensal
- `pages/CategoriesPage.tsx` — Lista de categorias
- `pages/PaymentMethodsPage.tsx` — Lista de metodos de pagamento
- `pages/PurchaseDetail.tsx` — Detalhe de compra/notificacao
- `components/BudgetSummaryCard.tsx` — Card de resumo de orcamento (filho de Tab1)
- `pages/ScannerPage.tsx` — Referencia: ja usa `useIonViewWillEnter`
- `context/InvoiceProcessingContext.tsx` — Context existente com `setReloadFn` (pode ser mantido para reload via toast de sucesso)
