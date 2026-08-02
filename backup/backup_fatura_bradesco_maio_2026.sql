-- ============================================================
-- BACKUP: Fatura Bradesco Visa Infinite - Vencimento 08/05/2026
-- Cartão: 4005 XXXX XXXX 6668 (Titular) / 9687 (Adicional)
-- Total da fatura: R$ 7.484,46
-- Gerado em: 2026-05-02
-- ============================================================

-- 1. Holder
INSERT INTO holders (id, name, created_at, updated_at)
VALUES (169, 'Ramon', NOW(), NOW())
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- 2. Payment Method
INSERT INTO payment_methods (id, name, type, holder_id, closing_day, created_at, updated_at)
VALUES (137, 'Bradesco Visa Infinite', 'CREDIT_CARD', 169, 26, NOW(), NOW())
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- 3. Sub Cards
INSERT INTO sub_cards (id, payment_method_id, last_four_digits, type, nickname, created_at, updated_at)
VALUES
  (53, 137, '6668', 'PHYSICAL_HOLDER', 'Titular Ramon', NOW(), NOW()),
  (54, 137, '9687', 'PHYSICAL_DEPENDENT', 'Adicional', NOW(), NOW())
ON DUPLICATE KEY UPDATE nickname = VALUES(nickname);

-- 4. Categorias
INSERT INTO categories (id, name, created_at, updated_at) VALUES
  (253, 'Mercado', NOW(), NOW()),
  (254, 'Gastos Gerais', NOW(), NOW()),
  (255, 'Veiculos', NOW(), NOW()),
  (256, 'Pets', NOW(), NOW()),
  (257, 'Moradia', NOW(), NOW()),
  (258, 'Remedios', NOW(), NOW()),
  (259, 'Medicos', NOW(), NOW()),
  (260, 'Transporte', NOW(), NOW()),
  (261, 'Viagens', NOW(), NOW()),
  (262, 'Assinaturas', NOW(), NOW()),
  (263, 'Lazer', NOW(), NOW()),
  (264, 'Educacao', NOW(), NOW()),
  (265, 'Vestuario', NOW(), NOW()),
  (266, 'Beleza', NOW(), NOW()),
  (267, 'Presentes', NOW(), NOW())
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- 5. Transações - Titular (Cartão 6668)
INSERT INTO payment_notifications
  (card_last_digits, purchased_at, amount, merchant_name, number_of_installments, origin, origin_type, category_id, payment_method_id, sub_card_id)
VALUES
  ('6668', '2026-03-26 12:00:00', 150.00, 'PSICOLOGA TATIANA CASTRO', 1, 'MANUAL', 'MANUAL', 259, 137, 53),
  ('6668', '2026-03-28 12:00:00', 1260.00, 'PAGAMENTO', 1, 'MANUAL', 'MANUAL', 254, 137, 53),
  ('6668', '2026-03-28 12:00:00', 90.00, 'PAGAMENTO', 1, 'MANUAL', 'MANUAL', 254, 137, 53),
  ('6668', '2026-03-28 12:00:00', 37.80, 'CASA CAPRI', 1, 'MANUAL', 'MANUAL', 263, 137, 53),
  ('6668', '2026-03-28 12:00:00', 25.00, 'ZonaNoire', 1, 'MANUAL', 'MANUAL', 263, 137, 53),
  ('6668', '2026-03-28 12:00:00', 5.00, 'S2066Alexandre', 1, 'MANUAL', 'MANUAL', 254, 137, 53),
  ('6668', '2026-03-29 12:00:00', 65.39, 'RAIA2012', 1, 'MANUAL', 'MANUAL', 258, 137, 53),
  ('6668', '2026-03-29 12:00:00', 49.96, 'DAISO BRASIL COMERCIO', 1, 'MANUAL', 'MANUAL', 254, 137, 53),
  ('6668', '2026-03-29 12:00:00', 82.70, 'COBASI NORTE SHOPPING', 1, 'MANUAL', 'MANUAL', 256, 137, 53),
  ('6668', '2026-03-30 12:00:00', 41.70, 'DROGARIA NORTE SHOPPIN', 1, 'MANUAL', 'MANUAL', 258, 137, 53),
  ('6668', '2026-04-04 12:00:00', 273.48, 'BAR LIGHT', 1, 'MANUAL', 'MANUAL', 263, 137, 53),
  ('6668', '2026-04-01 12:00:00', 150.00, 'PSICOLOGA TATIANA CASTRO', 1, 'MANUAL', 'MANUAL', 259, 137, 53),
  ('6668', '2026-04-03 12:00:00', 44.38, 'DROGASIL', 1, 'MANUAL', 'MANUAL', 258, 137, 53),
  ('6668', '2026-04-04 12:00:00', 11.00, 'MP*CAMELO', 1, 'MANUAL', 'MANUAL', 254, 137, 53),
  ('6668', '2026-04-04 12:00:00', 55.00, 'MP*MONKEYSBARBЕР', 1, 'MANUAL', 'MANUAL', 266, 137, 53),
  ('6668', '2026-04-04 12:00:00', 46.00, 'ASSINATURA SAMS', 1, 'MANUAL', 'MANUAL', 262, 137, 53),
  ('6668', '2026-04-04 12:00:00', 219.90, 'PAPELARIA E BAZAR 1 DE', 1, 'MANUAL', 'MANUAL', 254, 137, 53),
  ('6668', '2026-04-04 12:00:00', 15.00, 'MILHO RAFA', 1, 'MANUAL', 'MANUAL', 254, 137, 53),
  ('6668', '2026-04-04 12:00:00', 12.00, 'ESTACIONAMENTO K PARK', 1, 'MANUAL', 'MANUAL', 260, 137, 53),
  ('6668', '2026-04-04 12:00:00', 12.00, 'MP*MAOACUSUGARLOCT', 1, 'MANUAL', 'MANUAL', 253, 137, 53),
  ('6668', '2026-04-04 12:00:00', 30.00, 'ACACIO ANTONIO GOUVEIA', 1, 'MANUAL', 'MANUAL', 254, 137, 53),
  ('6668', '2026-04-04 12:00:00', 10.00, 'MP*EDOURAFRESQU', 1, 'MANUAL', 'MANUAL', 254, 137, 53),
  ('6668', '2026-04-04 12:00:00', 150.00, 'PSICOLOGA TATIANA CASTRO', 1, 'MANUAL', 'MANUAL', 259, 137, 53),
  ('6668', '2026-04-05 12:00:00', 249.98, 'CENTAURO CERE', 1, 'MANUAL', 'MANUAL', 265, 137, 53),
  ('6668', '2026-04-10 12:00:00', 89.97, 'HAVAIANAS', 1, 'MANUAL', 'MANUAL', 265, 137, 53),
  ('6668', '2026-04-10 12:00:00', 299.98, 'RIO DE JANEIRO CHAMPIO', 1, 'MANUAL', 'MANUAL', 263, 137, 53),
  ('6668', '2026-04-11 12:00:00', 66.77, 'DROGARIAS PACHECO SA', 1, 'MANUAL', 'MANUAL', 258, 137, 53),
  ('6668', '2026-04-11 12:00:00', 223.37, 'CARREFOUR ATACADAO LIN', 1, 'MANUAL', 'MANUAL', 253, 137, 53),
  ('6668', '2026-04-11 12:00:00', 9.00, 'MP*VEDOURAFRESQU', 1, 'MANUAL', 'MANUAL', 254, 137, 53),
  ('6668', '2026-04-12 12:00:00', 106.90, 'BANDERANTES COMERCIO', 1, 'MANUAL', 'MANUAL', 253, 137, 53),
  ('6668', '2026-04-14 12:00:00', 13.00, 'MP*MALUZERACAI', 1, 'MANUAL', 'MANUAL', 254, 137, 53),
  ('6668', '2026-04-14 12:00:00', 68.40, 'PAPELARIA E BAZAR 1 DE', 1, 'MANUAL', 'MANUAL', 254, 137, 53),
  ('6668', '2026-04-14 12:00:00', 159.97, 'DECATHLON', 1, 'MANUAL', 'MANUAL', 265, 137, 53),
  ('6668', '2026-04-14 12:00:00', 160.00, 'PSICOLOGA TATIANA CASTRO', 1, 'MANUAL', 'MANUAL', 259, 137, 53),
  ('6668', '2026-04-16 12:00:00', 94.00, 'Leitura', 1, 'MANUAL', 'MANUAL', 254, 137, 53),
  ('6668', '2026-04-16 12:00:00', 26.00, 'ESTACIONAMENTO K PARK', 1, 'MANUAL', 'MANUAL', 260, 137, 53),
  ('6668', '2026-04-17 12:00:00', 14.99, 'A NOSSA DROGARIA 07', 1, 'MANUAL', 'MANUAL', 258, 137, 53),
  ('6668', '2026-04-17 12:00:00', 4.80, 'BRASTALIA', 1, 'MANUAL', 'MANUAL', 254, 137, 53),
  ('6668', '2026-04-18 12:00:00', 30.63, 'LEROY MERLIN', 1, 'MANUAL', 'MANUAL', 257, 137, 53),
  ('6668', '2026-04-18 12:00:00', 20.00, 'PASTEL DO ANDERSON', 1, 'MANUAL', 'MANUAL', 263, 137, 53),
  ('6668', '2026-04-19 12:00:00', 141.42, 'ATACADAO 691 AS', 1, 'MANUAL', 'MANUAL', 253, 137, 53),
  ('6668', '2026-04-19 12:00:00', 160.96, 'TUTTO NHOQUE NOVA AMER', 1, 'MANUAL', 'MANUAL', 263, 137, 53),
  ('6668', '2026-04-20 12:00:00', 3.00, 'Leituraicomerci', 1, 'MANUAL', 'MANUAL', 254, 137, 53),
  ('6668', '2026-04-21 12:00:00', 7.00, 'CALIFORNIA COFFEE', 1, 'MANUAL', 'MANUAL', 263, 137, 53),
  ('6668', '2026-04-22 12:00:00', 48.99, 'IFOOD', 1, 'MANUAL', 'MANUAL', 263, 137, 53),
  ('6668', '2026-04-22 12:00:00', 32.63, 'VAGEM MERCADOS LTDA', 1, 'MANUAL', 'MANUAL', 253, 137, 53),
  ('6668', '2026-04-22 12:00:00', 6.45, 'VAGEM MERCADOS LTDA', 1, 'MANUAL', 'MANUAL', 253, 137, 53);

-- 6. Transações - Adicional (Cartão 9687)
INSERT INTO payment_notifications
  (card_last_digits, purchased_at, amount, merchant_name, number_of_installments, origin, origin_type, category_id, payment_method_id, sub_card_id)
VALUES
  ('9687', '2026-01-24 12:00:00', 16.65, 'Serasa Experian 03/12', 1, 'MANUAL', 'MANUAL', 262, 137, 54),
  ('9687', '2026-03-14 12:00:00', 151.72, 'COBASI 02/02', 1, 'MANUAL', 'MANUAL', 256, 137, 54),
  ('9687', '2026-03-29 12:00:00', 148.85, 'NUV*CASASSAOBENTO', 1, 'MANUAL', 'MANUAL', 257, 137, 54),
  ('9687', '2026-04-01 12:00:00', 189.67, 'NET.PGT*Fatura Claro', 1, 'MANUAL', 'MANUAL', 262, 137, 54),
  ('9687', '2026-04-03 12:00:00', 142.11, 'COBASI', 1, 'MANUAL', 'MANUAL', 256, 137, 54),
  ('9687', '2026-04-11 12:00:00', 1879.00, 'HOTEIS.COM', 1, 'MANUAL', 'MANUAL', 261, 137, 54),
  ('9687', '2026-04-19 12:00:00', 19.83, 'MERCADOLIVRE*SUPRICOMPEL', 1, 'MANUAL', 'MANUAL', 254, 137, 54);

-- ============================================================
-- VERIFICAÇÃO
-- ============================================================
-- SELECT COUNT(*) as total_transacoes,
--        SUM(amount) as total_valor
-- FROM payment_notifications
-- WHERE payment_method_id = 137
--   AND origin = 'MANUAL';
-- Esperado: 54 transações, total próximo de R$ 7.484,46
-- ============================================================
