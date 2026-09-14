# Tarefa 5.0: Ficha de loja e submissão — App Store Connect

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Preencher a ficha de loja completa do ControlAI no App Store Connect e submeter o build iOS já existente (via Appflow) para revisão da Apple, usando a política de privacidade (Tarefa 3.0), os screenshots (Tarefa 4.0) e a conta de revisor (Tarefa 1.0).

<skills>
### Conformidade com Skills Padrões

- Nenhuma skill de código se aplica diretamente — tarefa de configuração manual em dashboard externo.
</skills>

<requirements>
- PRD `Funcionalidades Principais > 1. Ficha de loja`: nome, descrição curta e longa, ícone, categoria, screenshots, política de privacidade, classificação etária.
- PRD `Funcionalidades Principais > 2. Conformidade`, requisitos 5–7: nenhum link/menção a pagamento externo; conta de demonstração disponível; formulário de App Privacy preenchido corretamente.
- PRD `Funcionalidades Principais > 3. Processo de submissão`, requisitos 8–10: submissão a partir do artefato Appflow; status acompanhável; registro de motivo em caso de rejeição.
- Restrição: guideline 3.1.1 da Apple sobre compras externas — o app não deve mencionar nem direcionar para o checkout Kiwify.
</requirements>

## Subtarefas

- [ ] 5.1 Criar/configurar o app no App Store Connect (nome, bundle ID `br.com.nomar.controlai`, categoria "Finanças").
- [ ] 5.2 Preencher descrição curta e longa, palavras-chave, e fazer upload dos screenshots da Tarefa 4.0.
- [ ] 5.3 Referenciar a URL da política de privacidade (Tarefa 3.0) e preencher o formulário de App Privacy (dados coletados: informações financeiras, e-mail, dados de uso).
- [ ] 5.4 Preencher a classificação etária e demais campos obrigatórios de conformidade.
- [ ] 5.5 Preencher App Review Information com as credenciais da conta de revisor (Tarefa 1.0) e um roteiro de navegação para as telas principais.
- [ ] 5.6 Fazer upload do build iOS mais recente (via Appflow/TestFlight) e vinculá-lo à versão em revisão.
- [ ] 5.7 Confirmar, antes de enviar, que nenhum campo da ficha menciona ou direciona para o checkout Kiwify.
- [ ] 5.8 Submeter a versão para revisão da Apple.

## Detalhes de Implementação

Ver Tech Spec `Sequenciamento de Desenvolvimento`, etapas 5 e 7, e `Pontos de Integração` (App Store Connect). Trabalho de configuração manual, sem código.

## Critérios de Sucesso

- Ficha de loja completa e sem erros de preenchimento no App Store Connect.
- Build iOS enviado e em status "Em Revisão" (Waiting for Review / In Review).
- Nenhum campo da ficha ou do app menciona pagamento externo.

## Testes da Tarefa

- [ ] Teste manual: revisão completa da ficha antes do envio (checklist de campos obrigatórios).
- [ ] Teste manual: login com a conta de revisor (Tarefa 1.0) simulando o fluxo que o revisor da Apple fará.
- [ ] Verificação manual: nenhuma menção a "Kiwify", "checkout", "pagamento" ou "comprar" em qualquer campo da ficha.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- Nenhum arquivo de código — configuração externa no App Store Connect.
- Depende de: Tarefa 1.0 (conta de revisor), Tarefa 3.0 (política de privacidade), Tarefa 4.0 (screenshots), build iOS já existente (Appflow).
