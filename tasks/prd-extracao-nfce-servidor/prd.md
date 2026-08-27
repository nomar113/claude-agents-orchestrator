# PRD: Extração Server-Side de Dados de NFC-e (RJ)

## Visao Geral

Hoje, quando o usuário escaneia o QR Code de uma NFC-e (Nota Fiscal de Consumidor Eletrônica), o ControlAI abre a URL de consulta da SEFAZ dentro de uma WebView no próprio app e extrai os dados da nota via injeção de JavaScript. Esse fluxo depende de o app conseguir carregar a página da SEFAZ diretamente do celular do usuário.

Esse fluxo passou a falhar de forma consistente para notas emitidas no Rio de Janeiro: a proteção anti-bot da SEFAZ-RJ (F5 BIG-IP/TSPD) está recusando a conexão vinda do contexto isolado da WebView do app, mesmo com o certificado e a rede do usuário funcionando normalmente para navegação comum. O resultado é que o usuário tenta escanear a nota e recebe um erro genérico de timeout, sem conseguir concluir o registro da compra.

Esta funcionalidade move a extração dos dados da nota para o backend do ControlAI, que processa a consulta à SEFAZ a partir da infraestrutura própria em vez do celular do usuário, resolvendo o desafio anti-bot do lado servidor e devolvendo ao app apenas os dados já extraídos.

## Objetivos

- Aumentar a taxa de notas RJ lidas com sucesso no primeiro scan, hoje reduzida pelo bloqueio da SEFAZ ao contexto de WebView do app.
- Eliminar a dependência do celular do usuário conseguir, sozinho, vencer a proteção anti-bot da SEFAZ para concluir a leitura de uma nota.
- Métrica principal: % de scans de NFC-e que resultam em nota registrada com sucesso (sem erro/timeout), medida antes e depois da mudança.

## Historias de Usuario

- Como usuário do ControlAI, eu quero escanear o QR Code de uma nota fiscal do RJ e ver os dados da compra preenchidos automaticamente, para não precisar digitar os itens manualmente.
- Como usuário do ControlAI, eu quero que a leitura da nota funcione de forma consistente, independentemente da operadora/rede que estou usando no momento do scan.
- Como usuário do ControlAI, se a leitura da nota falhar por instabilidade da SEFAZ, eu quero receber uma mensagem de erro clara, do mesmo jeito que acontece hoje, para saber que posso tentar novamente depois.

## Funcionalidades Principais

### 1. Processamento da nota no backend

O app envia ao backend a URL escaneada da nota (contendo a chave de acesso). O backend é responsável por consultar a SEFAZ, aguardar o carregamento da nota e extrair os dados necessários para o registro da compra — reproduzindo, do lado servidor, a mesma lógica de detecção de prontidão e de bloqueio que hoje existe no app (nota carregada, nota bloqueada/erro da SEFAZ, ou tempo esgotado).

Requisitos funcionais:
1. O backend deve aceitar a URL da nota escaneada pelo usuário como entrada.
2. O backend deve aguardar o carregamento completo da nota antes de tentar extrair os dados, incluindo o tempo necessário para a SEFAZ concluir sua verificação de segurança.
3. O backend deve identificar quando a SEFAZ retornou uma página de bloqueio/erro (nota inexistente, fora do padrão NFC-e, indisponibilidade) e diferenciar esse caso de uma falha de processamento.
4. O backend deve aplicar um tempo máximo de espera pela nota, análogo ao limite já usado hoje no app, encerrando a tentativa com erro caso o tempo se esgote.
5. O backend deve devolver ao app os mesmos dados de compra que o fluxo atual extrai da nota (os campos hoje retornados por `extractDataFromRJ`).

### 2. Integração do app com o processamento no backend

O app substitui o fluxo atual de WebView por uma chamada síncrona ao backend, mantendo a experiência de fila e status de leitura que já existe para múltiplos scans em sequência.

Requisitos funcionais:
6. O app deve enviar a URL escaneada ao backend e aguardar a resposta antes de considerar a leitura concluída.
7. O app deve manter o comportamento atual de fila: notas escaneadas em sequência são processadas uma de cada vez, com um toast de status por nota.
8. O app deve remover a lógica de WebView/InAppBrowser e injeção de JavaScript client-side usada hoje para ler a nota, já que essa responsabilidade passa a ser do backend.
9. Ao receber os dados extraídos do backend, o app deve seguir o mesmo caminho de hoje para salvar a compra (`/purchases/invoice`).

### 3. Tratamento de erros

Requisitos funcionais:
10. Em caso de falha (nota bloqueada pela SEFAZ, tempo esgotado, ou erro de processamento no backend), o usuário deve ver a mesma experiência de erro que existe hoje no app (toast de erro, com opção de descartar).
11. As mensagens de erro apresentadas ao usuário devem continuar distinguindo, quando possível, entre "SEFAZ bloqueou/recusou a consulta" e "não foi possível concluir a consulta" (timeout genérico), preservando o nível de clareza que o fluxo atual já oferece.

## Experiencia do Usuario

- O usuário não percebe nenhuma mudança de interface: a leitura da nota continua sendo iniciada pelo mesmo fluxo de escaneamento de QR Code já existente no app.
- Durante o processamento, o usuário continua vendo o toast de "carregando" já existente, agora representando o tempo de processamento no backend em vez do carregamento da WebView local.
- Em caso de sucesso, o comportamento é idêntico ao atual: toast de sucesso, recarregamento da lista de compras, e desaparecimento automático do toast.
- Em caso de erro, o comportamento é idêntico ao atual: toast de erro com a mensagem correspondente, que o usuário pode descartar manualmente.
- Essa mudança se aplica igualmente a iOS e Android, já que o fluxo de leitura de nota é compartilhado entre as duas plataformas.
- Não há requisitos novos de acessibilidade além dos já aplicados aos toasts existentes.

## Restricoes Tecnicas de Alto Nivel

- O backend precisa ser capaz de concluir, do lado servidor, a verificação de segurança que a SEFAZ-RJ aplica antes de servir o conteúdo da nota — hoje resolvida implicitamente por o conteúdo rodar dentro de uma WebView real no app.
- O tempo de resposta do backend ao app deve ficar dentro de uma janela aceitável para uma chamada síncrona (mesma ordem de grandeza do timeout já usado hoje no fluxo client-side).
- Esta funcionalidade cobre exclusivamente a consulta de NFC-e (modelo 65) emitida pela SEFAZ do Rio de Janeiro.
- Não há requisito de conformidade/regulatório novo além dos já aplicáveis ao tratamento de dados de compras do usuário.

## Fora de Escopo

- Extração de notas emitidas por SEFAZ de outros estados além do RJ.
- Suporte a outros tipos de documento fiscal (NF-e modelo 55, cupom não-fiscal, etc.).
- Infraestrutura de rotação de proxies/múltiplos IPs para o caso de o backend também vir a ser bloqueado no futuro.
- Dashboard ou alertas dedicados de observabilidade sobre a taxa de sucesso da extração.
- Manutenção do fluxo client-side (WebView) como alternativa/fallback — o fluxo atual é substituído, não mantido em paralelo.
