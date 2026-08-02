# Tarefa 3.0: Frontend - FilterContext (estado de filtros por tela)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar um React Context (`FilterContext`) que centraliza o estado de filtros para Tab1 e Tab2. Cada tela tem seu proprio `FilterState` independente, que persiste enquanto o app estiver aberto. O context fornece funcoes de update parcial e reset por tela.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo completo da skill para implementacao.
- `executar-review` / `task-reviewer` — Review automatico apos conclusao.
</skills>

<requirements>
- RF-4.1: Filtros devem persistir ao sair e retornar a uma tela na mesma sessao.
- RF-4.2: Filtros resetam ao fechar e reabrir o app.
- RF-4.3: Persistencia independente entre telas.
- Estado inicial: mes corrente, categoria null ("Todas"), mode "month", page 0.
- Funcoes `updateTab1`, `updateTab2`, `resetTab1`, `resetTab2`.
- O context deve ser provider no nivel do App (wrapping tabs).
</requirements>

## Subtarefas

- [ ] 3.1 Criar tipo `FilterState` e `FilterContextType` conforme techspec.md.
- [ ] 3.2 Criar `FilterContext.tsx` em `src/context/` com provider e hook `useFilter`.
- [ ] 3.3 Adicionar `FilterProvider` no componente App, envolvendo as tabs.
- [ ] 3.4 Escrever testes unitarios.

## Detalhes de Implementacao

Consultar `techspec.md` secao "Interfaces Principais" para os tipos `FilterState` e `FilterContextType`.

**Referencia de padrao existente:** `InvoiceProcessingContext.tsx` — seguir o mesmo padrao de context + provider + custom hook.

## Criterios de Sucesso

- `useFilter()` retorna estado de tab1 e tab2 independentes.
- `updateTab1({ month: '2026-03' })` atualiza apenas o mes da tab1 sem afetar tab2.
- `resetTab1()` restaura tab1 ao estado inicial (mes corrente, categoria null).
- O context sobrevive a navegacao entre tabs (Ionic mantém tabs montadas).
- Estado inicial usa mes corrente no formato "YYYY-MM".

## Testes da Tarefa

- [ ] Teste unitario: estado inicial correto (mes corrente, categoria null, mode "month").
- [ ] Teste unitario: `updateTab1` atualiza apenas tab1.
- [ ] Teste unitario: `updateTab2` atualiza apenas tab2.
- [ ] Teste unitario: update parcial preserva campos nao alterados.
- [ ] Teste unitario: `resetTab1` restaura estado inicial.
- [ ] Teste unitario: `resetTab2` restaura estado inicial.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `/controlai-frontend/src/context/InvoiceProcessingContext.tsx` (referencia de padrao)
- `/controlai-frontend/src/App.tsx` (onde adicionar o provider)
