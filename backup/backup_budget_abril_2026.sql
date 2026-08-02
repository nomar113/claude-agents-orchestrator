-- Backup do planejamento de Abril 2026 - ControlAI
-- Gerado em: 2026-05-03
-- Budget ID: 39 | Total Esperado: R$ 9.842,73

-- =============================================================
-- 1. Categoria criada para este planejamento
-- =============================================================
INSERT INTO categories (id, name, icon, deleted_at, created_at, updated_at)
VALUES (269, 'Academia', NULL, NULL, NOW(), NOW())
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- =============================================================
-- 2. Budget (orçamento mensal)
-- =============================================================
INSERT INTO budgets (id, reference_month, created_at, updated_at)
VALUES (39, '2026-04', NOW(), NOW())
ON DUPLICATE KEY UPDATE reference_month = VALUES(reference_month);

-- =============================================================
-- 3. Budget Items (itens do planejamento)
-- =============================================================
INSERT INTO budget_items (id, budget_id, category_id, type, expected, created_at, updated_at) VALUES
(48, 39, 253, 'EXPENSE', 1000.00, NOW(), NOW()),   -- Comida
(49, 39, 254, 'EXPENSE', 3000.00, NOW(), NOW()),   -- Gastos Gerais
(50, 39, 264, 'EXPENSE', 500.00, NOW(), NOW()),    -- Carro: combustível
(51, 39, 266, 'EXPENSE', 389.37, NOW(), NOW()),    -- Carro: seguro
(52, 39, 256, 'EXPENSE', 523.08, NOW(), NOW()),    -- Pets (PetLove R$323,08 + Banho cachorros R$200)
(53, 39, 265, 'EXPENSE', 200.00, NOW(), NOW()),    -- Moradia: luz (Light)
(54, 39, 269, 'EXPENSE', 129.43, NOW(), NOW()),    -- Academia (Bodytech Norte Shopping)
(55, 39, 259, 'EXPENSE', 0.00, NOW(), NOW()),      -- Remédio (Venvanse + Daforin)
(56, 39, 262, 'EXPENSE', 330.00, NOW(), NOW()),    -- Assinaturas
(57, 39, 255, 'EXPENSE', 240.85, NOW(), NOW()),    -- Telefonia
(58, 39, 257, 'EXPENSE', 750.00, NOW(), NOW()),    -- Moradia: condomínio + água
(59, 39, 258, 'EXPENSE', 80.00, NOW(), NOW()),     -- Moradia: gás
(60, 39, 263, 'EXPENSE', 600.00, NOW(), NOW()),    -- Médico: psicóloga
(61, 39, 261, 'EXPENSE', 2000.00, NOW(), NOW()),   -- Viagens
(62, 39, 260, 'EXPENSE', 100.00, NOW(), NOW())     -- Transporte
ON DUPLICATE KEY UPDATE expected = VALUES(expected);

-- =============================================================
-- Resumo do Planejamento
-- =============================================================
-- Comida:                    R$ 1.000,00
-- Gastos Gerais:             R$ 3.000,00
-- Carro: combustível:        R$   500,00
-- Carro: seguro:             R$   389,37
-- Pets:                      R$   523,08
-- Moradia: luz:              R$   200,00
-- Academia:                  R$   129,43
-- Remédio:                   R$     0,00
-- Assinaturas:               R$   330,00
-- Telefonia:                 R$   240,85
-- Moradia: condomínio+água:  R$   750,00
-- Moradia: gás:              R$    80,00
-- Médico: psicóloga:         R$   600,00
-- Viagens:                   R$ 2.000,00
-- Transporte:                R$   100,00
-- ─────────────────────────────────────────
-- TOTAL:                     R$ 9.842,73
