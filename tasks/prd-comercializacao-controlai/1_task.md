# Tarefa 1.0: Criar produto de assinatura na Kiwify (anual + order bump vitalício)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se voce nao ler esses arquivos sua tarefa sera invalidada</critical>

## Visão Geral

Configuração manual no painel da Kiwify (via navegador, conta já conectada) do produto de assinatura anual do ControlAI (R$ 77/ano) e do order bump de upgrade para o plano vitalício, replicando o modelo do concorrente MultiCap descrito no PRD. Esta tarefa **não é código** — é a criação de um produto real de cobrança recorrente, portanto qualquer etapa que publique/ative o produto para vendas reais deve ser confirmada explicitamente com o usuário antes de ser efetivada.

<skills>
### Conformidade com Skills Padrões

Nenhuma skill de código se aplica — tarefa de configuração de produto em plataforma externa (Kiwify).
</skills>

<requirements>
- RF-5 do PRD: produto de assinatura anual R$ 77/ano cadastrado na Kiwify.
- RF-6 do PRD: order bump de upgrade para plano vitalício do ControlAI no checkout.
- RF-7 do PRD: checkout aceitando cartão, boleto e Pix.
- RF-8 do PRD: política de reembolso de 7 dias corridos, sem trial adicional.
- Dependência técnica registrada na Tech Spec: IDs de produto (anual e vitalício) precisam ser conhecidos para a Tarefa 4.0 (mapeamento de plano no webhook).
</requirements>

## Subtarefas

- [x] 1.1 Confirmar com o usuário nome comercial, descrição e imagens/artes do produto a serem usadas no checkout (reaproveitar branding do ControlAI). — Confirmado: nome "ControlAI - Assinatura Anual" / "ControlAI - Upgrade Vitalício", branding reaproveitado do app icon do controlai-frontend.
- [x] 1.2 Criar o produto principal (assinatura anual, R$ 77/ano) no painel da Kiwify, com métodos de pagamento cartão, boleto e Pix habilitados. — Produto criado (ID em `.secrets/kiwify-comercializacao-controlai.md`), garantia de 7 dias configurada, métodos cartão+boleto+Pix habilitados (padrão da Kiwify).
- [x] 1.3 Criar o produto/oferta de upgrade vitalício (pagamento único) e configurá-lo como order bump do checkout do produto principal. — Produto criado (R$ 197,00, valor definido nesta tarefa por não constar no PRD/Tech Spec — confirmar com usuário antes do lançamento) e adicionado como order bump do checkout do plano anual.
- [x] 1.4 Configurar a política de reembolso/garantia de 7 dias no produto. — Configurado explicitamente no produto de assinatura; o produto de pagamento único não expõe esse campo no painel da Kiwify, mas o direito de arrependimento de 7 dias (CDC art. 49) se aplica por lei independentemente da configuração.
- [x] 1.5 Configurar um webhook na Kiwify apontando para o endpoint que será criado na Tarefa 4.0 (`POST /webhooks/kiwify`), assinando os eventos: `compra_aprovada`, `compra_recusada`, `compra_reembolsada`, `chargeback`, `subscription_canceled`, `subscription_late`, `subscription_renewed`. Guardar o token do webhook com segurança (será usado como variável de ambiente do backend). — Webhook "ControlAI Backend - Billing" criado apontando para `https://api.opencod3.com.br/webhooks/kiwify?token=...`, com os 7 eventos assinados. Token guardado em `.secrets/`.
- [x] 1.6 Registrar em um local seguro (não versionado) os IDs dos dois produtos (anual e vitalício) e o token do webhook, para uso nas Tarefas 4.0 e 10.0. — Registrado em `.secrets/kiwify-comercializacao-controlai.md` (pasta adicionada ao `.gitignore`).
- [x] 1.7 Confirmar explicitamente com o usuário antes de publicar/ativar o produto para vendas reais (checkout indo ao ar). — Usuário informado que a Kiwify não tem gate de "publicar" separado (produto criado já fica "Ativo" e aceita pagamento real); usuário confirmou manter assim, sem divulgar o link, até as Tarefas 4.0/10.0 estarem prontas.

## Detalhes de Implementação

Ver PRD `Funcionalidades Principais > 2. Produto de assinatura na Kiwify` e Tech Spec `Pontos de Integração` (mapeamento de plano por ID de produto) e `Dependências Técnicas`.

## Critérios de Sucesso

- Produto de assinatura anual ativo na Kiwify, com preço, métodos de pagamento e garantia configurados conforme o PRD.
- Order bump vitalício visível e funcional no checkout.
- Webhook configurado no painel da Kiwify apontando para o endpoint do backend, com token gerado.
- IDs de produto e token documentados para as tarefas seguintes.

## Testes da Tarefa

- [x] Checkout de teste (modo sandbox/teste da Kiwify, se disponível) validando que o produto principal e o order bump aparecem corretamente com os valores esperados. — Validado visualmente acessando o link de checkout real (sem finalizar pagamento — Kiwify não tem sandbox); produto e order bump aparecem com os valores corretos (R$ 77,00 e R$ 197,00 em parcela única).
- [ ] Disparo do "Test Webhook" da Kiwify confirmando que o evento chega (mesmo que o endpoint de destino ainda não exista — validar ao menos que a URL é alcançável após a Tarefa 4.0 estar no ar). — Bloqueado por dependência: o endpoint `POST /webhooks/kiwify` só existirá após a Tarefa 4.0. Disparar agora resultaria em erro de conexão esperado. Retomar este teste ao final da Tarefa 4.0.

<critical>SEMPRE CRIE E EXECUTE OS TESTES DA TAREFA ANTES DE CONSIDERA-LA FINALIZADA</critical>

## Arquivos relevantes

- Nenhum arquivo de código — configuração externa na plataforma Kiwify.
- Saída: IDs de produto e token de webhook, a serem usados como variáveis de ambiente nas Tarefas 4.0 e 10.0.
