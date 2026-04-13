# Tarefa 3.0: Backend — CreateInstallmentsProvider

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Implementar o provider que gera N parcelas atomicamente, incluindo a logica de calculo de datas ("mesmo dia, mes seguinte" com ajuste para meses curtos).

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o procedimento completo de implementacao
</skills>

<requirements>
- Criar `CreateInstallmentsProvider` como `@Service` Spring
- Receber: parentId, totalInstallments, amount (valor da parcela), startDate
- Gerar N registros de `Installment` com installmentNumber de 1 a N
- Calcular dueDate usando regra "mesmo dia do mes seguinte" (ver techspec.md secao "Logica de Calculo de Datas")
- Para dia 31 em meses com menos dias, usar ultimo dia do mes
- Salvar todos via `installmentRepository.saveAll()` atomicamente
- Retornar lista de parcelas criadas
</requirements>

## Subtarefas

- [ ] 3.1 Criar metodo `calculateDueDate(startDate, installmentNumber)` com logica de datas
- [ ] 3.2 Criar `CreateInstallmentsProvider.execute()` que gera e salva N parcelas
- [ ] 3.3 Testes unitarios e de integracao

## Detalhes de Implementacao

Consultar a secao "Logica de Calculo de Datas" da `techspec.md` para a implementacao do calculo.

Localizacao sugerida: `br.com.nomar.controlai.application.installments.application.CreateInstallmentsProvider`

## Criterios de Sucesso

- Provider gera exatamente N parcelas com numeros sequenciais (1 a N)
- Datas calculadas corretamente para todos os edge cases
- Todas as parcelas salvas em uma unica operacao

## Testes da Tarefa

- [ ] Testes de unidade: `calculateDueDate` — caso normal (dia 15), dia 31 em fev (deve ser 28/29), dia 30 em meses com 31 dias
- [ ] Testes de integracao: `execute()` com 3 parcelas — verifica 3 registros no banco com datas corretas
- [ ] Testes de integracao: `execute()` com 1 parcela — verifica 1 registro

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `CreateInstallmentsProvider.kt` (novo)
- `InstallmentRepository.kt` (da tarefa 2)
- `Installment.kt` (da tarefa 2)
