# PRD: Importacao de Historico da Planilha

## Visao Geral

O casal Ramon e Aline utiliza uma planilha Google Sheets ha meses para rastrear todos os gastos de cartoes de credito. Essa planilha contem historico financeiro valioso — padroes de gasto, evolucao mensal, gastos recorrentes. Ao migrar para o ControlAi, perder esse historico significaria comecar do zero, sem base de comparacao.

A planilha possui dois formatos distintos:
- **Formato antigo**: colunas Data, Estabelecimento, Divisao (parcelas), e valores separados por categoria/titular (RAMON, ALINE, COMIDA, TRANSPORTE, SAUDE, CASA)
- **Formato 2026 (atual)**: colunas DATA, DESCRICAO, PARCELAS, VALOR, CARTAO, FINAL CARTAO, CATEGORIA, e flag TRUE/FALSE

A importacao deve suportar ambos os formatos, mapear os dados para o modelo do ControlAi, e evitar duplicatas.

## Objetivos

- Permitir importacao de 100% do historico da planilha para o ControlAi
- Suportar ambos os formatos de planilha (antigo e 2026)
- Garantir zero duplicatas na importacao (mesmo arquivo importado duas vezes)
- Completar a importacao de um mes tipico (50-80 entradas) em menos de 10 segundos
- Fornecer relatorio de erros claro para entradas que nao puderam ser importadas

## Historias de Usuario

- Como Ramon, eu quero importar os dados da planilha de 2026 para que eu tenha historico de comparacao ao comecar a usar o app
- Como Ramon, eu quero importar dados do formato antigo da planilha para que eu mantenha todo o historico, nao apenas 2026
- Como Ramon, eu quero que o sistema me avise sobre entradas duplicadas para que eu nao importe o mesmo mes duas vezes
- Como Ramon, eu quero ver um resumo da importacao (quantas entradas importadas, quantas ignoradas, quantos erros) para que eu saiba se a importacao foi bem-sucedida
- Como Ramon, eu quero associar cada importacao a um mes/ano especifico para que os dados fiquem organizados corretamente

## Funcionalidades Principais

### RF01 - Upload de Arquivo CSV

O sistema deve permitir upload de arquivos CSV exportados do Google Sheets:
- Aceitar arquivos .csv com codificacao UTF-8
- Limite de tamanho: 5MB por arquivo
- O usuario deve informar o mes/ano de referencia do arquivo
- Validar que o arquivo possui headers reconheciveis antes de prosseguir

### RF02 - Deteccao Automatica de Formato

O sistema deve detectar automaticamente qual formato de planilha esta sendo importado:
- **Formato 2026**: detectar headers DATA, DESCRICAO, PARCELAS, VALOR, CARTAO, FINAL CARTAO, CATEGORIA
- **Formato antigo**: detectar headers Data, Estabelecimento, Divisao, RAMON, ALINE, COMIDA, TRANSPORTE, SAUDE, CASA
- Informar ao usuario qual formato foi detectado antes de prosseguir

### RF03 - Mapeamento de Dados do Formato Antigo

Para o formato antigo, o sistema deve:
- Identificar a categoria pelo nome da coluna onde o valor esta (COMIDA → Comida, TRANSPORTE → Transporte, etc.)
- Identificar o titular: valor na coluna RAMON → titular Ramon; valor na coluna ALINE → titular Aline
- Mapear "Divisao" para o formato de parcelas (atual/total)
- Solicitar ao usuario qual cartao associar (ja que o formato antigo nao tem coluna de cartao)

### RF04 - Mapeamento de Dados do Formato 2026

Para o formato 2026, o sistema deve:
- Mapear diretamente: DATA → data, DESCRICAO → descricao, PARCELAS → parcelas, VALOR → valor, CARTAO → cartao, FINAL CARTAO → final_cartao, CATEGORIA → categoria
- Mapear o flag TRUE/FALSE para o campo de verificado
- Validar que o cartao informado existe no cadastro do sistema

### RF05 - Prevencao de Duplicatas

O sistema deve evitar importar entradas duplicadas:
- Verificar por combinacao de: data + descricao + valor + mes/ano
- Entradas duplicadas sao listadas no relatorio mas nao importadas
- O usuario pode forcar a importacao de duplicatas se desejar

### RF06 - Pre-visualizacao e Confirmacao

Antes de efetivar a importacao, exibir:
- Numero total de entradas encontradas no arquivo
- Numero de entradas novas (serao importadas)
- Numero de duplicatas detectadas (serao ignoradas)
- Numero de entradas com erro (dados invalidos)
- Lista das entradas com erro e o motivo
- Botao de confirmar para efetivar a importacao

### RF07 - Relatorio de Importacao

Apos a importacao, exibir relatorio final:
- Total de entradas importadas com sucesso
- Total de duplicatas ignoradas
- Total de erros
- Valor total importado no mes
- Opcao de desfazer a importacao inteira (dentro de 5 minutos)

## Experiencia do Usuario

**Fluxo principal:**
1. Usuario acessa tela de importacao (via configuracoes ou menu)
2. Seleciona arquivo CSV do dispositivo
3. Sistema detecta formato e exibe: "Formato 2026 detectado — 67 entradas encontradas"
4. Sistema exibe pre-visualizacao: "62 novas, 3 duplicatas, 2 erros"
5. Usuario revisa erros se necessario
6. Usuario confirma importacao
7. Sistema processa e exibe relatorio final
8. Toast: "62 entradas importadas com sucesso para Mar/2026"

**Fluxo de formato antigo:**
1. Mesmos passos 1-2
2. Sistema detecta formato antigo e solicita informacao adicional: "Qual cartao associar a estas entradas?"
3. Usuario seleciona cartao padrao
4. Segue passos 4-8

**Consideracoes de UX:**
- A importacao deve ser simples e guiada (wizard de poucos passos)
- Erros devem ser claros e acionaveis ("Linha 15: valor invalido 'abc'")
- A opcao de desfazer da tranquilidade ao usuario
- Progress bar durante importacao de arquivos grandes

**Acessibilidade:**
- Botao de upload deve ser grande e claro
- Relatorio de erros deve ser acessivel por leitores de tela
- Status de progresso deve ser comunicado textualmente

## Restricoes Tecnicas de Alto Nivel

- Depende do PRD de Modelo de Dados (estrutura de destino dos dados)
- Depende do PRD de Gestao de Cartoes (para validar cartoes referenciados)
- Arquivos CSV exportados do Google Sheets usam codificacao UTF-8
- Valores monetarios na planilha usam virgula como separador decimal (formato brasileiro)
- A importacao deve ser atomica: ou todas as entradas validas sao importadas, ou nenhuma
- Dados importados devem ser indistinguiveis de dados registrados manualmente apos a importacao

## Fora de Escopo

- Importacao direta da API do Google Sheets (sem necessidade de exportar CSV)
- Importacao de dados de planejamento/orcamento (apenas gastos)
- Importacao de dados de receitas
- Importacao de extratos bancarios (OFX, PDF)
- Sincronizacao automatica continua com a planilha
- Importacao de dados de outros aplicativos financeiros
- Migracao de dados entre instancias do ControlAi
