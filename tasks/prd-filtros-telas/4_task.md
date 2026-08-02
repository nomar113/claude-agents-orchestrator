# Tarefa 4.0: Frontend - Componente MonthSelector reutilizavel

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar um componente `MonthSelector` reutilizavel que permite navegar mes a mes com setas (anterior/proximo), exibindo o nome do mes e ano. Extraido do padrao ja existente no `BudgetPage.tsx`.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo completo da skill para implementacao.
- `executar-review` / `task-reviewer` — Review automatico apos conclusao.
</skills>

<requirements>
- RF-1.1: Exibir nome do mes e ano (ex: "Maio 2026").
- RF-1.2: Botoes de seta para mes anterior e proximo.
- RF-1.6: Componente reutilizavel entre Tab1 e Tab2.
- Props: `month` (YYYY-MM), `onChange` (callback com novo YYYY-MM).
- Estilo visual consistente com o month-nav do BudgetPage.
- Acessibilidade: navegavel por teclado, aria-labels nos botoes.
</requirements>

## Subtarefas

- [ ] 4.1 Criar componente `MonthSelector.tsx` em `src/components/`.
- [ ] 4.2 Implementar props: `month: string` (YYYY-MM) e `onChange: (month: string) => void`.
- [ ] 4.3 Implementar logica de prev/next com transicao de ano (dez→jan, jan→dez).
- [ ] 4.4 Estilizar com CSS seguindo o padrao visual do `budget-month-nav` do BudgetPage.
- [ ] 4.5 Escrever testes unitarios.

## Detalhes de Implementacao

**Referencia de padrao existente:** `BudgetPage.tsx` linhas 57-59 (estado), 121-129 (logica prev/next), 246-254 (JSX do seletor).

O componente deve ser controlado (controlled component): recebe `month` e chama `onChange` ao navegar. A logica de estado fica no consumidor (Tab1/Tab2 via FilterContext).

## Criterios de Sucesso

- Renderiza "Maio 2026" quando `month="2026-05"`.
- Clicar seta esquerda chama `onChange("2026-04")`.
- Clicar seta direita chama `onChange("2026-06")`.
- Transicao dez/2026 → jan/2027 funciona corretamente.
- Transicao jan/2026 → dez/2025 funciona corretamente.
- Visual consistente com BudgetPage.

## Testes da Tarefa

- [ ] Teste unitario: renderiza mes e ano corretos.
- [ ] Teste unitario: click prev chama onChange com mes anterior.
- [ ] Teste unitario: click next chama onChange com mes seguinte.
- [ ] Teste unitario: transicao dezembro → janeiro (incrementa ano).
- [ ] Teste unitario: transicao janeiro → dezembro (decrementa ano).
- [ ] Teste unitario: aria-labels presentes nos botoes.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `/controlai-frontend/src/pages/BudgetPage.tsx` (referencia de padrao, linhas 57-59, 121-129, 246-254)
- `/controlai-frontend/src/pages/BudgetPage.css` (estilos do budget-month-nav)
