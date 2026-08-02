-- ============================================================
-- BACKUP: Fatura Itaú Visa Platinum LATAM Pass - Vencimento 08/05/2026
-- Cartões: 2108 (Titular), 8415 (Ramon), 2831 (Aline - Dependente)
-- Total da fatura: R$ 2.537,77
-- Gerado em: 2026-05-02
-- ============================================================

-- 1. Payment Method
INSERT INTO payment_methods (id, name, type, holder_id, closing_day, created_at, updated_at)
VALUES (138, 'Itau Visa Platinum LATAM Pass', 'CREDIT_CARD', 169, 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- 2. Sub Cards
INSERT INTO sub_cards (id, payment_method_id, last_four_digits, type, nickname, dependent_name, created_at, updated_at)
VALUES
  (55, 138, '2108', 'PHYSICAL_HOLDER', 'Titular Ramon', NULL, NOW(), NOW()),
  (56, 138, '8415', 'PHYSICAL_HOLDER', 'Cartao 2 Ramon', NULL, NOW(), NOW()),
  (57, 138, '2831', 'PHYSICAL_DEPENDENT', 'Aline', 'Aline C da S Diogo', NOW(), NOW())
ON DUPLICATE KEY UPDATE nickname = VALUES(nickname);

-- 3. Transações - Cartão 2108 (Titular)
INSERT INTO payment_notifications
  (card_last_digits, purchased_at, amount, merchant_name, number_of_installments, origin, origin_type, category_id, payment_method_id, sub_card_id)
VALUES
  ('2108', '2026-01-15 12:00:00', 129.43, 'BT NORDEST 04/10', 1, 'MANUAL', 'MANUAL', 263, 138, 55),
  ('2108', '2026-03-04 12:00:00', 1497.82, 'HB RJ MAGALHA 02/02', 1, 'MANUAL', 'MANUAL', 255, 138, 55),
  ('2108', '2026-04-02 12:00:00', 31.00, 'ANUIDADE DIFERENCI (liquido)', 1, 'MANUAL', 'MANUAL', 254, 138, 55);

-- 4. Transações - Cartão 8415 (Ramon)
INSERT INTO payment_notifications
  (card_last_digits, purchased_at, amount, merchant_name, number_of_installments, origin, origin_type, category_id, payment_method_id, sub_card_id)
VALUES
  ('8415', '2026-06-23 12:00:00', 87.20, 'ALURA 11/12', 1, 'MANUAL', 'MANUAL', 264, 138, 56),
  ('8415', '2026-01-06 12:00:00', 46.88, 'Disney Plus 04/12', 1, 'MANUAL', 'MANUAL', 262, 138, 56),
  ('8415', '2026-01-13 12:00:00', 9.99, 'PET LOVE*Clube OT 04/12', 1, 'MANUAL', 'MANUAL', 256, 138, 56),
  ('8415', '2026-04-04 12:00:00', 64.40, 'Estacionamento 20WP20', 1, 'MANUAL', 'MANUAL', 260, 138, 56),
  ('8415', '2026-04-04 12:00:00', 46.00, 'Clube Smiles', 1, 'MANUAL', 'MANUAL', 262, 138, 56),
  ('8415', '2026-04-05 12:00:00', 64.40, 'Estacionamento 20XD5E', 1, 'MANUAL', 'MANUAL', 260, 138, 56),
  ('8415', '2026-04-20 12:00:00', 23.40, 'ANCAR PARKINGEST', 1, 'MANUAL', 'MANUAL', 260, 138, 56),
  ('8415', '2026-04-23 12:00:00', 18.00, 'ANCAR PARKINGEST', 1, 'MANUAL', 'MANUAL', 260, 138, 56),
  ('8415', '2026-04-24 12:00:00', 9.99, 'DL*GOOGLE Google', 1, 'MANUAL', 'MANUAL', 262, 138, 56),
  ('8415', '2026-04-24 12:00:00', 9.99, 'DL*GOOGLE Google', 1, 'MANUAL', 'MANUAL', 262, 138, 56),
  ('8415', '2026-04-29 12:00:00', 109.90, 'APPLE.COM/BILL', 1, 'MANUAL', 'MANUAL', 262, 138, 56);

-- 5. Transações - Cartão 2831 (Aline - Dependente)
INSERT INTO payment_notifications
  (card_last_digits, purchased_at, amount, merchant_name, number_of_installments, origin, origin_type, category_id, payment_method_id, sub_card_id)
VALUES
  ('2831', '2026-04-29 12:00:00', 389.37, 'OBOTICARIO MARINE AUTO', 1, 'MANUAL', 'MANUAL', 266, 138, 57);

-- ============================================================
-- NOTAS:
-- - HB RJ MAGALHA: valor original 1497.83, ajustado para 1497.82
--   (estorno de -0.01 consolidado)
-- - ANUIDADE: valor original 62.00 com estorno de -31.00,
--   registrado o líquido de 31.00
-- - Transações com parcelas (ex: 04/10, 02/02, 11/12)
--   registradas como parcela única desta fatura
-- ============================================================
-- VERIFICAÇÃO
-- SELECT SUM(amount) FROM payment_notifications WHERE payment_method_id = 138;
-- Esperado: 2537.77
-- ============================================================
