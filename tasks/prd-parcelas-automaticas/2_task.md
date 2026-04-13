# Tarefa 2.0: Backend — Model JPA Installment + Repository

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar a entidade JPA `Installment` mapeando a tabela `installments` e o repositorio Spring Data `InstallmentRepository` com as queries necessarias.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o procedimento completo de implementacao
</skills>

<requirements>
- Criar entidade JPA `Installment` com todos os campos da tabela
- Criar `InstallmentRepository` extendendo `JpaRepository<Installment, Long>`
- Incluir queries: `findByParentIdOrderByInstallmentNumber`, `findByParentIdAndCancelledAtIsNull`
- Incluir query nativa `getMonthlyProjection` para projecao de comprometimento futuro
- Criar interface `MonthlyProjection` para o resultado da query nativa
- Criar DTO `InstallmentResponse` com metodo `from(Installment)`
- Criar DTO `MonthlyProjectionResponse`
</requirements>

## Subtarefas

- [ ] 2.1 Criar entidade JPA `Installment.kt`
- [ ] 2.2 Criar `InstallmentRepository.kt` com queries
- [ ] 2.3 Criar interface `MonthlyProjection.kt` para resultado da query nativa
- [ ] 2.4 Criar `InstallmentResponse.kt` e `MonthlyProjectionResponse.kt`
- [ ] 2.5 Testes unitarios e de integracao

## Detalhes de Implementacao

Consultar a secao "Modelos de Dados" e "Interfaces Principais" da `techspec.md` para definicoes de entidade, repository e DTOs.

Seguir o padrao de pacotes existente. Sugestao de localizacao:
- `br.com.nomar.controlai.application.installments.entrypoint.database.model.Installment`
- `br.com.nomar.controlai.application.installments.entrypoint.database.repository.InstallmentRepository`
- `br.com.nomar.controlai.application.installments.entrypoint.rest.response.InstallmentResponse`

## Criterios de Sucesso

- Entidade JPA mapeia corretamente para a tabela `installments`
- Repository queries retornam dados corretos
- DTOs mapeiam entidade para response corretamente
- Build passa sem erros

## Testes da Tarefa

- [ ] Testes de unidade: `InstallmentResponse.from()` mapeia corretamente
- [ ] Testes de integracao: insert + findByParentId retorna dados corretos via repository

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `Installment.kt` (novo)
- `InstallmentRepository.kt` (novo)
- `MonthlyProjection.kt` (novo)
- `InstallmentResponse.kt` (novo)
- `MonthlyProjectionResponse.kt` (novo)
- `PaymentNotification.kt` (referencia — entidade pai)
