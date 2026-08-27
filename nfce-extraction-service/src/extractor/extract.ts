import { ExtractedInvoice } from '../types';

// This function is passed directly to Playwright's page.evaluate, which serializes it
// via toString() and re-runs it isolated in the browser — any reference to module-level
// scope (helper functions included) would throw a ReferenceError there, so every helper
// must be nested inside the function body instead of living at module scope.
export function extractDataFromRJ(): ExtractedInvoice;
export function extractDataFromRJ(doc: Document): ExtractedInvoice;
export function extractDataFromRJ(doc: Document = document): ExtractedInvoice {
  const DATE_FIELD_LENGTH = '00/00/0000 00:00:00-00:00'.length;

  function toNumber(rawValue: string): number {
    return parseFloat(rawValue.replace(/\./g, '').replace(',', '.'));
  }

  const merchantName = doc.querySelector('.txtTopo')!.textContent!.replace(/\s+/g, ' ').trim();
  const cnpj = doc.querySelector('.text')!.textContent!.replace('CNPJ:', '').replace(/\s+/g, '').trim();
  const merchantAddress = doc
    .querySelector('.text')!
    .nextElementSibling!.textContent!.replace(/\t/g, '')
    .replace(/\n/g, '')
    .replace(/\s+/g, ' ')
    .replace(/\s*,\s*/g, ', ')
    .trim();

  const items: ExtractedInvoice['items'] = [];
  doc.querySelectorAll('#tabResult tr[id^="Item"]').forEach((row) => {
    const td = row.querySelectorAll('td');
    items.push({
      productName: td[0].querySelector('.txtTit')!.textContent!,
      code: td[0].querySelector('.RCod')!.textContent!.replace('(Código:', '').replace(')', '').trim(),
      quantity: toNumber(td[0].querySelector('.Rqtd')!.textContent!.replace('Qtde.:', '').trim()),
      unit: td[0].querySelector('.RUN')!.textContent!.replace('UN:', '').trim(),
      unitPrice: toNumber(td[0].querySelector('.RvlUnit')!.textContent!.replace('Vl. Unit.:', '').trim()),
      totalPrice: toNumber(td[1].querySelector('.valor')!.textContent!),
    });
  });

  const values = doc.querySelectorAll('#totalNota .totalNumb');
  const totalItems = toNumber(values[0].textContent!);

  const discountLabel = 'Descontos R$:';
  const discountElement = Array.from(doc.querySelectorAll('#totalNota label')).find(
    (element) => element.textContent!.trim() === discountLabel,
  );

  let subtotal = 0;
  let discount = 0;
  if (discountElement) {
    subtotal = toNumber(values[1].textContent!);
    discount = toNumber(discountElement.nextElementSibling!.textContent!);
  }

  const total = toNumber(doc.querySelector('#totalNota .totalNumb.txtMax')!.textContent!);

  const taxesElement = doc.querySelector('#totalNota .totalNumb.txtObs');
  let taxes = 0;
  if (taxesElement) {
    taxes = toNumber(taxesElement.textContent!);
    if (isNaN(taxes)) {
      taxes = 0;
    }
  }

  const paymentValueElements = Array.from(doc.querySelectorAll('#linhaTotal span.totalNumb'));
  const totalIndex = paymentValueElements.findIndex((element) => element.classList.contains('txtMax'));
  const paymentMethodElements = Array.from(doc.querySelectorAll('#linhaTotal label.tx'));
  const payments = paymentMethodElements.map((element, index) => ({
    type: element.textContent!.trim(),
    value: toNumber(paymentValueElements[totalIndex + index + 1].textContent!),
  }));

  const dateLabel = Array.from(doc.querySelectorAll('strong')).find(
    (el) => el.textContent?.replace(/\s+/g, ' ').trim() === 'Emissão:',
  );
  const date = dateLabel!.nextSibling!.textContent!.trim().substring(0, DATE_FIELD_LENGTH);

  return {
    merchantName,
    cnpj,
    merchantAddress,
    totalItems,
    subtotal,
    discount,
    total,
    taxes,
    date,
    items,
    payments,
  };
}
