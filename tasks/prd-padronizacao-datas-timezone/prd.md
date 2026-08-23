# PRD: Padronização de Datas e Timezone (controlai + controlai-frontend)

## Visão Geral

O ControlAI é um app pessoal de controle financeiro (backend Kotlin/Spring Boot + frontend Ionic/React) usado por um casal para gerenciar compras, faturas e parcelas de cartão de crédito, muitas registradas automaticamente a partir de SMS bancário.

Uma análise do código identificou que **nenhuma camada do sistema fixa timezone explicitamente** — backend e frontend dependem do timezone default da JVM/host/navegador, que varia entre ambiente de desenvolvimento e produção. Isso já produziu inconsistências reais: tipos de data divergentes para o mesmo conceito no backend (`LocalDateTime`, `OffsetDateTime`, `Instant` convivendo sem critério), formatos de serialização diferentes entre endpoints, e no frontend um bug confirmado onde uma compra registrada manualmente pode ser salva com até 3 horas de deslocamento em relação ao horário informado pelo usuário, além de parcelas podendo ser classificadas incorretamente como vencidas/futuras perto da virada do dia.

Esta funcionalidade padroniza como datas e horários são armazenados, transmitidos e exibidos em todo o sistema, eliminando ambiguidade de timezone e unificando os padrões de tipo/formato usados em cada camada.

## Objetivos

- **Zero divergência entre horário real e horário exibido**: uma data/hora registrada em qualquer ponto do sistema (SMS, entrada manual, edição) deve ser exibida de forma idêntica em qualquer tela do app, em qualquer ambiente (dev/produção), independentemente do timezone do host do backend.
- **Um único padrão de tipo e formato por tipo de dado semântico**: eliminar a mistura atual de `LocalDateTime`/`OffsetDateTime`/`Instant` no backend para o mesmo conceito (ex: timestamps de evento) e a duplicação de lógica de parsing/formatação de data no frontend.
- **Eliminação dos bugs conhecidos**: correção do deslocamento de horário em registro manual de compra e da inconsistência de classificação de parcelas por vencimento.
- Sucesso é mensurável por: (a) auditoria de código confirmando um único tipo de data por categoria semântica em cada camada, com timezone declarado explicitamente onde a JVM/driver/Jackson dependem de configuração; (b) ausência de deslocamento de horário em testes que cobrem virada de dia e mudança de horário de verão histórico, se aplicável.

## Histórias de Usuário

- Como usuário do app, quando registro uma compra manualmente informando data e hora, quero que o horário salvo e depois exibido seja exatamente o que digitei, para confiar no histórico de gastos.
- Como usuário do app, quando uma compra é criada automaticamente a partir de um SMS do banco, quero que o horário exibido corresponda ao horário real da compra (horário de Brasília), independentemente de onde o backend está rodando.
- Como usuário do app, ao visualizar uma parcela com vencimento "hoje" perto da meia-noite, quero que o app classifique corretamente se ela já venceu ou não, sem depender de coincidência de fuso horário.
- Como usuário do app, ao editar a data/hora de uma compra ou período de orçamento, quero que o valor salvo reflita exatamente o que selecionei na interface.
- Como desenvolvedor (Ramon) mantendo o código sozinho, quero um padrão único e previsível de como datas são tratadas em cada camada, para não precisar reaprender ou redescobrir a lógica a cada novo ponto do código que lida com datas.

## Funcionalidades Principais

### 1. Padrão único de armazenamento e timezone no backend
Todo timestamp de evento de negócio (compra, cancelamento, criação/atualização de registro, expiração de token etc.) é armazenado e tratado internamente em UTC, com o timezone da aplicação (JVM, driver JDBC, Hibernate) fixado explicitamente em vez de depender do ambiente. Datas "de calendário" puras (sem componente de hora, como vencimento de parcela ou período de orçamento) continuam representadas sem timezone, mas de forma consistente entre si.

**Requisitos funcionais:**
1. Deve existir exatamente um tipo de dado por categoria semântica (timestamp de evento vs. data de calendário) usado consistentemente em todas as entidades do backend.
2. O timezone usado para interpretar/gerar timestamps deve ser explícito e configurado centralmente, não implícito no ambiente de execução.
3. Um timestamp de evento persistido deve representar o mesmo instante no tempo independentemente do timezone do host onde a aplicação ou o banco de dados rodam.

### 2. Padronização de serialização na API
Todos os endpoints que retornam ou recebem datas/horas usam o mesmo formato de serialização para cada categoria semântica de dado, sem conversões manuais para `String` nem formatos customizados divergentes entre responses.

**Requisitos funcionais:**
4. Todos os campos de timestamp de evento em responses da API devem usar o mesmo formato de serialização entre si.
5. Todos os campos de data de calendário em responses da API devem usar o mesmo formato de serialização entre si.
6. Requests que recebem data/hora do cliente devem ter seu timezone de origem tratado de forma explícita e não ambígua pelo backend.

### 3. Padronização de parsing e exibição no frontend
O frontend interpreta datas recebidas da API de forma correta e consistente (sem o bug clássico de interpretar data como UTC-meia-noite), formata para exibição em horário de Brasília através de um único ponto de lógica reutilizado por toda a aplicação, e envia datas/horas de volta à API em um formato não ambíguo.

**Requisitos funcionais:**
7. Deve existir um único ponto de lógica (compartilhado) responsável por formatar datas para exibição, substituindo as implementações duplicadas hoje presentes em múltiplos componentes.
8. Toda conversão de data recebida da API para exibição deve produzir o mesmo resultado visual independentemente do timezone do navegador/dispositivo do usuário.
9. Toda data/hora enviada da interface (formulários, seletores de data) para a API deve preservar o valor exatamente como inserido pelo usuário, sem deslocamento por conversão de timezone.
10. A comparação de datas de vencimento de parcela com a data/hora atual deve usar a mesma lógica de interpretação usada na exibição dessas mesmas datas, evitando classificações inconsistentes.

### 4. Correção dos bugs conhecidos
Os dois problemas concretos já identificados são corrigidos como parte desta padronização, não como itens à parte.

**Requisitos funcionais:**
11. O fluxo de registro manual de compra não deve mais introduzir deslocamento de horário entre o valor informado pelo usuário e o valor persistido.
12. A lógica que determina se uma parcela está vencida deve usar interpretação de data consistente com a usada para exibi-la, eliminando divergência perto da virada do dia.

## Experiência do Usuário

- **Usuários**: casal (Ramon e cônjuge) usando o app para controle de gastos compartilhado — sem necessidade de suporte a múltiplos timezones ou locales, apenas horário de Brasília e formato pt-BR.
- **Fluxos principais afetados**: registro automático de compra via SMS, registro manual de compra, edição de data/hora de compra, visualização de listas e detalhes de compras/parcelas/faturas, edição de períodos de orçamento.
- **Requisito de UI/UX**: todas as datas e horas exibidas devem continuar em formato pt-BR (dd/MM/yyyy, nomes de mês abreviados em português, hora em formato 24h) — a padronização não deve alterar o formato visual já estabelecido, apenas garantir que o valor exibido esteja correto.
- **Acessibilidade**: nenhum requisito novo além dos já aplicáveis aos componentes de formulário de data existentes (`IonDatetime`, inputs nativos).

## Restrições Técnicas de Alto Nível

- Backend permanece em Kotlin/Spring Boot com MySQL; frontend permanece em Ionic/React/TypeScript — nenhuma nova dependência de infraestrutura é assumida por este PRD.
- O app é de uso pessoal, single-tenant, exclusivamente em horário de Brasília (America/Sao_Paulo) — não há requisito de suportar múltiplos fusos horários simultâneos.
- Não há mandato de conformidade/regulatório específico associado a este tópico.
- A padronização deve ser aplicável sem exigir indisponibilidade do sistema em produção.

## Fora de Escopo

- Migração ou correção de dados históricos já persistidos no banco de dados — o foco é garantir corretude a partir da implementação desta funcionalidade em diante.
- Suporte a múltiplos timezones ou internacionalização de formato de data/hora (o app permanece fixo em horário de Brasília e formato pt-BR).
- Mudanças de UX/design nos componentes de seleção ou exibição de data além da correção do valor exibido (não inclui redesenho visual de calendários, seletores ou listas).
- Qualquer alteração no conteúdo ou parsing de outros dados do SMS bancário além do timestamp (valor, estabelecimento etc.).

(Nota: riscos de implementação técnica — como escolha de tipos específicos, biblioteca de datas no frontend, e estratégia de configuração de timezone em cada camada — serão detalhados na Tech Spec.)
