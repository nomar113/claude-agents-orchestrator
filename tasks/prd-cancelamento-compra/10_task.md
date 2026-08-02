# Tarefa 10.0: PurchaseList — Long Press + IonActionSheet

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Implementar interacao de long press nos itens da lista que abre um `IonActionSheet` com opcoes de contexto, incluindo "Cancelar compra".

<skills>
### Conformidade com Skills Padroes

Nenhuma skill especifica aplicavel. Seguir padrao de componentes Ionic do projeto.
</skills>

<requirements>
- Detectar long press (pressao prolongada ~500ms) em cada item da lista
- Ao detectar long press: abrir `IonActionSheet` com opcoes contextuais
- Opcoes para compras ativas: "Cancelar compra", "Excluir registro", "Fechar"
- Opcoes para compras canceladas: "Excluir registro", "Fechar" (sem opcao de cancelar)
- Ao selecionar "Cancelar compra": exibir dialog de confirmacao (RF-04)
- Ao confirmar: chamar API de cancelamento e atualizar lista
- Long press nao deve interferir com scroll ou tap normal
</requirements>

## Subtarefas

- [ ] 10.1 Implementar deteccao de long press via touch events (onTouchStart timer + onTouchEnd/onTouchMove cancel)
- [ ] 10.2 Implementar `IonActionSheet` com opcoes dinamicas baseadas no estado do item
- [ ] 10.3 Conectar acao "Cancelar compra" ao dialog de confirmacao
- [ ] 10.4 Conectar acao "Excluir registro" a funcionalidade de exclusao existente
- [ ] 10.5 Garantir que long press nao dispara durante scroll (cancelar se touch move > threshold)
- [ ] 10.6 Adicionar feedback haptico/visual ao iniciar long press (opcional, se Capacitor Haptics disponivel)

## Detalhes de Implementacao

Referencia: `techspec.md` secao "Decisoes Principais > IonActionSheet"

Deteccao de long press: usar `setTimeout` no `onTouchStart` (500ms) e cancelar no `onTouchMove`/`onTouchEnd`. Se o timer completa sem cancelamento, abrir action sheet.

`IonActionSheet` aceita array de buttons com `text`, `role` (destructive, cancel), e `handler`.

## Criterios de Sucesso

- Long press (~500ms) em item da lista abre action sheet
- Scroll nao dispara long press
- Tap normal nao dispara long press
- Action sheet mostra opcoes corretas baseadas no estado (ativa vs cancelada)
- "Cancelar compra" abre dialog de confirmacao e executa cancelamento
- "Excluir registro" funciona normalmente

## Testes da Tarefa

- [ ] Teste manual: long press abre action sheet
- [ ] Teste manual: scroll rapido nao abre action sheet
- [ ] Teste manual: tap simples nao abre action sheet (navega para detalhe)
- [ ] Teste manual: opcoes corretas para item ativo vs cancelado
- [ ] Teste manual: cancelamento via action sheet funciona end-to-end

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/components/PurchaseList.tsx`
- `src/pages/Tab1.css` (estilos)

### Referencia Visual

Artboard "Cancelamento — Acao + Confirmacao" no Paper (arquivo "ControlAI")
