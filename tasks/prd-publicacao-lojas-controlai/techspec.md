# Tech Spec: Publicação do ControlAI na App Store e Google Play

## Resumo Executivo

Esta funcionalidade é majoritariamente um trabalho de configuração e preenchimento manual nos consoles das lojas (App Store Connect e Google Play Console), reaproveitando os builds assinados já produzidos pelos PRDs "Comercialização do ControlAI" (app sem nenhuma menção a pagamento externo, já validado por teste automatizado) e "Build Android no Appflow" (artefato Android assinado). Três pequenos entregáveis de código/conteúdo dão suporte a esse processo: (1) uma página estática de política de privacidade no `controlai-landing`, exigida por URL pública em ambas as lojas; (2) uma migração de seed no backend que cria uma conta fixa de revisor (assinatura ativa, dados fictícios) para contornar a desativação do cadastro público; (3) exportação de screenshots de loja a partir do arquivo de design já existente no Paper ("ControlAI"), em vez de captura da UI real. Não há novo endpoint, serviço ou tela de aplicação.

## Arquitetura do Sistema

### Visão Geral dos Componentes

- **Página de política de privacidade (novo, `controlai-landing`)** — HTML estático puro (mesmo padrão da landing page de vendas, sem framework), publicada junto com o site já existente, referenciada por URL nas duas lojas.
- **Migração `V40__seed_store_reviewer_account.sql` (novo, backend `controlai`)** — reaproveita o mesmo padrão de dado usado no grandfathering (PRD comercialização): insere um usuário fixo de revisor com grupo próprio, uma linha `subscriptions` com `status = ACTIVE`, e um pequeno conjunto de dados de exemplo não sensíveis (1 cartão fictício, 1–2 compras) para que o revisor navegue pelas telas principais sem encontrar estados vazios. Nenhuma lógica de aplicação nova — é dado, assim como o backfill de grandfathering já existente em `V39`.
- **Screenshots de loja (design, sem código)** — exportados diretamente do arquivo Paper "ControlAI" (`01KM6VMAY9XBB4E4KWF7B6G7W4`), reaproveitando artboards já existentes: `Dashboard — Home` (id `1-0`), `Cartões — Lista` (`CW-0`), `Orçamento Mensal` (`158-0`) e `Detalhe — Nota Fiscal` (`RL-0`) cobrem, respectivamente, dashboard/cartões/orçamento/faturas exigidos pelo PRD. Exportação via `get_screenshot` por artboard, nos tamanhos de dispositivo exigidos por cada loja.
- **Ficha de loja e submissão (fora do repositório)** — preenchimento manual em App Store Connect e Google Play Console: nome, descrições, categoria (Finanças), classificação etária, App Privacy / Data Safety, App Review Information (credenciais da conta seed + roteiro de navegação), upload de build e screenshots.
- **Guard-rail de "zero menção a pagamento externo"** — já implementado no PRD de comercialização (`SubscriptionRequiredPage` sem qualquer link/texto de checkout, coberto por `SubscriptionRequiredPage.test.tsx`); nenhuma mudança de código necessária aqui, apenas validação de que o teste continua passando.

Fluxo: build assinado (iOS via Appflow, já existente; Android via Appflow, PRD "Build Android no Appflow") → upload para TestFlight / trilha da Play Console → preenchimento da ficha em cada console (usando a política de privacidade e os screenshots deste PRD) → submissão para revisão → revisor loga com a conta seed → aprovação → app público em ambas as lojas.

## Design de Implementação

### Interfaces Principais

Não aplicável — nenhuma interface de serviço nova. A única mudança de "contrato" é a migração de dado descrita abaixo.

### Modelos de Dados

Reaproveita as entidades já existentes do bounded context `billing` (PRD comercialização), sem alteração de schema:

```sql
-- Conceitual, via migração V40 — reaproveita tabelas users/groups/subscriptions já existentes
INSERT INTO groups (...) VALUES (...);                 -- grupo dedicado ao revisor
INSERT INTO users (email, password_hash, group_id, ...) VALUES ('revisor@...', '<bcrypt fixo>', ...);
INSERT INTO subscriptions (group_id, plan, status) VALUES (<group_id>, 'GRANDFATHERED', 'ACTIVE');
-- + 1 cartão e 1-2 compras de exemplo, sem dados financeiros reais
```

### Endpoints de API

Não aplicável — nenhum endpoint novo é exposto.

## Pontos de Integração

- **App Store Connect** — App Privacy, TestFlight/submissão, App Review Information (credenciais da conta seed).
- **Google Play Console** — Data Safety (categoria "Informações financeiras"), Content rating, App content, trilha de produção.
- **Paper (design)** — fonte dos screenshots de loja; uso pontual de leitura, não é uma integração de produção/runtime.
- **Dependências de outros PRDs**: build assinado Android (PRD "Build Android no Appflow", concluído) e postura de "sem menção a pagamento" do app (PRD "Comercialização do ControlAI", concluído e testado).

## Abordagem de Testes

### Testes de Unidade

Não aplicável — não há lógica de aplicação nova.

### Testes de Integração

- Rodar a migração `V40` em ambiente de teste (mesmo `docker-compose` MySQL já usado pelos demais testes de integração do backend) e confirmar que a conta seed autentica e retorna `200` (não `402`) em uma rota protegida — reaproveita a fixture de `SubscriptionGuardFilter` já testada no PRD comercialização.
- Confirmar que `SubscriptionRequiredPage.test.tsx` (guard-rail de "sem menção a checkout/pagamento") continua passando sem alterações — é o principal controle automatizado do Requisito 5 do PRD.

### Testes de E2E

Não aplicável via Playwright — a validação final é um smoke test manual: login com a conta seed em um build real (TestFlight / trilha interna Android) e navegação pelas telas usadas nos screenshots, confirmando que refletem a UI real do app publicado.

## Sequenciamento de Desenvolvimento

### Ordem de Construção

1. **Migração `V40` (conta de revisor)** — pré-requisito para poder preencher "App Review Information" em ambas as lojas.
2. **Página de política de privacidade** (`controlai-landing`) — pré-requisito de URL pública para a ficha de loja em ambas as plataformas.
3. **Gerar o ícone de launcher Android** — bloqueador técnico identificado nesta análise (ver Riscos Conhecidos), precisa existir antes de qualquer build de release Android apresentável.
4. **Exportar screenshots** via Paper para os tamanhos exigidos por cada loja.
5. **Preencher ficha de loja completa no App Store Connect** (nome, descrição, categoria, ícone, screenshots, política de privacidade, App Privacy, classificação etária, App Review Information).
6. **Preencher ficha de loja completa no Google Play Console** (idem + Data Safety + Content rating).
7. **Submeter os builds** (iOS via TestFlight/Appflow; Android via trilha de produção do Appflow ou promoção manual da trilha interna já configurada) para revisão.
8. **Acompanhar status até aprovação**; documentar motivo e reenviar em caso de rejeição.

### Dependências Técnicas

- Build assinado iOS (já existente) e Android (PRD "Build Android no Appflow", concluído).
- Conta ativa e em situação regular no App Store Connect e no Google Play Console.
- Ícone Android ausente (`controlai-frontend/android/app/src/main/res/` está vazio, apesar de `AndroidManifest.xml` referenciar `@mipmap/ic_launcher`) — precisa ser gerado a partir da arte-fonte já usada no ícone iOS antes do primeiro build de release público.
- Confirmação de que o app `br.com.nomar.controlai` já existe no Google Play Console (pré-requisito também levantado no PRD "Build Android no Appflow").

## Monitoramento e Observabilidade

Não aplicável — sem componente em runtime. O status de cada submissão (em revisão, aprovado, rejeitado) é acompanhado nativamente nos dashboards das lojas (App Store Connect / Play Console), mesmo padrão de "sem instrumentação customizada" adotado no PRD "Build Android no Appflow".

## Considerações Técnicas

### Decisões Principais

- **Sem automação (Fastlane) para metadados**: preenchimento manual nos consoles das lojas, consistente com a abordagem de configuração via dashboard já usada no PRD "Build Android no Appflow" — evita introduzir uma ferramenta nova só para um processo majoritariamente único (primeira publicação).
- **Screenshots reaproveitados do design já existente no Paper, não capturas da UI real renderizada**: reduz esforço, mantém consistência visual com o design system aprovado. Risco de leve divergência entre design e implementação real é mitigado pela revisão manual das telas reais antes da submissão.
- **Conta de revisor criada via seed de dados (mesmo mecanismo do grandfathering)**, não via fluxo de compra real na Kiwify: evita depender do ambiente de teste do gateway de pagamento para algo puramente operacional, e garante uma conta estável e reutilizável para reenvios em caso de rejeição.
- **Postura de "zero menção a pagamento externo" mantida mesmo após a flexibilização de 2026 da Guideline 3.1.1 da Apple (que permite links de compra externa apenas no storefront dos EUA)**: como o ControlAI tem storefront BR, a mudança não se aplica, e a decisão já tomada e implementada no PRD de comercialização é a mais conservadora e segura para revisão em qualquer região — não é necessário solicitar o "External Link Account Entitlement".

### Riscos Conhecidos

- **Launcher icon do Android ausente**: bloqueia a geração de um build de release apresentável; precisa ser resolvido antes da Tarefa de submissão Android. Risco identificado nesta análise técnica, não estava explícito no PRD original.
- **App ainda não confirmado como existente no Google Play Console**: mesmo risco já levantado no PRD "Build Android no Appflow" — pré-requisito bloqueante para a ficha de loja Android.
- **Google Play Data Safety** exige declarar a categoria "Informações financeiras" e detalhar terceiros/SDKs (ex.: Resend como processador de e-mail; a Kiwify não deve aparecer como coletor de dados do app, já que o pagamento acontece inteiramente fora dele) — preenchimento incorreto é causa comum de rejeição ou remoção posterior.
- **Ausência de fluxo de beta público** (TestFlight externo / Google Play Beta) está fora de escopo deste PRD — a validação pré-submissão depende inteiramente de testadores internos.

### Conformidade com Skills Padrão

- `frontend-design` — aplica-se à página de política de privacidade em `controlai-landing`.
- `ionic-design` — aplica-se à checagem visual final das telas reais antes de finalizar os screenshots exportados do Paper, garantindo consistência com a UI publicada.
- Demais skills do projeto (`kotlin-springboot`, `clean-code`) aplicam-se apenas de forma pontual à migração `V40`, sem introduzir componentes ou abstrações novas.

### Arquivos relevantes e dependentes

- Novo: `controlai-landing/privacidade.html` (ou rota equivalente do site estático).
- Novo: `controlai/src/main/resources/db/migration/V40__seed_store_reviewer_account.sql`.
- `controlai-frontend/android/app/src/main/res/` — mipmaps do ícone de launcher (a popular).
- `controlai-frontend/src/pages/SubscriptionRequiredPage.test.tsx` — guard-rail existente de referência.
- `controlai-frontend/ios/App/App/Assets.xcassets/AppIcon.appiconset/` — ícone-fonte de referência para gerar o ícone Android.
- Arquivo de design Paper "ControlAI" (id `01KM6VMAY9XBB4E4KWF7B6G7W4`) — fonte dos screenshots de loja.
- Configuração externa ao repositório: App Store Connect, Google Play Console (não versionada em código).
