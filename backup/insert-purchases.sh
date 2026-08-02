#!/bin/bash
# Script para inserir compras de faturas de cartões via API
# API: api.opencod3.com.br
# Payment method: 1 (Itau LATAM) - subCards: 55=2108, 56=8415, 57=2831
# Nubank não tem payment method cadastrado, usa paymentMethodId=1 genérico

set -e

API="https://api.opencod3.com.br/payments/notifications/manual"
CT="Content-Type: application/json"

echo "=== Cartão LATAM 2108 (subCardId=55) ==="

echo "-> BT NORTESH..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"BT NORTESH","amount":129.43,"purchasedAt":"2026-01-15T12:00:00","paymentMethodId":1,"categoryId":1,"cardLastDigits":"2108","subCardId":55,"numberOfInstallments":1}'
echo

echo "-> HB RJ MAGALHA..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"HB RJ MAGALHA","amount":1497.83,"purchasedAt":"2026-03-04T12:00:00","paymentMethodId":1,"categoryId":1,"cardLastDigits":"2108","subCardId":55,"numberOfInstallments":1}'
echo

echo "-> ANUIDADE DIFERENCIADA..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"ANUIDADE DIFERENCIADA","amount":31.00,"purchasedAt":"2026-04-02T12:00:00","paymentMethodId":1,"categoryId":1,"cardLastDigits":"2108","subCardId":55,"numberOfInstallments":1}'
echo

echo ""
echo "=== Cartão 8415 (subCardId=56) ==="

echo "-> ALURA..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"ALURA","amount":87.20,"purchasedAt":"2025-06-23T12:00:00","paymentMethodId":1,"categoryId":10,"cardLastDigits":"8415","subCardId":56,"numberOfInstallments":1}'
echo

echo "-> Disney Plus..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"Disney Plus","amount":46.88,"purchasedAt":"2026-01-06T12:00:00","paymentMethodId":1,"categoryId":10,"cardLastDigits":"8415","subCardId":56,"numberOfInstallments":1}'
echo

echo "-> PET LOVE Clube OT..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"PET LOVE Clube OT","amount":9.99,"purchasedAt":"2026-01-13T12:00:00","paymentMethodId":1,"categoryId":4,"cardLastDigits":"8415","subCardId":56,"numberOfInstallments":1}'
echo

echo "-> Estacionamento 20WP2Q..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"Estacionamento 20WP2Q","amount":64.40,"purchasedAt":"2026-04-04T12:00:00","paymentMethodId":1,"categoryId":12,"cardLastDigits":"8415","subCardId":56,"numberOfInstallments":1}'
echo

echo "-> Smiles Clube Smiles..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"Smiles Clube Smiles","amount":46.00,"purchasedAt":"2026-04-05T12:00:00","paymentMethodId":1,"categoryId":10,"cardLastDigits":"8415","subCardId":56,"numberOfInstallments":1}'
echo

echo "-> Estacionamento 20XD5E..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"Estacionamento 20XD5E","amount":64.40,"purchasedAt":"2026-04-05T12:00:00","paymentMethodId":1,"categoryId":12,"cardLastDigits":"8415","subCardId":56,"numberOfInstallments":1}'
echo

echo "-> ANCAR PARKING EST..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"ANCAR PARKING EST","amount":18.00,"purchasedAt":"2026-04-23T12:00:00","paymentMethodId":1,"categoryId":12,"cardLastDigits":"8415","subCardId":56,"numberOfInstallments":1}'
echo

echo "-> DL*GOOGLE Google (1)..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"DL*GOOGLE Google","amount":9.99,"purchasedAt":"2026-04-24T12:00:00","paymentMethodId":1,"categoryId":10,"cardLastDigits":"8415","subCardId":56,"numberOfInstallments":1}'
echo

echo "-> DL*GOOGLE Google (2)..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"DL*GOOGLE Google","amount":9.99,"purchasedAt":"2026-04-24T13:00:00","paymentMethodId":1,"categoryId":10,"cardLastDigits":"8415","subCardId":56,"numberOfInstallments":1}'
echo

echo "-> APPLE.COM/BILL..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"APPLE.COM/BILL","amount":109.90,"purchasedAt":"2026-04-29T12:00:00","paymentMethodId":1,"categoryId":10,"cardLastDigits":"8415","subCardId":56,"numberOfInstallments":1}'
echo

echo ""
echo "=== Cartão 2831 Aline (subCardId=57) ==="

echo "-> TOKIO MARINE AUTO..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"TOKIO MARINE AUTO","amount":389.37,"purchasedAt":"2026-04-29T12:00:00","paymentMethodId":1,"categoryId":3,"cardLastDigits":"2831","subCardId":57,"numberOfInstallments":1}'
echo

echo ""
echo "=== Nubank 6668 (Aline) ==="

echo "-> RAIA2012..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"RAIA2012","amount":65.39,"purchasedAt":"2026-03-29T12:00:00","paymentMethodId":1,"categoryId":6,"cardLastDigits":"6668"}'
echo

echo "-> DAISO BRASIL COMERCIO..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"DAISO BRASIL COMERCIO","amount":49.96,"purchasedAt":"2026-03-29T12:00:00","paymentMethodId":1,"categoryId":1,"cardLastDigits":"6668"}'
echo

echo "-> PSICOLOGA TATIANA CASTRO (01/04)..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"PSICOLOGA TATIANA CASTRO","amount":150.00,"purchasedAt":"2026-04-01T12:00:00","paymentMethodId":1,"categoryId":7,"cardLastDigits":"6668"}'
echo

echo "-> MP*BARRACADOAGRICULTOR..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"MP*BARRACADOAGRICULTOR","amount":12.00,"purchasedAt":"2026-04-05T08:30:00","paymentMethodId":1,"categoryId":2,"cardLastDigits":"6668"}'
echo

echo "-> CENTAURO CE86..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"CENTAURO CE86","amount":249.98,"purchasedAt":"2026-04-10T12:00:00","paymentMethodId":1,"categoryId":1,"cardLastDigits":"6668"}'
echo

echo "-> HAVAIANAS..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"HAVAIANAS","amount":80.97,"purchasedAt":"2026-04-10T12:00:00","paymentMethodId":1,"categoryId":1,"cardLastDigits":"6668"}'
echo

echo "-> DROGARIAS PACHECO SA..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"DROGARIAS PACHECO SA","amount":66.77,"purchasedAt":"2026-04-11T12:00:00","paymentMethodId":1,"categoryId":6,"cardLastDigits":"6668"}'
echo

echo "-> PSICOLOGA TATIANA CASTRO (16/04)..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"PSICOLOGA TATIANA CASTRO","amount":150.00,"purchasedAt":"2026-04-16T12:00:00","paymentMethodId":1,"categoryId":7,"cardLastDigits":"6668"}'
echo

echo "-> Leiturariocomerci..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"Leiturariocomerci","amount":3.00,"purchasedAt":"2026-04-20T12:00:00","paymentMethodId":1,"categoryId":1,"cardLastDigits":"6668"}'
echo

echo "-> Veterinário Yuna (1260)..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"Veterinário Yuna","amount":1260.00,"purchasedAt":"2026-03-28T12:00:00","paymentMethodId":1,"categoryId":4,"cardLastDigits":"6668"}'
echo

echo "-> Veterinário Yuna (90)..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"Veterinário Yuna","amount":90.00,"purchasedAt":"2026-03-28T12:00:00","paymentMethodId":1,"categoryId":4,"cardLastDigits":"6668"}'
echo

echo ""
echo "=== Nubank 9687 (Ramon) ==="

echo "-> Serasa Experian..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"Serasa Experian","amount":16.65,"purchasedAt":"2026-01-24T12:00:00","paymentMethodId":1,"categoryId":10,"cardLastDigits":"9687","numberOfInstallments":1}'
echo

echo "-> COBASI..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"COBASI","amount":151.72,"purchasedAt":"2026-03-14T12:00:00","paymentMethodId":1,"categoryId":4,"cardLastDigits":"9687","numberOfInstallments":1}'
echo

echo "-> MERCADOLIVRE*SUPRICOMPEL..."
curl -s -X POST "$API" -H "$CT" \
  -d '{"merchantName":"MERCADOLIVRE*SUPRICOMPEL","amount":19.83,"purchasedAt":"2026-04-19T12:00:00","paymentMethodId":1,"categoryId":1,"cardLastDigits":"9687"}'
echo

echo ""
echo "=== DONE! 28 compras inseridas ==="
