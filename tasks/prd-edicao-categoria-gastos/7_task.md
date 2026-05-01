# Tarefa 7.0: Testes E2E com Playwright

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Criar testes end-to-end com Playwright cobrindo os fluxos completos de edicao de categoria: no detalhe, na listagem e o fluxo de CTA de orcamento. Os testes devem validar a integracao completa entre frontend e backend.

<skills>
### Conformidade com Skills Padroes

- `executar-task` — Seguir o fluxo de implementacao incremental
- `executar-qa` — Referencia para padroes de QA com Playwright
- `task-review` — Submeter para review apos conclusao
</skills>

<requirements>
- Testar fluxo completo de categorizar gasto no PurchaseDetail
- Testar fluxo completo de categorizar gasto na listagem (Tab1)
- Testar remocao de categoria (selecionar "Nenhuma")
- Testar fluxo de CTA de orcamento: categorizar com categoria fora do budget → verificar banner → clicar CTA → verificar que item foi adicionado
- Testes devem rodar contra backend real (nao mocked)
- Seguir padroes de Playwright ja estabelecidos no projeto (se existirem)
</requirements>

## Subtarefas

- [ ] 7.1 Criar arquivo de teste E2E para edicao de categoria no detalhe
- [ ] 7.2 Criar teste: abrir detalhe de notification sem categoria → selecionar categoria → verificar atualizacao
- [ ] 7.3 Criar teste: abrir detalhe → alterar categoria existente → verificar atualizacao
- [ ] 7.4 Criar teste: abrir detalhe → remover categoria ("Nenhuma") → verificar "Sem categoria"
- [ ] 7.5 Criar teste E2E para edicao de categoria na listagem
- [ ] 7.6 Criar teste: na listagem → tocar badge → selecionar categoria → verificar atualizacao inline
- [ ] 7.7 Criar teste E2E para fluxo de orcamento
- [ ] 7.8 Criar teste: categorizar com categoria fora do budget → banner aparece → clicar CTA → banner desaparece

## Detalhes de Implementacao

Consultar a secao **"Abordagem de Testes > Testes de E2E"** da `techspec.md` para os cenarios.

Consultar `executar-qa/references/playwright-tools.md` para padroes de Playwright do projeto.

## Criterios de Sucesso

- Todos os fluxos E2E passam consistentemente
- Testes cobrem os 3 cenarios principais: detalhe, listagem, orcamento
- Testes sao estaveis (sem flakiness)
- Testes validam tanto a UI quanto os dados persistidos

## Testes da Tarefa

- [ ] Testes E2E: categorizar no detalhe (sem categoria → com categoria)
- [ ] Testes E2E: alterar categoria no detalhe
- [ ] Testes E2E: remover categoria no detalhe
- [ ] Testes E2E: categorizar na listagem inline
- [ ] Testes E2E: fluxo CTA orcamento (banner + criacao de item)

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

**Criar:**
- Arquivo(s) de teste Playwright (localizar diretorio de testes E2E do projeto)

**Referencia:**
- `executar-qa/references/playwright-tools.md` — padroes de Playwright
- Todos os componentes implementados nas tasks 1-6
