# Tarefa 11.0: PurchaseDetail — Cancelamento

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Atualizar a tela de detalhe de compra para suportar cancelamento: botao "Cancelar compra" para compras ativas e indicadores visuais para compras canceladas.

<skills>
### Conformidade com Skills Padroes

Nenhuma skill especifica aplicavel. Seguir padrao de paginas Ionic do projeto.
</skills>

<requirements>
- Adicionar botao "Cancelar compra" (cor amber) acima do botao "Excluir registro" para compras ativas (RF-01)
- Nao exibir botao "Cancelar compra" para compras ja canceladas (RF-17)
- Manter botao "Excluir registro" disponivel para canceladas (RF-18)
- Exibir banner amber "Esta compra foi cancelada" abaixo do header para canceladas (RF-13)
- Exibir valor principal com line-through e opacidade reduzida para canceladas (RF-14)
- Substituir icone principal por icone neutro (circulo com linha diagonal) para canceladas (RF-15)
- Adicionar campo "Status: Cancelada" com indicador amber na secao de informacoes (RF-16)
- Dialog de confirmacao antes de cancelar (RF-04, RF-05)
- Apos cancelar: atualizar tela imediatamente para refletir estado cancelado
</requirements>

## Subtarefas

- [ ] 11.1 Adicionar botao "Cancelar compra" com estilo amber (condicional: apenas para ativas)
- [ ] 11.2 Implementar dialog de confirmacao ao clicar "Cancelar compra"
- [ ] 11.3 Chamar API de cancelamento e atualizar estado local apos sucesso
- [ ] 11.4 Implementar banner amber "Esta compra foi cancelada" (condicional: apenas para canceladas)
- [ ] 11.5 Aplicar line-through e opacidade no valor principal para canceladas
- [ ] 11.6 Substituir icone por icone neutro para canceladas
- [ ] 11.7 Adicionar campo "Status: Cancelada" na secao de informacoes
- [ ] 11.8 Garantir que "Excluir registro" continua disponivel para canceladas

## Detalhes de Implementacao

Referencia: `techspec.md` secao "Visao Geral dos Componentes > PurchaseDetail.tsx"

O detalhe ja carrega dados via `getNotificationById(id)` ou `getInvoiceById(id)`. Verificar `cancelledAt` no response para decidir qual estado renderizar.

Hierarquia de botoes: "Cancelar compra" (amber) > "Excluir registro" (vermelho/destrutivo).

## Criterios de Sucesso

- Compra ativa mostra botao "Cancelar compra" amber
- Compra cancelada mostra banner amber + valor tachado + icone neutro + campo status
- Compra cancelada NAO mostra botao "Cancelar compra"
- Compra cancelada AINDA mostra "Excluir registro"
- Cancelamento via detalhe atualiza a tela instantaneamente
- Dialog de confirmacao funciona corretamente

## Testes da Tarefa

- [ ] Teste manual: tela de compra ativa mostra botao cancelar
- [ ] Teste manual: cancelar via detalhe atualiza todos os indicadores visuais
- [ ] Teste manual: tela de compra cancelada mostra banner + estilos corretos
- [ ] Teste manual: "Excluir registro" funciona para compra cancelada
- [ ] Verificar acessibilidade: banner e status legiveis por screen reader

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/pages/PurchaseDetail.tsx`
- `src/pages/PurchaseDetail.css`
- `src/services/purchaseService.ts`

### Referencia Visual

Artboard "Cancelamento — Detalhe" no Paper (arquivo "ControlAI")
