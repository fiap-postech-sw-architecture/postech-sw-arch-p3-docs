# Fichamento: API-Gateway (fase 3)

Fonte: transcricoes em `~/git/local/postech-bootstrap/lessons/phase3/API-Gateway/` (6 aulas; aulas 01-03 de Milton Camara, aulas 04-06 de Douglas Lima da Silva Martins).

## Resumo por aula

### API-Gateway - Aula 01.txt (Introducao ao API Gateway)
- Conceito: API Gateway (API GW / GW) e um componente intermediario que atua como ponto de entrada unico para todas as chamadas de API, um "guardiao" que direciona requisicoes aos servicos subjacentes e coordena as respostas (secao Saiba Mais).
- Motivadores listados: consolidacao/simplificacao, seguranca centralizada (politicas, autenticacao, autorizacao), monitoramento e analise, transformacao de dados e cache (secao Saiba Mais, lista de motivadores).
- Hands On: implementacao de um gateway simples em .NET Core 7 — dois projetos Web API (`MyAPIs` com dois endpoints ficticios e `APIGateway` com `GatewayController` usando `HttpClient` para repassar chamadas), testado com Postman em `localhost:5001/gateway/api1|api2`.
- O material explicita que a implementacao do hands-on e basica e que, em cenarios reais, o gateway incluiria "autenticacao, limitacao de requests e balanceamento de carga, entre muitas outras" (Conclusao do Hands On).
- Caso real: pico de acesso no debate presidencial de 2022 em uma emissora resolvido reapontando o GW para uma estrutura Kubernetes com APIs replicadas "em muitos PODs, o que so foi possivel por tudo estar centralizado no nosso GW" (secao Saiba Mais).
- Palavras-chave da aula: "API GW. Gateway. Proxy."

### API-Gateway - Aula 02.txt (API Management do Azure)
- Apresenta o Azure API Management (APIM), servico em nuvem da Microsoft para "criacao, o gerenciamento e a exposicao de APIs", atuando como gateway central da organizacao (secao Saiba Mais).
- Recursos destacados: Portal do Desenvolvedor, gateways distribuidos, politicas e transformacoes (seguranca, autenticacao, autorizacao, limitacao de taxa), versionamento, analytics/monitoramento, cache, suporte a OpenAPI/Swagger e integracao com Azure Functions, Logic Apps, Event Grid e Azure Active Directory.
- Hands On 100% no portal Azure (portal.azure.com): criar recurso APIM (tier "Development" para testes), publicar uma "API de exemplo", testar com GET no proprio painel e explorar o Portal do Desenvolvedor; recomenda deletar o recurso ao final para evitar custos.
- Beneficios enumerados: centralizacao e padronizacao, gateway de entrada, seguranca centralizada, transformacao de dados e analytics/insights.
- Exemplo de cenario: app mobile integrando APIs de pagamento de varios fornecedores; o APIM unifica autenticacao, transformacao de dados e seguranca (figuras 1 e 2).
- Revela que o APIM foi a ferramenta usada no caso da emissora da aula 01 ("ele foi utilizado no exemplo da aula anterior, no caso da emissora").

### API-Gateway - Aula 03.txt (API Management na pratica)
- Aula pratica de APIM: criar o servico no portal Azure, adicionar "API em branco" apontando para uma Web Service URL, e configurar politica de seguranca "Chave de assinatura" para exigir chave de API (Hands On, Configurar Politicas de Seguranca).
- Politicas de API: "conjuntos de regras e acoes" aplicadas entre requisicao e resposta; em seguranca, permitem exigir "chaves de API validas, tokens de acesso ou implementar a autenticacao OAuth" (secao Saiba Mais).
- Politicas de entrada no APIM: exemplo de adicionar politica "Verificar chave de consulta ou cabecalho" (Hands On, Configurando Politicas de API).
- Monitoramento com metricas vitais: trafego da API, tempo de resposta, taxas de erro, latencia e taxas de uso por recurso; configuracao de alertas no painel (secoes Hands On e Saiba Mais).
- Cache no APIM como camada de performance: melhoria de desempenho, reducao de latencia, economia de recursos de backend e escalabilidade (secao Saiba Mais, "Por que cache?").
- Portal do Desenvolvedor como componente para especialistas em desenvolvimento descobrirem, testarem e consumirem APIs.

### API-Gateway - Aula 04.txt (Conhecendo o Kong)
- Apresenta o Kong API Gateway como "ferramenta Open Source que serve como Proxy para APIs, com diversas configuracoes de autenticacao, logs e consumers" (O que vem por ai?).
- Kong Manager: era pago; a partir da versao 3.4 passou a ter versao free basica, "sem autenticacao para acessar os servicos, rotas e consumers criados" (secao Saiba Mais).
- GUIs open source da comunidade: Konga (server side, com tela de login, salva configuracao em banco) e King (client side, sem login, configuracao local); ambas se conectam ao node do Kong Admin.
- O Konga foi subido "por meio do Docker Compose" na videoaula (secao Saiba Mais); o node Admin do Kong expoe a porta 8001 (localhost ou `host.docker.internal`).
- Conexao do Konga ao node Admin pode ser feita so pela URL ou "por meio de Key, JWT ou Basic auth", usando informacoes de um Consumer especifico (secao Saiba Mais).
- Funcionalidades exclusivas do Konga: Users (usuarios e admins), Snapshots (servicos, rotas, APIs, plugins, consumers, upstreams e targets) e Settings (controle de cadastro, permissoes granulares CRUD, notificacoes por e-mail e Slack).

### API-Gateway - Aula 05.txt (Criando Servicos e Rotas)
- Foca em colocar no ar o King for Kong e analisar o "mapa de arquitetura" que a aplicacao gera baseado em Consumers (O que vem por ai? / Hands On).
- Fluxo Docker: clonar o repositorio do King, criar um Dockerfile, `docker build -t king .` e `docker run --publish 4200:80 -d king`; conectar informando a URL do node Admin (`http://host.docker.internal:8001`).
- "Todo Consumer e o ponto de partida no desenho de arquitetura do Kong"; o mapa e util para identificar dependencias e ligacoes entre APIs cadastradas (secao Saiba Mais).
- Limitacao do King: por ser client side e sem tela de login, "a administracao se torna dificil (...) ele acaba nao sendo tao indicado"; o Konga "acaba sendo superior por entregar mais funcionalidades e permitir o controle de acesso" (secao Saiba Mais).
- Menciona que anteriormente foram criados servicos e rotas no Kong via Kong Manager, e que o docker compose apresentado "contempla o Kong e o banco" (secao Saiba Mais).

### API-Gateway - Aula 06.txt (Consumers)
- Hands On central: "criar um consumer e utiliza-lo para proteger nossas APIs com plugins de autenticacao basica e empregando API Key" (secao Hands On).
- Konnect Dev Portal: site personalizavel para desenvolvedores localizarem, testarem e consumirem APIs, gerenciando as proprias credenciais (secao Saiba Mais).
- Kong Konnect: plataforma de gerenciamento do ciclo de vida de API como servico — plano de controle hospedado na nuvem pelo Kong, plano de dados gerenciado pelo usuario no proprio ambiente (secao Saiba Mais).
- Gateway Manager (modulo do Konnect): cataloga, conecta e monitora planos de controle e nos do plano de dados em um so lugar; Mesh Manager: gestao de malhas Kong Mesh com plano de controle global (secao Saiba Mais).
- Enterprise vs Open Source: Enterprise adiciona GraphQL (conversao de queries GraphQL para REST, conversao JQ, rate limit sobre queries) e autenticacao LDAP e RBAC; "a versao Open Source atende muito bem a maioria dos cenarios" (secao Saiba Mais).

## Ferramentas e tecnicas enfatizadas

Tratadas como centrais/obrigatorias nos hands-on (o material nao usa a palavra "obrigatorio", mas sao o nucleo pratico das aulas):

- Kong API Gateway open source como proxy de APIs, com servicos, rotas, consumers e plugins (aulas 04-06).
- Docker Compose para subir Kong + banco + Konga localmente (aulas 04 e 05).
- Consumers + plugins de autenticacao basic auth e API Key para proteger APIs no Kong (aula 06, Hands On).
- Azure API Management (APIM): criacao de recurso, publicacao de API, politica de chave de assinatura, monitoramento/alertas, cache e Portal do Desenvolvedor (aulas 02 e 03).
- Postman (ou similar) para testar as APIs atras do gateway (aula 01, pre-requisitos do Hands On).
- Padrao API Gateway em si: ponto unico de entrada, seguranca centralizada, monitoramento, transformacao de dados, cache e rate limit (aula 01).

Tratadas como opcionais/complementares:

- .NET Core 7 para o gateway artesanal da aula 01 (o proprio material o chama de "implementacao basica para fornecer uma compreensao do papel do API Gateway").
- Konga como GUI do Kong — recomendada entre as GUIs, mas alternativa ao Kong Manager free 3.4+ (aula 04).
- King for Kong — apresentado e explicitamente desaconselhado para administracao ("nao sendo tao indicado", aula 05); util so pelo mapa de arquitetura por Consumers.
- Kong Konnect, Dev Portal, Gateway Manager e Mesh Manager — servicos gerenciados/adicionais (aula 06).
- Kong Gateway Enterprise (GraphQL, LDAP, RBAC) — upgrade apenas quando a versao Open Source nao atende (aula 06).
- OpenAPI/Swagger para importar APIs existentes no APIM (aulas 02 e 03).

## Implicacoes para o PytStop

- O material aponta duas rotas viaveis: APIM (nuvem Azure, aulas 02-03) e Kong open source via Docker Compose (aulas 04-06). Para a stack do PytStop (Docker multi-stage, docker-compose, Kubernetes kind local, Terraform), o Kong e a rota que roda inteiramente local — as aulas 04 e 05 sobem Kong, banco, Konga e King com docker compose/docker run, o que encaixa direto no docker-compose existente e num overlay kustomize para o kind.
- O padrao de protecao ensinado (Consumer + plugin de API Key / basic auth, aula 06) mapeia naturalmente para o contexto `autenticacao` do PytStop: o gateway faz a barreira de entrada (chave/credencial) enquanto a logica de identidade permanece no servico FastAPI. A aula 03 reforca o mesmo padrao no APIM ("Chave de assinatura", "Verificar chave de consulta ou cabecalho").
- Roteamento por servicos e rotas do Kong (aulas 04-05) permite expor os contextos DDD (cliente_veiculo, catalogo_servicos, estoque, ordem_servico) como rotas distintas atras de um unico ponto de entrada, o beneficio de "consolidacao e simplificacao" da aula 01 — mesmo com um monolito modular, as rotas por contexto ficam padronizadas.
- Monitoramento e metricas do gateway (trafego, tempo de resposta, taxas de erro, latencia — aula 03) complementam a observabilidade ja planejada com OpenTelemetry+Jaeger+Prometheus; o gateway vira mais um ponto de coleta na borda.
- Cache e rate limit no gateway (aulas 01 e 03) sao alavancas de performance que o material enfatiza como responsabilidade do GW, nao da aplicacao — no PytStop isso tira carga do FastAPI/PostgreSQL sem codigo novo nos contextos.
- O caso da emissora (aula 01) — reapontar o GW para pods replicados no Kubernetes — e exatamente o argumento para colocar o gateway na frente dos Deployments no kind: escalar replicas sem tocar nos clientes.
- Nada no material usa Python/FastAPI ou AWS; os exemplos sao .NET Core 7 (aula 01) e portais Azure/Kong. A transposicao para a stack do PytStop e conceitual (padrao, politicas, consumers), nao de codigo.

## Sinais de avaliacao

O material nao cita explicitamente o tech challenge, mas os sinais do que tende a ser cobrado sao:

- Saber justificar o uso de API Gateway com os motivadores da aula 01: ponto unico de entrada, seguranca centralizada, monitoramento, transformacao de dados, cache (e rate limit/balanceamento citados na conclusao do Hands On da aula 01).
- Demonstrar um gateway funcionando na frente das APIs — todos os hands-on terminam com uma chamada real passando pelo gateway (Postman na aula 01, botao Testar no APIM nas aulas 02-03, rotas do Kong nas aulas 04-05).
- Proteger APIs no gateway com autenticacao: chave de assinatura/verificacao de chave no APIM (aula 03) e consumer + plugins basic auth/API Key no Kong (aula 06). E o tema com mais repeticao ao longo do modulo.
- Conhecer servicos, rotas e consumers do Kong e o papel do Consumer como "ponto de partida no desenho de arquitetura" (aulas 04-06).
- Saber posicionar monitoramento (metricas de trafego, tempo de resposta, erros, latencia) e cache como responsabilidades do gateway (aula 03).
- Entender o trade-off entre solucao gerenciada (APIM, Konnect) e open source auto-hospedada (Kong OSS), incluindo os limites da versao free/Open Source vs Enterprise (aulas 02, 04 e 06).

## Perguntas obrigatorias (respostas com citacao de aula/trecho)

### (a) O material foca AWS API Gateway ou gateways auto-hospedados (Kong/Traefik/outros)?

Nao ha uma unica mencao a AWS em nenhuma das seis aulas. O foco e dividido entre o Azure API Management — "o Azure API Management (APIM) e um servico em nuvem oferecido pela Microsoft Azure que permite a criacao, o gerenciamento e a exposicao de APIs" (Aula 02, secao Saiba Mais) — e o Kong auto-hospedado: "voce aprendera sobre o Kong Api Gateway, uma ferramenta Open Source que serve como Proxy para APIs" (Aula 04, O que vem por ai?). Traefik e outros gateways nao aparecem; a aula 01 usa um gateway artesanal em .NET Core 7 apenas para fins didaticos.

### (b) Como o material trata autenticacao no gateway (authorizers, lambda authorizer, JWT)?

Nao existem "authorizers" nem "lambda authorizer" no material (termos do ecossistema AWS, ausente do modulo). A autenticacao aparece de tres formas:

- Politicas no APIM: "selecione 'Chave de assinatura' para exigir uma chave de API para acessar esta API" e politica "Verificar chave de consulta ou cabecalho" (Aula 03, Hands On); as politicas permitem "exigir que os individuos (...) fornecam chaves de API validas, tokens de acesso ou implementar a autenticacao OAuth" (Aula 03, Saiba Mais).
- Consumers + plugins no Kong: "Vamos criar um consumer e utiliza-lo para proteger nossas APIs com plugins de autenticacao basica e empregando API Key" (Aula 06, Hands On).
- JWT aparece pontualmente como opcao de conexao do Konga ao node Admin do Kong: "e possivel realizar a conexao por meio da URL e porta do node Admin somente ou por meio de Key, JWT ou Basic auth" (Aula 04, Saiba Mais). Na versao Enterprise do Kong ha ainda "outros meios de autenticacao, como LDAP e RBAC" (Aula 06, Saiba Mais).

### (c) O material mostra alguma forma de executar/emular o gateway localmente?

Sim, para o Kong: toda a trilha das aulas 04-06 roda local via Docker. "Na videoaula, subimos o Konga por meio do Docker Compose" com o node Admin do Kong na porta 8001, acessivel por "localhost ou pelo endpoint interno do docker, neste caso host.docker.internal" (Aula 04, Saiba Mais); a aula 05 builda e roda o King com "docker build -t king ." e "docker run --publish 4200:80 -d king", e afirma que "o arquivo escrito contempla o Kong e o banco" no docker compose (Aula 05, Saiba Mais). A aula 01 tambem executa o gateway didatico localmente ("dotnet run --urls http://localhost:5001", Hands On). Ja o Azure APIM nao tem emulacao local no material — os hands-on das aulas 02 e 03 sao inteiramente no portal.azure.com, com recomendacao de deletar o recurso ao final "para evitar custos" (Aula 02, Hands On).
