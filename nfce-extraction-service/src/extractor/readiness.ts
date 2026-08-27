// The SEFAZ-RJ page goes through a reCAPTCHA v3 check and an F5/TSPD anti-bot
// challenge that reload the document several times before the invoice renders.
// Poll this until it returns true instead of waiting a fixed delay.
export function isInvoiceReadyRJ(): boolean;
export function isInvoiceReadyRJ(doc: Document): boolean;
export function isInvoiceReadyRJ(doc: Document = document): boolean {
  return (
    !!doc.querySelector('.txtTopo') &&
    doc.querySelectorAll('#tabResult tr[id^="Item"]').length > 0 &&
    !!doc.querySelector('#totalNota .totalNumb.txtMax')
  );
}
