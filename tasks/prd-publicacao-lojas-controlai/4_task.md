# Tarefa 4.0: Screenshots de loja a partir do design (Paper)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Exportar, a partir do arquivo de design já existente no Paper ("ControlAI"), os screenshots das telas principais (dashboard, cartões, faturas, orçamento) nos tamanhos de dispositivo exigidos pela App Store e pela Google Play, para uso nas fichas de loja das Tarefas 5.0 e 6.0.

<skills>
### Conformidade com Skills Padrões

- `ionic-design` — checagem visual de que os artboards exportados são fiéis à UI real publicada.
</skills>

<requirements>
- PRD `Funcionalidades Principais > 1. Ficha de loja`, requisito 2: screenshots representativos das principais telas (dashboard, cartões, faturas, orçamento) em ambas as lojas.
- PRD `Experiência do Usuário`: screenshots devem ser compreensíveis e legíveis (contraste adequado).
- Tech Spec `Arquitetura do Sistema`: reaproveitar os artboards já existentes no arquivo Paper "ControlAI" (`Dashboard — Home`, `Cartões — Lista`, `Orçamento Mensal`, `Detalhe — Nota Fiscal`), em vez de capturar a UI real renderizada.
</requirements>

## Subtarefas

- [ ] 4.1 Abrir o arquivo Paper "ControlAI" (`01KM6VMAY9XBB4E4KWF7B6G7W4`) e confirmar que os artboards `Dashboard — Home`, `Cartões — Lista`, `Orçamento Mensal` e `Detalhe — Nota Fiscal` refletem fielmente a UI atualmente publicada (comparar com o app real; ajustar a escolha de artboard se algum estiver desatualizado).
- [ ] 4.2 Exportar cada artboard escolhido nos tamanhos de dispositivo exigidos pela App Store (ex.: iPhone 6.7" e 6.5") e pela Google Play (telefone e, se aplicável, tablet).
- [ ] 4.3 Organizar os arquivos exportados por loja e por tamanho, prontos para upload nas Tarefas 5.0 e 6.0.
- [ ] 4.4 Validar legibilidade e contraste dos screenshots exportados nos tamanhos finais.

## Detalhes de Implementação

Ver Tech Spec `Arquitetura do Sistema` (screenshots de loja) e `Considerações Técnicas > Decisões Principais` (uso do design em vez de captura real). Nenhuma alteração de código de aplicação.

## Critérios de Sucesso

- Conjunto completo de screenshots (dashboard, cartões, faturas, orçamento) exportado nos tamanhos exigidos por cada loja.
- Screenshots visualmente fiéis à UI real publicada, com boa legibilidade e contraste.
- Arquivos prontos para upload direto nas Tarefas 5.0 e 6.0.

## Testes da Tarefa

- [ ] Teste manual: comparação lado a lado de cada screenshot exportado com a tela real correspondente no app publicado, confirmando fidelidade.
- [ ] Teste manual: verificação de que os tamanhos de imagem exportados atendem às especificações de cada loja no momento do upload.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- Novo: pasta local de screenshots exportados (fora do repositório de código, para upload manual nas Tarefas 5.0/6.0).
- Referência: arquivo de design Paper "ControlAI" (`01KM6VMAY9XBB4E4KWF7B6G7W4`), artboards `1-0`, `CW-0`, `158-0`, `RL-0`.
- Depende de: nenhuma outra tarefa deste PRD (pode ser feita em paralelo às Tarefas 1.0, 2.0 e 3.0).
