# Tarefa 6.0: Frontend — Service layer + tipos TypeScript

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar a camada de servico centralizada para comunicacao com a API de meios de pagamento e definir todas as interfaces/tipos TypeScript correspondentes. Isso padroniza as chamadas HTTP (suportando CapacitorHttp para nativo e fetch para web) e serve como base para todas as telas do frontend.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Skill principal para implementacao
- `task-review` — Review automatico apos conclusao
</skills>

<requirements>
- Criar arquivo `src/services/paymentMethodService.ts`
- Implementar funcoes para todos os endpoints: listHolders, createHolder, listPaymentMethods, getPaymentMethod, createPaymentMethod, updatePaymentMethod, deletePaymentMethod, createSubCard, updateSubCard, deleteSubCard, getPaymentMethodsSummary
- Suportar dual-platform: CapacitorHttp (nativo) + fetch (web), seguindo padrao existente em InvoiceProcessingContext.tsx
- Criar tipos TypeScript em `src/types/paymentMethod.ts`: Holder, PaymentMethod, SubCard, PaymentMethodSummary, SubCardTotal, e tipos de request (Create/Update)
- URL base da API configuravel (constante no topo do service)
- Tratar erros de forma consistente (throw com mensagem descritiva)
</requirements>

## Subtarefas

- [ ] 6.1 Criar tipos TypeScript em `src/types/paymentMethod.ts`
- [ ] 6.2 Criar helper de HTTP dual-platform (CapacitorHttp + fetch)
- [ ] 6.3 Implementar funcoes de Holders (list, create)
- [ ] 6.4 Implementar funcoes de PaymentMethods (CRUD completo)
- [ ] 6.5 Implementar funcoes de SubCards (create, update, delete)
- [ ] 6.6 Implementar funcao de Summary (getPaymentMethodsSummary)
- [ ] 6.7 Testes unitarios do service

## Detalhes de Implementacao

Consultar secao **Endpoints de API** da `techspec.md` para lista de endpoints e formatos.

Seguir padrao de chamada HTTP existente em `src/context/InvoiceProcessingContext.tsx` (linhas 33-50) para dual-platform.

## Criterios de Sucesso

- Todas as funcoes do service compilam sem erro TypeScript
- Tipos cobrem 100% dos campos retornados pela API
- Chamadas HTTP funcionam tanto em plataforma nativa quanto web
- Erros de rede sao tratados e propagados de forma consistente
- Service e reutilizavel por qualquer componente/pagina

## Testes da Tarefa

- [ ] Teste unitario: cada funcao do service chama o endpoint correto (mock fetch)
- [ ] Teste unitario: tipos TypeScript estao consistentes com os response DTOs do backend
- [ ] Teste unitario: erros HTTP sao propagados corretamente

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `controlai-frontend/src/services/paymentMethodService.ts` (novo)
- `controlai-frontend/src/types/paymentMethod.ts` (novo)
- `controlai-frontend/src/context/InvoiceProcessingContext.tsx` (referencia de padrao HTTP)
- `controlai-frontend/src/pages/Tab1.tsx` (referencia de padrao fetch)
