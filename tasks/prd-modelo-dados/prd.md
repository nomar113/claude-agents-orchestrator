# PRD: Reestruturacao do Modelo de Dados do ControlAI

## Visao Geral

O ControlAI e um aplicativo de financas pessoais que visa substituir uma planilha do Google Sheets usada pelo casal Ramon e Aline para controlar despesas de cartao de credito. O modelo de dados atual foi construido em torno de notas fiscais eletronicas (NFe) e notificacoes de pagamento, mas nao representa adequadamente os conceitos fundamentais da planilha: despesas com parcelas, categorias, cartoes de credito, verificacao manual e planejamento orcamentario.

Esta PRD define a reestruturacao do modelo de dados para que ele suporte todos os conceitos presentes na planilha. Este e o PRD fundacional -- todas as demais funcionalidades do sistema (importacao de historico, entrada manual, dashboard, gestao de cartoes, planejamento orcamentario) dependem deste modelo estar implementado.

## Objetivos

1. **Representar 100% dos conceitos da planilha** no modelo de dados: despesas, parcelas, categorias, cartoes, metodos de pagamento, flag de verificacao, receitas e planejamento orcamentario.
2. **Manter compatibilidade com o modelo atual** de payment_notifications e purchase_invoices, permitindo migracao incremental sem perda de dados.
3. **Suportar multi-usuario** desde o inicio, distinguindo despesas de Ramon e Aline e permitindo visao consolidada do casal.
4. **Permitir consultas eficientes por mes/fatura**, ja que a planilha e organizada por mes de referencia da fatura do cartao.
5. **Ser extensivel** para acomodar novos cartoes, categorias e metodos de pagamento sem alteracoes estruturais no banco de dados.

## Historias de Usuario

1. Como **Ramon**, eu quero registrar uma despesa com cartao de credito informando descricao, valor, cartao, categoria e numero de parcelas, para que eu tenha o mesmo controle que tenho na planilha.

2. Como **Aline**, eu quero ver minhas despesas separadas das do Ramon, mas tambem poder ver o consolidado do casal, para que cada um saiba quanto gastou individualmente.

3. Como **Ramon**, eu quero marcar uma despesa como verificada (conferida na fatura), para que eu saiba quais lancamentos ja foram conciliados com a fatura real do cartao.

4. Como **usuario**, eu quero que despesas parceladas gerem automaticamente os registros de cada parcela nos meses correspondentes, para que eu veja o impacto mensal correto sem precisar lancar manualmente cada parcela.

5. Como **Ramon**, eu quero categorizar despesas usando as mesmas categorias da planilha (Comida, Gastos Gerais, Carro, etc.), para que os relatorios reflitam a organizacao que ja uso.

6. Como **usuario**, eu quero cadastrar meus cartoes de credito com nome e ultimos digitos, para que despesas capturadas por notificacao automatica sejam associadas ao cartao correto.

7. Como **Ramon**, eu quero registrar pagamentos via Pix e Dinheiro alem de cartao de credito, para que todas as despesas estejam em um unico lugar.

8. Como **usuario**, eu quero definir um orcamento mensal por categoria (valor esperado vs real), para que eu possa acompanhar se estou dentro do planejado.

9. Como **usuario**, eu quero registrar receitas (salarios, rendimentos), para que eu tenha visao completa de entradas e saidas no planejamento mensal.

10. Como **Ramon**, eu quero que despesas vindas de notificacoes automaticas (SMS Bradesco, Nubank) sejam vinculadas ao modelo de despesas, para nao ter dados duplicados.

## Funcionalidades Principais

### F1. Entidade de Usuarios/Membros
- Representar os membros do casal (Ramon e Aline) como entidades do sistema.
- Cada despesa deve estar associada a um membro.
- Permitir visao individual e consolidada.

### F2. Entidade de Cartoes e Metodos de Pagamento
- Cadastro de cartoes de credito com: nome do cartao, ultimos 4 digitos, bandeira (opcional) e membro proprietario.
- Cartoes iniciais: Smiles Infinite (6668), Smiles Infinite (9687), Latam, Nubank Ramon, Nubank Aline, Neon Aline.
- Metodos de pagamento adicionais: Pix e Dinheiro.
- Vincular cartoes aos ultimos digitos para associacao automatica com notificacoes.

### F3. Entidade de Categorias
- Categorias configuráveis pelo usuario (nao hardcoded).
- Categorias iniciais da planilha: Comida, Gastos Gerais, Carro, Seguro Carro, PetLove, Light, Bodytech, Venvanse, Daforin, Assinaturas, Telefonia, Condominio, Gas, Banho cachorros, Psicologa, Viagem, Transporte, Taxa incendio, IPTU, IPVA.
- Permitir adicionar, editar e desativar categorias sem afetar historico.

### F4. Entidade de Despesas (Expenses)
- Campos obrigatorios: data da compra, descricao, valor total, metodo de pagamento (cartao ou Pix/Dinheiro), categoria, membro responsavel.
- Campos opcionais: observacoes.
- Flag de verificacao (verified: true/false) para conciliacao com fatura.
- Mes de referencia da fatura (pode diferir do mes da compra, dependendo da data de fechamento do cartao).

### F5. Suporte a Parcelas (Installments)
- Ao registrar despesa parcelada, informar: parcela atual e total (ex: 3/10).
- Gerar registros individuais para cada parcela, distribuidos nos meses corretos.
- Cada parcela deve ter: numero da parcela, total de parcelas, valor da parcela, mes de referencia.
- Manter vinculo entre todas as parcelas de uma mesma compra.

### F6. Vinculacao com Notificacoes Existentes
- Manter a tabela payment_notifications como fonte de dados brutos.
- Permitir que uma notificacao seja vinculada a uma despesa (relacao opcional).
- Evitar duplicidade: ao criar despesa a partir de notificacao, marcar a notificacao como processada.

### F7. Entidade de Receitas (Revenues)
- Registro de receitas mensais: descricao, valor, membro, mes de referencia.
- Tipos: salario, rendimento, outros.
- Suporte a receitas recorrentes (salario fixo mensal).

### F8. Entidade de Planejamento Orcamentario (Budget)
- Definir valor esperado por categoria por mes.
- Calcular valor real automaticamente a partir das despesas do mes.
- Calcular diferenca (esperado - real).
- Consolidar totais por metodo de pagamento.

### F9. Vinculacao com Notas Fiscais Existentes
- Manter as tabelas purchase_invoices, purchase_items e purchase_payments.
- Permitir vinculacao opcional entre uma despesa e uma nota fiscal.
- Nao obrigar que toda despesa tenha nota fiscal (a maioria nao tera).

## Experiencia do Usuario

O usuario principal (Ramon) interage com o sistema de duas formas:

**Fluxo automatico**: Uma notificacao de compra no cartao chega via SMS/push. O sistema ja recebe essa notificacao (fluxo existente), identifica o cartao pelos ultimos digitos e cria um rascunho de despesa com os dados basicos preenchidos. Ramon abre o app, ve o rascunho, seleciona a categoria, ajusta a descricao se necessario, informa parcelas se houver, e confirma. A despesa aparece no mes de referencia correto.

**Fluxo manual**: Ramon ou Aline abrem o app, clicam em "Nova Despesa", preenchem os campos (data, descricao, valor, cartao/pix/dinheiro, categoria, parcelas) e salvam. Para despesas parceladas, o sistema gera todas as parcelas automaticamente.

**Verificacao mensal**: No fechamento da fatura, Ramon abre a visao mensal, compara com a fatura do cartao e marca cada despesa como verificada. A visao mostra totais por cartao e por categoria, similar a planilha atual.

**Planejamento**: Ramon define o orcamento esperado por categoria. Ao longo do mes, o sistema mostra quanto ja foi gasto vs o planejado, similar a aba PL da planilha.

## Restricoes Tecnicas de Alto Nivel

1. **Banco de dados MySQL** -- manter compatibilidade com o banco atual.
2. **Migracao via Flyway** -- todas as alteracoes de schema devem ser scripts de migracao versionados (V5+).
3. **Sem quebra do modelo atual** -- as tabelas payment_notifications, purchase_invoices, purchase_items e purchase_payments devem continuar existindo. O novo modelo se soma a elas.
4. **Valores monetarios em DECIMAL(19,2)** -- padrao ja usado em payment_notifications.
5. **Timestamps de auditoria** -- todas as novas tabelas devem ter created_at e updated_at.
6. **Backend Kotlin/Spring Boot** -- o modelo deve seguir as convencoes JPA/Hibernate ja usadas no projeto.
7. **IDs auto-incrementais BIGINT** -- padrao consistente com payment_notifications.
8. **Charset utf8mb4** -- padrao consistente com as tabelas existentes.

## Fora de Escopo

1. **Interface grafica (frontend)** -- esta PRD trata apenas do modelo de dados e migracao do banco. Telas serao abordadas em PRDs especificas.
2. **APIs REST** -- endpoints serao definidos nas PRDs de cada funcionalidade (entrada manual, dashboard, etc.).
3. **Importacao de dados da planilha** -- sera tratada em PRD separada (prd-importacao-historico).
4. **Logica de fechamento de fatura** -- regras de data de corte de cada cartao serao tratadas em PRD separada (prd-gestao-cartoes).
5. **Relatorios e graficos** -- serao tratados em PRD separada (prd-dashboard-mensal).
6. **Autenticacao e autorizacao** -- fora de escopo neste momento.
7. **Notificacoes push e integracao com SMS** -- o fluxo de captura de notificacoes ja existe e nao sera alterado.
8. **Investimentos** -- embora a planilha tenha uma secao de investimentos, isso sera tratado em uma PRD futura.
