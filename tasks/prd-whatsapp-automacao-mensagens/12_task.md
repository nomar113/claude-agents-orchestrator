# Tarefa 12.0: Testes E2E Playwright dos Fluxos-Ancora

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Construir a suite de testes E2E com Playwright cobrindo os 3 cenarios-ancora descritos no PRD e na techspec, garantindo que o sistema atende as historias de usuario de ponta a ponta. Os testes rodam contra Next.js + API com `WHATSAPP_DRIVER=fake` para nao depender de QR Code real.

<skills>
### Conformidade com Skills Padroes

- `executar-task`.
- `executar-qa` — esta tarefa entrega a base do QA automatizado.
- `frontend-design` (global) — checagens visuais/UX leves nas asserts.
</skills>

<requirements>
- Setup Playwright em `apps/web/playwright/` com config rodando contra `npm run dev` da API e do Web em portas conhecidas.
- Variavel `WHATSAPP_DRIVER=fake` aplicada ao processo da API durante os testes.
- Banco SQLite efemero por execucao da suite (limpa antes de rodar).
- Fixture/util que conecta o driver fake e simula `ready` automaticamente.
- Cenarios obrigatorios:
  1. **Onboarding solar**: configurar lat/lng e timezone em Settings -> importar 3 contatos via CSV -> criar schedule solar (`sunrise + 2h`) para um contato -> validar que a tela mostra `nextRunAt` calculado para a data esperada (com tolerancia minima).
  2. **Pause/Resume**: criar schedule `fixed` -> pausar -> verificar badge `paused` e ausencia de job pendente (via endpoint debug ou metrica `queue_depth`) -> resumir -> verificar `nextRunAt` recalculado.
  3. **Bulk confirmation**: criar lista com 12 contatos -> iniciar criacao de schedule para a lista -> validar modal exibido com contagem `12` -> cancelar nao cria; confirmar cria e exibe na listagem.
- CI script `npm run test:e2e` rodando todos os cenarios.
</requirements>

## Subtarefas

- [x] 12.1 Instalar Playwright e configurar `apps/web/playwright.config.ts`.
- [x] 12.2 Implementar fixture global que sobe API + Web com env de teste e reseta banco.
- [x] 12.3 Implementar helper `connectFakeWhatsApp()` para forcar `ready` no driver fake.
- [x] 12.4 Implementar cenario 1 (Onboarding solar) em `playwright/onboarding.spec.ts`.
- [x] 12.5 Implementar cenario 2 (Pause/Resume) em `playwright/pause-resume.spec.ts`.
- [x] 12.6 Implementar cenario 3 (Bulk confirmation) em `playwright/bulk-confirmation.spec.ts`.
- [x] 12.7 Adicionar script `test:e2e` (`npm run test:e2e`) na raiz e no `apps/web/package.json`.
- [x] 12.8 Executar suite e garantir 3 verdes consecutivos (estabilidade).

## Detalhes de Implementacao

Ver `techspec.md` secoes "Abordagem de Testes - Testes de E2E" (descricao dos 3 cenarios) e PRD "Historias de Usuario" (mapeamento dos cenarios as historias-ancora).

## Criterios de Sucesso

- `npm run test:e2e` executa os 3 spec files e todos passam em ambiente limpo.
- Cada spec valida pelo menos 1 asserts visual (badge, modal) e 1 asserts funcional (API ou estado de banco).
- Tempo total da suite < 3min em maquina local.

## Testes da Tarefa

- [x] Testes de unidade: nao aplicavel (a tarefa em si e composta por testes).
- [x] Testes de integracao: nao aplicavel.
- [x] Testes E2E (Playwright): os 3 cenarios listados acima, totalizando 3 specs com pelo menos 1 caso cada.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `apps/web/playwright.config.ts`
- `apps/web/playwright/fixtures.ts`
- `apps/web/playwright/utils/whatsapp-fake.ts`
- `apps/web/playwright/onboarding.spec.ts`
- `apps/web/playwright/pause-resume.spec.ts`
- `apps/web/playwright/bulk-confirmation.spec.ts`
- `apps/web/package.json` (script `test:e2e`)
- `package.json` raiz (script `test:e2e` agregado)
