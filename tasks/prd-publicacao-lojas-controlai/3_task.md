# Tarefa 3.0: Página de política de privacidade

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Criar uma página estática de política de privacidade no projeto `controlai-landing`, acessível publicamente por URL, para atender à exigência obrigatória de ambas as lojas (App Store e Google Play) de referenciar uma política de privacidade na ficha do app.

<skills>
### Conformidade com Skills Padrões

- `frontend-design` — qualidade visual e de legibilidade da página, consistente com o restante do site de vendas.
</skills>

<requirements>
- PRD `Funcionalidades Principais > 1. Ficha de loja`, requisito 3: deve existir uma política de privacidade pública e acessível por URL, referenciada na ficha de loja de ambas as plataformas.
- PRD `Funcionalidades Principais > 2. Conformidade`, requisito 7: o texto deve refletir corretamente quais dados são coletados e para quê (base para os formulários de App Privacy/Data Safety das Tarefas 5.0 e 6.0).
- Tech Spec `Arquitetura do Sistema`: página HTML estática, mesmo padrão sem framework do site de vendas já existente em `controlai-landing`.
</requirements>

## Subtarefas

- [ ] 3.1 Definir a URL/rota da página (ex.: `controlai-landing/privacidade.html`) dentro do site estático já existente.
- [ ] 3.2 Redigir o texto da política de privacidade cobrindo: quais dados são coletados (dados financeiros de cartões/faturas/compras, e-mail, dados de autenticação), como são usados, com quem são compartilhados (ex.: Resend para e-mail transacional) e como o usuário pode solicitar exclusão de conta/dados.
- [ ] 3.3 Aplicar as mesmas práticas de acessibilidade já usadas na landing page de vendas (contraste, marcação semântica, navegação por teclado).
- [ ] 3.4 Publicar a página junto com o site já hospedado e confirmar que a URL final é pública e estável.
- [ ] 3.5 Linkar a política de privacidade a partir da landing page de vendas (rodapé), para facilitar descoberta também fora das lojas.

## Detalhes de Implementação

Ver Tech Spec `Arquitetura do Sistema` (página de política de privacidade) e `Sequenciamento de Desenvolvimento`, etapa 2. Reaproveitar a estrutura/estilo já usados na landing page de vendas (Tarefa 10.0 do PRD comercialização).

## Critérios de Sucesso

- Página de política de privacidade publicada e acessível publicamente por URL estável, sem exigir login.
- Texto reflete corretamente a coleta/uso/compartilhamento real de dados do ControlAI.
- URL pronta para ser referenciada nas Tarefas 5.0 e 6.0.

## Testes da Tarefa

- [ ] Teste manual: URL da política de privacidade acessível publicamente (sem login) em desktop e mobile.
- [ ] Checagem de acessibilidade (Lighthouse/axe) sem erros críticos, mesmo padrão usado na landing page de vendas.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-landing/privacidade.html` (novo).
- Referência: demais páginas/estilos já existentes em `controlai-landing` (Tarefa 10.0 do PRD comercialização).
- Depende de: nenhuma outra tarefa deste PRD (pode ser feita em paralelo às Tarefas 1.0, 2.0 e 4.0).
