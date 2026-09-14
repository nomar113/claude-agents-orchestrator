# Tarefa 6.0: Ficha de loja e submissão — Google Play Console

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Preencher a ficha de loja completa do ControlAI no Google Play Console e submeter o build Android já produzido pelo Appflow (PRD "Build Android no Appflow") para a trilha de produção, usando a política de privacidade (Tarefa 3.0), os screenshots (Tarefa 4.0), o ícone (Tarefa 2.0) e a conta de revisor (Tarefa 1.0).

<skills>
### Conformidade com Skills Padrões

- Nenhuma skill de código se aplica diretamente — tarefa de configuração manual em dashboard externo.
</skills>

<requirements>
- PRD `Funcionalidades Principais > 1. Ficha de loja`: nome, descrição curta e longa, ícone, categoria, screenshots, política de privacidade, classificação etária.
- PRD `Funcionalidades Principais > 2. Conformidade`, requisitos 5–7: nenhum link/menção a pagamento externo; conta de demonstração disponível; Data Safety preenchido corretamente.
- PRD `Funcionalidades Principais > 3. Processo de submissão`, requisitos 8–10: submissão a partir do artefato Appflow; status acompanhável; registro de motivo em caso de rejeição.
- Tech Spec `Riscos Conhecidos`: Data Safety deve declarar a categoria "Informações financeiras" e detalhar terceiros/SDKs corretamente (ex.: Resend; Kiwify não deve aparecer como coletor de dados do app).
</requirements>

## Subtarefas

- [ ] 6.1 Confirmar que o app `br.com.nomar.controlai` já existe no Google Play Console (pré-requisito também levantado no PRD "Build Android no Appflow"); criar manualmente se ainda não existir.
- [ ] 6.2 Preencher nome, descrição curta e longa, categoria ("Finanças") e fazer upload do ícone (Tarefa 2.0) e dos screenshots (Tarefa 4.0).
- [ ] 6.3 Referenciar a URL da política de privacidade (Tarefa 3.0) e preencher o formulário Data Safety (categoria "Informações financeiras", terceiros como Resend, sem menção à Kiwify como coletor de dados do app).
- [ ] 6.4 Preencher o Content rating (questionário de classificação etária) e demais campos obrigatórios do App content.
- [ ] 6.5 Preencher as instruções de acesso para o revisor (App content > "Acesso ao app") com as credenciais da conta de revisor (Tarefa 1.0).
- [ ] 6.6 Promover o build Android da trilha de testes internos (já configurada no PRD "Build Android no Appflow") para a trilha de produção, ou fazer upload direto de um novo AAB assinado via Appflow.
- [ ] 6.7 Confirmar, antes de enviar, que nenhum campo da ficha menciona ou direciona para o checkout Kiwify.
- [ ] 6.8 Submeter a versão para revisão do Google.

## Detalhes de Implementação

Ver Tech Spec `Sequenciamento de Desenvolvimento`, etapas 6 e 7, e `Pontos de Integração` (Google Play Console). Trabalho de configuração manual, sem código.

## Critérios de Sucesso

- Ficha de loja completa e sem erros de preenchimento no Google Play Console.
- Build Android enviado à trilha de produção e em status "Em revisão".
- Data Safety e Content rating preenchidos corretamente, sem menção à Kiwify como coletora de dados.

## Testes da Tarefa

- [ ] Teste manual: revisão completa da ficha antes do envio (checklist de campos obrigatórios, incluindo Data Safety e Content rating).
- [ ] Teste manual: login com a conta de revisor (Tarefa 1.0) simulando o fluxo que o revisor do Google fará.
- [ ] Verificação manual: nenhuma menção a "Kiwify", "checkout", "pagamento" ou "comprar" em qualquer campo da ficha.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- Nenhum arquivo de código — configuração externa no Google Play Console.
- Depende de: Tarefa 1.0 (conta de revisor), Tarefa 2.0 (ícone), Tarefa 3.0 (política de privacidade), Tarefa 4.0 (screenshots), build Android já existente (PRD "Build Android no Appflow").
