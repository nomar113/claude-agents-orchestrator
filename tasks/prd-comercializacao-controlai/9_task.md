# Tarefa 9.0: Frontend — remoção do fluxo de cadastro público

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Remover a rota `/register` e qualquer link para ela no app, já que contas novas passam a nascer apenas da compra na Kiwify (Tarefa 5.0). Espelha no frontend a decisão já implementada no backend na Tarefa 7.0.

<skills>
### Conformidade com Skills Padrões

- `ionic-design` — ajuste de rotas e da tela de login seguindo os padrões visuais já usados no restante do app.
</skills>

<requirements>
- Decisão da clarificação de techspec: desativar registro público no app (frontend).
- Tech Spec `Arquivos Relevantes`: `App.tsx` (remover rota `/register`), `LoginPage.tsx` (remover link de cadastro).
</requirements>

## Subtarefas

- [ ] 9.1 Remover a rota `exact path="/register"` de `App.tsx` e o import de `RegisterPage`.
- [ ] 9.2 Remover o link/botão "Criar conta" (ou equivalente) da `LoginPage.tsx`.
- [ ] 9.3 Decidir com o usuário se o arquivo `RegisterPage.tsx` e seus testes devem ser deletados ou apenas desconectados do roteamento (recomendação: deletar, já que o backend não aceita mais o cadastro — evita código morto).
- [ ] 9.4 Revisar se `RegisterPage.test.tsx` e qualquer outro teste que dependa da rota `/register` precisa ser removido/atualizado.

## Detalhes de Implementação

Ver Tech Spec `Arquivos Relevantes`. Esta é uma tarefa de remoção — não deve introduzir nenhuma funcionalidade nova.

## Critérios de Sucesso

- A rota `/register` não existe mais no app (navegar para ela redireciona para `/login` ou não resolve nenhuma página).
- Nenhum ponto do app oferece um caminho de autocadastro.
- A suíte de testes do frontend passa sem referências a uma tela de registro inexistente.

## Testes da Tarefa

- [ ] Teste de integração/roteamento confirmando que `/register` não renderiza mais `RegisterPage`.
- [ ] Suíte de testes existente (`npm run test.unit`) passando após a remoção, sem testes órfãos referenciando `RegisterPage`.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/App.tsx` (modificado)
- `src/pages/LoginPage.tsx` (modificado)
- `src/pages/RegisterPage.tsx`, `src/pages/RegisterPage.css`, `src/pages/RegisterPage.test.tsx` (remover ou desconectar)
- Depende de: Tarefa 7.0 (backend já não aceita mais o cadastro)
