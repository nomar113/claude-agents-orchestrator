# Tarefa 7.0: Frontend — Tela de gerenciamento de categorias

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar a pagina `CategoriesPage.tsx` com CRUD completo de categorias, seguindo o padrao visual da `PaymentMethodsPage`. Inclui listagem, criacao, edicao e exclusao com confirmacao.

<skills>
### Conformidade com Skills Padroes

- **`ionic-design`**: Usar componentes Ionic nativos (IonList, IonItem, IonButton, IonInput, IonAlert, IonToast).
- **`clean-code`**: Componentes focados, estado local com useState.
</skills>

<requirements>
- Tela com lista de categorias em ordem alfabetica
- Botao para criar nova categoria (abre formulario inline ou modal)
- Acao de editar em cada item da lista
- Acao de excluir com dialogo de confirmacao (usar ConfirmDialog existente)
- Exibir erro 409 quando tentar excluir categoria vinculada a compras (toast com mensagem)
- Exibir erro 409 quando tentar criar nome duplicado (toast com mensagem)
- Toast de sucesso ao criar, editar e excluir
- Visual consistente com PaymentMethodsPage
</requirements>

## Subtarefas

- [ ] 7.1 Criar `src/pages/CategoriesPage.tsx` com listagem de categorias
- [ ] 7.2 Implementar formulario de criacao de categoria
- [ ] 7.3 Implementar edicao inline ou modal
- [ ] 7.4 Implementar exclusao com confirmacao e tratamento de erro 409
- [ ] 7.5 Criar `src/pages/CategoriesPage.css` com estilos
- [ ] 7.6 Escrever testes unitarios do componente

## Detalhes de Implementacao

Referencia visual e de padrao: `src/pages/PaymentMethodsPage.tsx` e `src/pages/PaymentMethodsPage.css`.

Usar `categoryService.ts` (task 6) para todas as chamadas HTTP.

Usar `ConfirmDialog` existente em `src/components/ConfirmDialog.tsx` para confirmacao de exclusao.

## Criterios de Sucesso

- CRUD completo funcional na tela
- Erros 409 tratados com mensagens amigaveis
- Visual consistente com o resto do app
- Build passa sem erros

## Testes da Tarefa

- [ ] Teste unitario: renderiza lista de categorias
- [ ] Teste unitario: criacao de categoria chama servico correto
- [ ] Teste unitario: exclusao bloqueada exibe mensagem de erro
- [ ] Verificacao manual: visual consistente com PaymentMethodsPage

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/pages/PaymentMethodsPage.tsx` — Referencia visual e de padrao
- `controlai-frontend/src/pages/PaymentMethodsPage.css` — Referencia de estilos
- `controlai-frontend/src/components/ConfirmDialog.tsx` — Componente reutilizavel
- `controlai-frontend/src/services/categoryService.ts` — Servico HTTP (task 6)
