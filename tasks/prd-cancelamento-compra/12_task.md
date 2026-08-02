# Tarefa 12.0: Estilos Visuais da Lista

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visao Geral

Implementar os estilos visuais que diferenciam compras canceladas das ativas na listagem.

<skills>
### Conformidade com Skills Padroes

Nenhuma skill especifica aplicavel. Seguir padrao de CSS do projeto.
</skills>

<requirements>
- Opacidade reduzida (55%) no item inteiro para compras canceladas (RF-08)
- Icone de categoria substituido por icone neutro (circulo com linha diagonal) em tom cinza (RF-09)
- Badge "CANCELADA" em cor amber (#F59E0B) ao lado do nome do estabelecimento (RF-10)
- Valor da compra com line-through (tachado) (RF-11)
- Manter posicao cronologica na lista (RF-12) — ja garantido pela query
- Badge deve ser acessivel via screen reader
- Contraste amber sobre fundo escuro deve atender WCAG AA
</requirements>

## Subtarefas

- [ ] 12.1 Adicionar classe CSS condicional no item quando `cancelledAt` esta preenchido
- [ ] 12.2 Implementar opacidade 55% no container do item cancelado
- [ ] 12.3 Criar/usar icone neutro (circulo com linha diagonal) em cinza para canceladas
- [ ] 12.4 Implementar badge "CANCELADA" com estilo amber ao lado do merchant name
- [ ] 12.5 Aplicar text-decoration line-through no valor da compra cancelada
- [ ] 12.6 Adicionar aria-label no badge para acessibilidade
- [ ] 12.7 Verificar contraste WCAG AA do amber (#F59E0B) sobre fundo escuro do app

## Detalhes de Implementacao

Referencia: `techspec.md` secao "Visao Geral dos Componentes > Novos estilos CSS"

Aplicar estilos condicionalmente baseado na presenca de `cancelledAt` no item. Usar `className` condicional ou CSS com seletor de atributo.

Icone neutro: usar `banOutline` do ionicons (circulo com linha diagonal) ou criar SVG simples.

## Criterios de Sucesso

- Compras canceladas sao visualmente distintas das ativas
- Opacidade 55% aplicada corretamente
- Badge "CANCELADA" visivel e com cor amber
- Valor tachado (line-through)
- Icone neutro cinza no lugar do icone de categoria
- Acessibilidade: screen reader le "CANCELADA" no item
- Contraste atende WCAG AA

## Testes da Tarefa

- [ ] Teste visual: comparar com artboard "Cancelamento — Lista" no Paper
- [ ] Teste de acessibilidade: VoiceOver le badge "CANCELADA"
- [ ] Teste de contraste: verificar ratio do amber sobre fundo escuro (usar ferramenta de contraste)
- [ ] Teste manual: itens cancelados e ativos coexistem corretamente na mesma lista

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- `src/components/PurchaseList.tsx`
- `src/pages/Tab1.css` (ou novo arquivo CSS para estilos de cancelamento)

### Referencia Visual

Artboard "Cancelamento — Lista" no Paper (arquivo "ControlAI")
