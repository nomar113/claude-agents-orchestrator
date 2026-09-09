# Review: Task 1.0 - Criar produto de assinatura na Kiwify (anual + order bump vitalício)

**Revisor**: AI Code Reviewer
**Data**: 2026-09-09
**Arquivo da task**: 1_task.md
**Status**: APROVADO COM OBSERVAÇÕES

## Resumo

Esta tarefa não envolveu código — foi a configuração manual/via navegador de um produto real de cobrança recorrente na Kiwify (assinatura anual R$ 77/ano + order bump vitalício R$ 197,00 + webhook), conforme RF-5 a RF-8 do PRD e a seção "Pontos de Integração"/"Dependências Técnicas" do Tech Spec. Por isso, esta revisão foi adaptada: em vez de typecheck/testes/convenções de nomenclatura de código, avaliou-se a qualidade e honestidade da documentação de configuração (`.secrets/kiwify-comercializacao-controlai.md`), a atualização de `tasks.md` e o tratamento dado aos "Testes da Tarefa".

Avaliação geral: o trabalho está correto, completo e — o ponto mais importante — **honesto**. Nenhuma subtarefa foi marcada como concluída sem evidência real, e o teste bloqueado por dependência (Tarefa 4.0) foi corretamente deixado como pendente em vez de ser falsamente marcado como feito. As duas decisões fora do PRD/Tech Spec (preço do vitalício e link provisório da página de vendas) estão registradas como pendências. Os únicos pontos levantados são de natureza "minor" — melhorias de rastreabilidade da documentação, não bloqueios.

## Arquivos Revisados

| Arquivo | Status | Problemas |
|---------|--------|-----------|
| `tasks/prd-comercializacao-controlai/1_task.md` | OK | 0 |
| `tasks/prd-comercializacao-controlai/tasks.md` | OK | 0 |
| `.gitignore` | OK | 0 |
| `.secrets/kiwify-comercializacao-controlai.md` (não versionado) | OK | 2 minor |

## Problemas Encontrados

### Problemas Críticos

Nenhum problema crítico encontrado.

### Problemas Major

Nenhum problema major encontrado.

### Problemas Minor

1. **`.secrets/kiwify-comercializacao-controlai.md` — nomes das propriedades de configuração não explicitados junto aos IDs.**
   O Tech Spec (seção "Pontos de Integração") define que o mapeamento de plano na Tarefa 4.0 usará as propriedades `kiwify.product.annual-id` e `kiwify.product.lifetime-id`. O arquivo de segredos documenta os `Product ID` corretos e a associação semântica (anual vs. vitalício) fica clara pelo contexto, mas não nomeia explicitamente qual valor vai em qual propriedade.
   **Sugestão**: adicionar uma linha por produto no formato `kiwify.product.annual-id = f3ae4750-ac67-11f1-b162-19836e161bb8` e `kiwify.product.lifetime-id = 2a333aa0-ac69-11f1-84ab-6f8584fa9657`, para que a Tarefa 4.0 possa copiar o valor diretamente sem interpretação.

2. **RF-8 ("sem período de teste gratuito adicional") não tem confirmação explícita de que nenhum trial foi configurado.**
   O documento confirma a garantia de 7 dias (direito de arrependimento) no produto de assinatura, mas não registra explicitamente que o campo de "período de teste gratuito" (trial), se existente no painel da Kiwify, foi deixado desabilitado/zerado — que é a segunda metade do RF-8.
   **Sugestão**: adicionar uma linha confirmando que nenhum trial foi configurado (ou que a Kiwify não oferece esse campo para o tipo de produto usado), para fechar o requisito com a mesma explicitação dada à garantia.

## Destaques Positivos

- **Honestidade no tratamento dos "Testes da Tarefa"**: o teste de checkout foi validado visualmente e documentado com detalhes reais (inclusive a observação sobre o valor de R$ 244,44 em 12x, corretamente atribuído a juros de parcelamento e não a erro de configuração). O teste do "Test Webhook" foi deixado **não marcado**, com justificativa clara de bloqueio pela Tarefa 4.0 (endpoint ainda não existe) — exatamente o comportamento esperado de uma tarefa bem executada, evitando o antipadrão de marcar teste como concluído sem executá-lo.
- **Rastreabilidade RF-5 a RF-8**: cada subtarefa (1.2 a 1.4) referencia explicitamente o requisito funcional do PRD que está satisfazendo, facilitando a auditoria.
- **Tratamento correto de ambiguidade legal**: ao constatar que o produto de pagamento único não expõe o campo de garantia no painel da Kiwify, a tarefa não inventou uma configuração — explicou corretamente que o direito de arrependimento de 7 dias (CDC art. 49) se aplica por lei, independente da configuração do produto.
- **Duas decisões fora do escopo do PRD/Tech Spec foram capturadas como pendências, não escondidas**: o preço do upgrade vitalício (R$ 197,00, definido nesta tarefa por ausência no PRD/Tech Spec) e o link provisório do Instagram como "página de vendas" até a Tarefa 10.0 existir. Ambas aparecem na seção "Pendente / decisão do usuário" do arquivo de segredos e a primeira também é repetida na subtarefa 1.3 do `1_task.md` — redundância que aumenta a chance de a pendência não ser esquecida.
- **`.gitignore` correto e minimamente invasivo**: a entrada `.secrets/` foi adicionada com um comentário explicativo, sem tocar em nenhuma outra regra existente. Confirmado via `git check-ignore -v` que o arquivo de segredos está de fato ignorado pelo Git.
- **Separação clara entre segredo e histórico de tarefa**: o token do webhook e a URL completa (com token) ficam apenas no arquivo não versionado; `1_task.md`, que é versionado, referencia a existência do token sem expô-lo.

## Conformidade com Padrões

| Padrão | Status |
|--------|--------|
| Cobertura dos requisitos funcionais (RF-5 a RF-8) | OK |
| Pontos de Integração do Tech Spec (IDs de produto, token, URL do endpoint) | OK (2 observações minor) |
| Dependências Técnicas do Tech Spec | OK |
| Segurança de segredos (`.gitignore`, não versionamento) | OK |
| Honestidade no registro de subtarefas e testes | OK |
| Atualização de `tasks.md` | OK |
| Registro de riscos/decisões pendentes | OK |

## Recomendações

1. (Minor) Adicionar ao `.secrets/kiwify-comercializacao-controlai.md` as linhas explícitas `kiwify.product.annual-id = ...` e `kiwify.product.lifetime-id = ...`, no formato de propriedade Spring, para reduzir trabalho de interpretação na Tarefa 4.0.
2. (Minor) Confirmar e documentar explicitamente que nenhum período de trial adicional foi configurado nos dois produtos, fechando a segunda metade do RF-8.
3. (Sem ação necessária agora, apenas acompanhamento) Manter o item "Retomar teste do Test Webhook ao final da Tarefa 4.0" visível no planejamento da Tarefa 4.0, já que ele depende diretamente da conclusão desta.
4. (Sem ação necessária agora) Ao chegar a Tarefa 10.0, lembrar de: (a) confirmar o valor final do upgrade vitalício (R$ 197,00) com o usuário antes do lançamento; (b) substituir o link provisório do Instagram pela landing page real na configuração da Kiwify.

## Veredito

Tarefa 1.0 **aprovada com observações**. Todas as subtarefas (1.1 a 1.7) atendem aos requisitos RF-5, RF-6, RF-7 e RF-8 do PRD e às exigências de "Pontos de Integração"/"Dependências Técnicas" do Tech Spec. O arquivo de segredos documenta corretamente IDs de produto, token de webhook e URL do endpoint, ainda que sem nomear explicitamente as chaves de propriedade Spring que serão usadas na Tarefa 4.0 (observação minor). Os "Testes da Tarefa" foram tratados com honestidade — um validado de fato, o outro corretamente deixado como bloqueado em vez de falsamente marcado como concluído. `tasks.md` foi atualizado marcando a Tarefa 1.0 como concluída. As duas pendências fora do escopo do PRD/Tech Spec (preço do vitalício e link provisório de vendas) estão claramente registradas como decisões a confirmar antes do lançamento.

Nenhum bloqueio impede o avanço para a Tarefa 2.0. As duas observações minor (nomear as propriedades de config e confirmar ausência de trial) podem ser resolvidas com uma pequena edição do arquivo de segredos, a qualquer momento antes da Tarefa 4.0, sem necessidade de retrabalho na Kiwify.
