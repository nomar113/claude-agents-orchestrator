# Tarefa 1.0: Backend — Configuracao central de timezone UTC

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Fixar explicitamente o timezone UTC em todas as camadas do backend que hoje dependem implicitamente do timezone do host (JVM, driver JDBC `mysql-connector-j`, Hibernate, Jackson), via `application.yml` e URL de conexao JDBC. Esta e a base de toda a padronizacao: nenhuma outra tarefa de backend deve iniciar antes desta configuracao estar em vigor.

**Nao ha dependencias** — esta e a primeira tarefa da sequencia.

<skills>
### Conformidade com Skills Padroes

- `clean-code`: centralizar a configuracao de timezone em um unico ponto (`application.yml`), eliminando dependencia implicita de ambiente.
</skills>

<requirements>
- O timezone usado para interpretar/gerar timestamps deve ser explicito e configurado centralmente, nao implicito no ambiente de execucao (PRD requisito 2).
- Um timestamp de evento persistido deve representar o mesmo instante no tempo independentemente do timezone do host onde a aplicacao ou o banco de dados rodam (PRD requisito 3).
- Nao deve ser necessaria alteracao no `docker-compose.yml`/imagem MySQL — apenas parametros de URL JDBC.
</requirements>

## Subtarefas

- [x] 1.1 Configurar `spring.jackson.time-zone: UTC` em `application.yml`.
- [x] 1.2 Configurar `spring.jpa.properties.hibernate.jdbc.time_zone: UTC` em `application.yml`.
- [x] 1.3 Ajustar a URL JDBC do datasource para incluir `connectionTimeZone=UTC&forceConnectionTimeZoneToSession=true`.
- [x] 1.4 Validar que a configuracao vale tanto para o ambiente local (docker-compose) quanto para producao, sem exigir mudanca de imagem/container MySQL.
- [x] 1.5 Escrever testes de unidade e integracao (ver secao de Testes).

## Detalhes de Implementacao

Ver secao "Configuracao central de timezone" e "Pontos de Integracao" da `techspec.md` — inclui o trecho exato de `application.yml` a aplicar e a justificativa de uso de `connectionTimeZone`/`forceConnectionTimeZoneToSession` em vez do parametro legado `serverTimezone`.

## Criterios de Sucesso

- A aplicacao sobe corretamente em ambiente local (docker-compose) e a variavel de sessao `time_zone` do MySQL e forcada para UTC a cada conexao, independentemente do timezone default do container.
- Nenhuma mudanca de comportamento observavel ainda nesta tarefa (tipos de entidade so mudam na Tarefa 2.0) — o objetivo e apenas fixar a base.

## Testes da Tarefa

- [x] Testes de unidade: verificar que o contexto Spring carrega com `jackson.time-zone=UTC` e `hibernate.jdbc.time_zone=UTC` aplicados.
- [x] Testes de integracao: teste contra MySQL real (Testcontainers/docker-compose de teste ja usado no projeto) validando que `connectionTimeZone=UTC` esta de fato aplicado — grava um timestamp conhecido, reinicia a sessao, rele e compara (conforme "Abordagem de Testes" da techspec.md).

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `application.yml` (raiz do repositorio `controlai` — carregado via convencao Spring Boot `file:./application.yml`, tem precedencia sobre `classpath:/application.yml`; `src/main/resources/application.properties` guarda outras configs, sem chaves de datasource/jackson/jpa)
- Configuracao de datasource (URL JDBC)
- Suite de testes de integracao existente (docker-compose de teste, MySQL real em `mysql_local`)
