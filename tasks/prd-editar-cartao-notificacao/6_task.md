# Tarefa 6.0: Polish — Acessibilidade, copy, back nativo e verificacao manual nos 3 cenarios

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Fechar a feature com os ajustes de acessibilidade, copy e back nativo descritos no PRD, garantir a propagacao do estado para as listas/relatorios dependentes e validar manualmente o fluxo nos 3 cenarios principais. Esta tarefa nao introduz novas regras de negocio; ela consolida qualidade.

<skills>
### Conformidade com Skills Padroes

- **ionic-design** — back nativo, drag handle, dim overlay, tamanho de alvo de toque.
- **frontend-design** / **ui-ux-pro-max** — contraste AA, hierarquia visual, micro-momentos com accent #FF4D6D, copy alinhada ao tom do produto.
- **clean-code** — refatorar pequenos pontos pendentes que tenham surgido nas Tarefas 4.0/5.0.
</skills>

<requirements>
- Labels VoiceOver/TalkBack: "Editar cartao" (linha do Detalhe), "Selecionar cartao" (sheet), "Selecionar sub-cartao" (2a tela).
- Todos os alvos de toque envolvidos na feature >= 44x44 px.
- Contraste de texto AA (>= 4.5:1) em estados normais, selecionado e desabilitado.
- Botao back nativo (Android e iOS) fecha o sheet sem alterar o cartao original.
- Loading visivel durante a operacao (sem bloquear o app por mais de 2s na rede 4G tipica).
- Propagacao em listas/relatorios: garantir que Tab1 (lista de compras) e BudgetPage recarreguem em `useIonViewWillEnter` apos retornar do Detalhe. Documentar no codigo (comentario unico curto **so** se nao for obvio) ou via ajuste no hook de carregamento ja existente, conforme padrao do projeto.
- Copy: revisar mensagens de erro e estados vazios alinhando ao tom do app.
- Verificacao manual obrigatoria nos 3 cenarios principais.
</requirements>

## Subtarefas

- [x] 6.1 Auditar labels de acessibilidade na linha Cartao e em todo o sheet; ajustar onde faltar.
- [x] 6.2 Auditar tamanhos de alvo de toque e contraste; ajustar CSS/componentes se necessario.
- [x] 6.3 Validar e ajustar (se preciso) o comportamento do botao back nativo no sheet.
- [x] 6.4 Garantir que Tab1 e BudgetPage recarregam ao voltar do Detalhe (usando `useIonViewWillEnter` ja padrao no projeto).
- [x] 6.5 Revisar copy de erros/loadings/mensagens.
- [ ] 6.6 Verificacao manual nos 3 cenarios: (a) cartao sem sub-cards, (b) cartao com sub-cards trocando para outro com sub-cards, (c) "Continuar sem sub-cartao". *(verificacao manual em dispositivo pelo usuario)*
- [x] 6.7 Atualizar (se necessario) os testes existentes para refletir copy/labels novas.

## Detalhes de Implementacao

Ver `prd.md` "Experiencia do Usuario" (diretrizes de UX) e `techspec.md` "Riscos Conhecidos" (cache no frontend; mitigacao via reload em telas dependentes).

## Criterios de Sucesso

- Leitor de tela narra corretamente "Editar cartao", "Selecionar cartao", "Selecionar sub-cartao".
- Back nativo fecha o sheet em ambos os passos (cartao e sub-cartao) sem persistir mudanca.
- Tab1 e BudgetPage refletem o novo cartao ao serem reabertas.
- Verificacao manual aprovada nos 3 cenarios.

## Testes da Tarefa

- [ ] Testes de unidade — atualizar quaisquer testes que dependam de copy ou labels alteradas em 6.5/6.1.
- [ ] Testes de integracao — verificar que o back nativo simulado fecha o sheet sem disparar `onSelect`.
- [ ] Verificacao manual (E2E informal) — registrar resultados dos 3 cenarios:
  - cartao sem sub-cards
  - cartao com sub-cards (troca para outro tambem com sub-cards)
  - "Continuar sem sub-cartao"

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/components/PaymentMethodSelector.tsx` (ajustes de label/aria)
- `src/components/PaymentMethodSelector.css` (ajustes de contraste/alvo de toque)
- `src/pages/PurchaseDetail.tsx` (label da affordance e mensagens)
- `src/pages/PurchaseDetail.css` (ajustes de UI da linha)
- `src/pages/Tab1.tsx` e `src/pages/BudgetPage.tsx` (verificar `useIonViewWillEnter` para reload — sem mudanca se ja padrao)
- Quaisquer arquivos de testes afetados por copy/labels
