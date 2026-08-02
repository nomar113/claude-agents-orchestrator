# Review: Task 7.0 - SuggestionsPage + CSS

**Revisor**: AI Code Reviewer
**Data**: 2026-05-23
**Arquivo da task**: 7_task.md
**Status**: APROVADO COM OBSERVACOES

## Resumo

A task 7.0 implementou a pagina `SuggestionsPage.tsx` e seu CSS correspondente no projeto `controlai-frontend`. A implementacao cobre os tres estados (loading skeleton, lista de sugestoes, estado vazio), o fallback de busca via API (RF22), a navegacao com `location.state` para associacao manual (RF20) e com sugestao (RF21), e o suporte a dark mode. O codigo esta funcional, TypeScript compila e o build passa. Existem, porem, alguns pontos que merecem atencao: a rota nao foi registrada no `App.tsx` (escopo de outra task, mas vale confirmar), funcoes utilitarias estao duplicadas, e ha inline styles que poderiam ser movidos para CSS.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `src/pages/SuggestionsPage.tsx` | Problemas | 5 |
| `src/pages/SuggestionsPage.css` | OK | 0 |

## Problemas Encontrados

### Problemas Criticos

Nenhum problema critico encontrado.

### Problemas Major

**M1. Rota nao registrada no App.tsx**
- **Arquivo**: `src/App.tsx`
- **Descricao**: A Tech Spec indica explicitamente que `App.tsx` deve ser modificado para incluir a rota `/suggestions/:invoiceId`. Atualmente, o `SuggestionsPage` nao tem rota registrada, o que significa que a pagina nao e acessivel. Embora isso possa estar planejado para outra task (task 8.0), a task 7.0 deveria pelo menos ter validado se a rota existe ou documentado essa dependencia.
- **Nota**: Verificar se a task 8.0 cobre esse registro. Se nao, e necessario adicionar:
```tsx
import SuggestionsPage from './pages/SuggestionsPage';
// ...
<Route exact path="/suggestions/:invoiceId">
  <SuggestionsPage />
</Route>
```

**M2. Funcoes utilitarias duplicadas (`fmt`, `fmtDateFull`)**
- **Arquivo**: `src/pages/SuggestionsPage.tsx`, linhas 29-41
- **Descricao**: As funcoes `fmt` e `fmtDateFull` sao identicas as definidas em `PurchaseDetail.tsx` (linhas 48-60). O mesmo `fmt` aparece em pelo menos 8 outros arquivos do projeto. Isso viola o principio DRY e aumenta custo de manutencao.
- **Correcao sugerida**: Extrair para um modulo utilitario compartilhado, por exemplo `src/utils/format.ts`:
```typescript
// src/utils/format.ts
export const formatCurrency = (value: number) =>
  new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value);

export const formatDateFull = (dateString: string) => {
  const dt = new Date(dateString);
  const months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
  const day = dt.getDate();
  const mon = months[dt.getMonth()];
  const year = dt.getFullYear();
  const hh = String(dt.getHours()).padStart(2, '0');
  const mm = String(dt.getMinutes()).padStart(2, '0');
  return `${day} ${mon} ${year}, ${hh}:${mm}`;
};
```
- **Nota**: Este e um problema pre-existente no projeto, nao introduzido por esta task. Porem, ao criar um arquivo novo, seria a oportunidade ideal para iniciar a centralizacao.

**M3. Ausencia de testes unitarios**
- **Arquivo**: `src/pages/SuggestionsPage.test.tsx` (inexistente)
- **Descricao**: A task define em seus criterios: "SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA". Outras paginas do projeto (PurchaseDetail, CategoriesPage, PaymentMethodsPage, Tab1, Tab2, BudgetPage) possuem arquivos `.test.tsx`. A SuggestionsPage nao possui testes.
- **Correcao sugerida**: Criar `SuggestionsPage.test.tsx` com testes para os tres estados (loading, lista com sugestoes, estado vazio) e para as navegacoes (tap em card, associacao manual).

### Problemas Minor

**m1. Inline styles nos icones e skeletons**
- **Arquivo**: `src/pages/SuggestionsPage.tsx`, linhas 167, 182, 186-190, 222, 257
- **Descricao**: Ha 9 ocorrencias de `style={{ ... }}` inline no componente. Os icones usam `style={{ color: '#FFB74D', fontSize: 28 }}` e os skeletons usam inline styles para dimensoes. Isso dificulta manutencao e quebra consistencia com o CSS que usa classes `sg-*`.
- **Correcao sugerida**: Mover para classes CSS dedicadas. Exemplo:
```css
.sg-hero-icon ion-icon { color: #FFB74D; font-size: 28px; }
.sg-card-icon ion-icon { color: #4285F4; font-size: 20px; }
.sg-empty-icon ion-icon { color: rgba(255,255,255,0.4); font-size: 32px; }
```

**m2. Funcao `getOriginLabel` com mapeamento hardcoded**
- **Arquivo**: `src/pages/SuggestionsPage.tsx`, linhas 50-62
- **Descricao**: O mapeamento de origens (nubank, inter, c6_bank, etc.) esta hardcoded dentro do componente. Se novas origens forem adicionadas, sera necessario modificar este arquivo. Considerar extrair para um arquivo de constantes ou um mapeamento centralizado.
- **Impacto**: Baixo no momento, mas pode crescer com novas integracoes.

## Destaques Positivos

1. **Fallback bem implementado (RF22)**: O useEffect para buscar dados do invoice via API quando `location.state` esta ausente esta correto, com cleanup via `cancelled` flag para evitar atualizacoes de estado apos unmount.

2. **Tratamento de cancelamento nos useEffect**: Ambos os effects utilizam o padrao de `cancelled` flag no cleanup, prevenindo memory leaks e atualizacoes de estado em componentes desmontados.

3. **Navegacao com location.state (RF20/RF21)**: Os dados passados via `location.state` correspondem exatamente ao que o PRD especifica para ambos os cenarios (associacao manual e associacao com sugestao).

4. **CSS bem organizado**: O arquivo CSS segue corretamente o prefixo `sg-` conforme especificado na task, esta bem estruturado por secoes, e utiliza variaveis de opacidade/cores consistentes com o restante do projeto.

5. **Skeleton loading**: O skeleton loading tanto para o hero (invoice) quanto para a lista de sugestoes oferece boa experiencia de carregamento.

6. **Uso de `<button>` para cards**: Os cards de sugestao usam `<button>` semantico em vez de `<div>` com onClick, o que e correto para acessibilidade.

## Conformidade com Padroes

| Padrao | Status |
|--------|--------|
| Padroes de Codigo | Problemas |
| TypeScript/Node.js | OK |
| React | OK |
| Testes | Problemas |

**Detalhes:**
- **Padroes de Codigo**: Funcoes utilitarias duplicadas (DRY). Inline styles em vez de classes CSS. Nomenclatura `fmt` e `fmtDelta` usa abreviacoes (padrao do projeto, nao exclusivo desta task).
- **TypeScript**: Compila sem erros. Tipos bem definidos (`LocationState`, `SuggestionResponse`).
- **React**: Hooks utilizados corretamente. Cleanup de effects presente. Componente funcional com padrao do projeto.
- **Testes**: Ausentes. Outras paginas do projeto possuem testes.

## Recomendacoes

1. **[Prioritaria]** Criar testes unitarios para `SuggestionsPage.tsx` cobrindo os tres estados de renderizacao e as interacoes de navegacao.
2. **[Prioritaria]** Confirmar se a rota no `App.tsx` sera adicionada na task 8.0 ou se deveria ter sido parte desta task.
3. **[Melhoria]** Mover inline styles dos icones e skeletons para classes CSS, mantendo consistencia com o restante do arquivo.
4. **[Melhoria futura]** Extrair `fmt` e `fmtDateFull` para um modulo utilitario compartilhado (`src/utils/format.ts`) e refatorar todos os arquivos que duplicam essas funcoes.

## Veredito

A implementacao da `SuggestionsPage` atende os requisitos funcionais do PRD (RF10-RF22) de forma correta e o codigo e funcional. Os tres estados (loading, lista, vazio) estao implementados, a navegacao com `location.state` respeita a especificacao, e o fallback via API funciona adequadamente.

Os dois pontos de atencao mais relevantes sao: (1) a ausencia de testes unitarios, que e uma exigencia explicita da task, e (2) a confirmacao de que a rota sera registrada no `App.tsx`. Nenhum desses pontos e bloqueante para o fluxo de desenvolvimento, desde que sejam endereçados antes da entrega final da feature.

**Proximo passo**: Criar os testes em `SuggestionsPage.test.tsx` e confirmar o registro da rota.
