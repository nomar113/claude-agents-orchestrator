# Tarefa 10.0: Frontend — Roteamento e navegacao

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Adicionar a rota para `CategoriesPage` no `App.tsx` e criar um ponto de acesso na navegacao do app (tab de configuracoes ou similar). Garantir que a tela de categorias esta acessivel em no maximo 2 toques.

<skills>
### Conformidade com Skills Padroes

- **`ionic-design`**: Roteamento com IonReactRouter, navegacao por tabs.
- **`clean-code`**: Rotas claras e consistentes.
</skills>

<requirements>
- Adicionar rota `/categories` no App.tsx (IonRouterOutlet)
- Criar ponto de acesso na tab de configuracoes (Tab3 ou equivalente)
- Link/botao para "Gerenciar Categorias" visivel e acessivel
- Navegacao consistente com o padrao do app (PaymentMethods esta acessivel de forma similar)
- Maximo 2 toques para chegar a tela de categorias
</requirements>

## Subtarefas

- [ ] 10.1 Adicionar rota para CategoriesPage em `App.tsx`
- [ ] 10.2 Adicionar link/botao de acesso em Tab3 ou tela de configuracoes
- [ ] 10.3 Verificar navegacao de ida e volta (back button)
- [ ] 10.4 Escrever testes

## Detalhes de Implementacao

Verificar como `PaymentMethodsPage` esta registrada no roteamento e seguir o mesmo padrao.

O App.tsx usa React Router 5 com `IonRouterOutlet` e navegacao por tabs.

## Criterios de Sucesso

- Rota `/categories` funcional
- Tela acessivel em no maximo 2 toques a partir da tab principal
- Back button funciona corretamente
- Build passa sem erros

## Testes da Tarefa

- [ ] Teste unitario: rota `/categories` renderiza CategoriesPage
- [ ] Verificacao manual: navegacao ida e volta funciona
- [ ] Verificacao manual: acessivel em 2 toques

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/App.tsx` — Sera modificado (nova rota)
- `controlai-frontend/src/pages/Tab3.tsx` — Sera modificado (link de acesso)
- `controlai-frontend/src/pages/CategoriesPage.tsx` — Pagina criada na task 7
