# Fichamento: Monitoramento (fase 3)

Fonte: transcricoes em `~/git/local/postech-bootstrap/lessons/phase3/Monitoramento/` (3 arquivos .txt, apostilas das aulas 01-03). As apostilas sao hands-on; as figuras (YMLs completos) nao estao no texto extraido, apenas descritas.

## Resumo por aula

### Monitoramento - Aula 01.txt (Introducao ao Zabbix)

- Introduz o Zabbix como aliado Open Source: "com ele, conseguimos monitorar praticamente tudo com pouca configuracao e o Agent instalado, o que nao afeta a aplicacao em si".
- Hands-on: subir Zabbix Server + banco MySQL via Docker Compose ("criar um Zabbix Server com Banco MySQL a partir do Docker Compose utilizando o arquivo YML").
- Estrutura do compose: rede com driver bridge; servico MySQL primeiro; Zabbix Server com `depends_on` apontando para o banco; front-end (PHP + Apache) com portas HTTP/HTTPS mapeadas e tambem `depends_on` do banco.
- Boa pratica citada: "devemos usar sempre variaveis para apontar dados sensiveis e utilizar um arquivo .env para expor os valores".
- Pre-requisito: Docker + plugin Docker Compose (com passo a passo via WSL para Windows); acesso final em `http://localhost`, login Admin/zabbix.
- Justificativa do monitoramento: desenvolvimento "sem utilizar mais recursos do que se deve, sem estragar a performance e tendo insumos para aplicar melhorias na infraestrutura".

### Monitoramento - Aula 02.txt (Monitoramento com Zabbix)

- Hands-on: monitorar um banco de dados via ODBC pelo Zabbix ("instalaremos uma extensao ODBC para monitorar um banco de dados por meio do Zabbix e realizar a conexao, alem de monitorar via hosts").
- Setup: instalar `unixodbc` no Linux, configurar `/etc/odbcinst.ini` (driver/conector MySQL) e `/etc/odbc.ini` (endpoint, porta, usuario, senha, alias `[db-zabbix]`); testar com `isql -v db-zabbix`.
- No Zabbix: criar Host em Data Collection com o template ODBC correto para MySQL ("e importante selecionar o template correto, pois ele sera usado para executar querys que tragam informacoes sobre o banco"); sem interface/IP — "como a conexao sera via ODBC, nao precisamos de um Agent".
- Macros do host: DSN, User e Password apontam para a configuracao do odbc.ini.
- Principio de menor privilegio na pratica: dados nao coletados "por falta de permissao" levam a criar usuario dedicado `zbx_monitor` com grants restritos (`REPLICATION CLIENT, PROCESS, SHOW DATABASES, SHOW VIEW`), atualizando odbc.ini e as macros.
- Validacao em Monitoring > Latest Data, onde as metricas do banco aparecem.

### Monitoramento - Aula 03.txt (Prometheus e Grafana)

- Contexto: "ja aprendemos sobre Zabbix, Grafana e Prometheus, mas nao vimos uma secao de logs em nenhuma das tres ferramentas" — a aula introduz o Grafana Loki, "um projeto inspirado no Prometheus mas com foco em logs, diferentemente do Prometheus que coleta metricas de uma aplicacao".
- Hands-on: instalar Loki + Promtail no Ubuntu (`apt-get install loki promtail -y`); "o Loki precisa estar no mesmo servidor do Grafana, uma vez que ele e uma extensao da ferramenta; assim como o Grafana, o Loki e Open Source".
- Configuracao: `/etc/loki/loki.yml` (servico na porta 3100) e `/etc/promtail/config.yml` (positions como "mapa" dos .log, URL do Loki em clients, bloco scrape com labels e path dos logs do Linux).
- Labels sao o mecanismo de segmentacao: "os labels serao responsaveis por isolar um conjunto de log do outro para ser usado no Grafana" (ex.: `job: varlogs`).
- No Grafana: adicionar Loki como Data Source (`http://localhost:3100`), criar dashboard e consultar por Label Filters (Run Query).
- Fechamento da stack: "juntamente com as ferramentas Zabbix e Prometheus, os logs monitoram a infraestrutura e a aplicacao, e completam toda uma stack sobre monitoramento".

## Ferramentas e tecnicas enfatizadas

Todas as ferramentas do material sao open source; o material as trata como o caminho ensinado (hands-on obrigatorio das aulas), nao ha alternativas pagas apresentadas.

- **Zabbix** (Server + front-end PHP/Apache + MySQL) — centro das aulas 01 e 02; tratado como ferramenta principal de monitoramento de infra (Aula 01.txt, Aula 02.txt).
- **Docker + Docker Compose** — meio obrigatorio de provisionar o Zabbix na aula 01 ("e isso que vamos aprender... fazer a instalacao do Zabbix por meio do Docker Compose") (Aula 01.txt).
- **ODBC (unixODBC + conector MySQL)** — tecnica ensinada para monitorar banco de dados sem Agent (Aula 02.txt).
- **Templates e Macros do Zabbix** — mecanica central da coleta na aula 02 (Aula 02.txt).
- **Grafana** — visualizacao/dashboards; ja assumido como conhecido ("ja aprendemos sobre Zabbix, Grafana e Prometheus") (Aula 03.txt).
- **Prometheus** — citado como coletor de metricas ja visto no curso; nao ha hands-on dele nestes .txt (Aula 03.txt).
- **Grafana Loki + Promtail** — hands-on da aula 03 para logs (Aula 03.txt).
- **Praticas transversais**: `.env` para segredos no compose (Aula 01.txt); usuario de monitoramento com privilegios minimos no banco (Aula 02.txt); labels para segmentar logs (Aula 03.txt).
- Opcionais/perifericos: WSL (so para quem usa Windows, Aula 01.txt); VSCode (editor sugerido, Aula 01.txt); `isql` (ferramenta de teste, Aula 02.txt).

Nao aparecem no material: Datadog, New Relic, CloudWatch, Elastic/ELK ou qualquer SaaS de observabilidade.

## Implicacoes para o PytStop

- **Metricas ja cobertas**: o PytStop ja tem OpenTelemetry + Jaeger + Prometheus da fase 2; a aula 03 confirma que Prometheus (metricas) + Grafana (visualizacao) e a dupla esperada pelo curso. O gap em relacao ao material e (1) Grafana como camada de dashboards sobre o Prometheus existente e (2) uma solucao de logs.
- **Logs**: a aula 03 ensina Loki + Promtail. No nosso contexto Kubernetes (kind + kustomize), o equivalente direto e Loki + um coletor de logs dos pods (Promtail ou sucessor) com Grafana como data source — mesma arquitetura da aula (Loki na porta 3100, labels por job) adaptada de VMs Ubuntu para containers. Os labels da aula 03 mapeiam naturalmente para labels por contexto DDD (cliente_veiculo, catalogo_servicos, estoque, ordem_servico, autenticacao) ou por deployment.
- **Zabbix**: as aulas 01-02 dedicam 2/3 do modulo ao Zabbix, entao vale considerar cobertura dele na entrega (ao menos justificar a escolha da stack Prometheus/Grafana, ja que a propria aula 03 apresenta as ferramentas como complementares numa mesma stack). O padrao da aula 01 (compose com rede bridge, depends_on, .env) e trivial de reproduzir no nosso docker-compose se quisermos demonstrar Zabbix.
- **Monitoramento de banco**: a aula 02 monitora MySQL via ODBC; o analogo para nosso PostgreSQL 16 seria o template ODBC de PostgreSQL do Zabbix ou, na stack ja existente, o postgres_exporter do Prometheus — o principio ensinado (usuario dedicado de monitoramento com privilegios minimos, ex. `zbx_monitor`) aplica-se igual ao Postgres.
- **Segredos**: a pratica da aula 01 (variaveis + .env para dados sensiveis no compose) ja e nossa pratica; em Kubernetes traduz-se em Secrets, coerente com o que ja temos no kind/kustomize e Terraform.
- **Esforco**: nada do material exige SaaS nem infra nova paga; tudo roda em Docker/K8s local, compativel com GitHub Actions e o cluster kind da fase 2.

## Sinais de avaliacao

O material destes .txt nao enumera criterios do tech challenge, mas o que ele enfatiza (e portanto o que tende a ser cobrado) e:

- Demonstrar uma **stack completa de monitoramento**: metricas (Prometheus/Zabbix) + visualizacao (Grafana/front-end Zabbix) + logs (Loki) — a aula 03 fecha dizendo que logs "completam toda uma stack sobre monitoramento" (Aula 03.txt).
- **Provisionamento reproduzivel via Docker Compose/containers**, com rede, depends_on e segredos em .env (Aula 01.txt).
- **Monitoramento de banco de dados** com usuario dedicado e permissoes minimas (Aula 02.txt).
- **Dashboards funcionais** com queries por labels no Grafana (Aula 03.txt).
- Enfase em ferramentas **open source** e em nao degradar a aplicacao monitorada ("o Agent instalado... nao afeta a aplicacao em si", Aula 01.txt).

## Perguntas obrigatorias (respostas com citacao de aula/trecho)

### (a) Quais ferramentas o material enfatiza (Datadog, New Relic, Prometheus/Grafana, CloudWatch, outras)?

O material enfatiza **Zabbix** (aulas 01 e 02), **Grafana + Loki + Promtail** (aula 03) e cita **Prometheus** como parte da stack ja vista. Citacoes: "Um forte aliado Open Source e o Zabbix: com ele, conseguimos monitorar praticamente tudo com pouca configuracao" (Aula 01.txt); "Ja aprendemos sobre Zabbix, Grafana e Prometheus... nesta aula, conheceremos o Grafana Loki, um projeto inspirado no Prometheus mas com foco em logs" (Aula 03.txt); "juntamente com as ferramentas Zabbix e Prometheus, os logs monitoram a infraestrutura e a aplicacao, e completam toda uma stack sobre monitoramento" (Aula 03.txt). **Datadog, New Relic e CloudWatch nao aparecem em nenhum dos tres arquivos.**

### (b) O material exige/implica SaaS pago ou aceita stack aberta auto-hospedada?

Todo o material e baseado em **stack aberta auto-hospedada** — nenhum SaaS pago e mencionado. O Zabbix e apresentado como "um forte aliado Open Source" rodando localmente via Docker Compose (Aula 01.txt: "fazer a instalacao do Zabbix por meio do Docker Compose... acessar o Zabbix por meio do seguinte endereco: http://localhost"); o Loki/Grafana idem: "assim como o Grafana, o Loki e Open Source, entao conseguiremos aproveitar a ferramenta ao maximo", instalado no Ubuntu local e acessado em `http://localhost:3100` (Aula 03.txt). Tudo "rodando em um projeto local" (Aula 03.txt, secao O QUE VEM POR AI).

### (c) O que o material diz sobre logs estruturados e correlacao entre requisicoes?

O material **nao trata de logs estruturados (ex. JSON) nem de correlacao entre requisicoes (trace/correlation IDs)** — esses termos nao aparecem em nenhum dos tres arquivos. O que existe de mais proximo e a segmentacao de logs por **labels** no Promtail/Loki: "Os labels serao importantes para executarmos querys no Grafana para pegar logs relacionados a esse job... os labels serao responsaveis por isolar um conjunto de log do outro para ser usado no Grafana" (Aula 03.txt). A coleta e de logs brutos do sistema via tail: o promtail "sera responsavel por ler os logs usando o comando tail do Linux", varrendo "todos os logs do ambiente Linux. Isso envolvera Zabbix, Prometheus e processos do proprio Linux" (Aula 03.txt). Correlacao com requisicoes da aplicacao fica, portanto, fora do escopo destes textos (no PytStop, ja coberta pelo OpenTelemetry da fase 2).
