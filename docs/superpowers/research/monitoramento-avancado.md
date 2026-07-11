# Fichamento: Monitoramento-Avancado (fase 3)

Fonte: 12 arquivos `.txt` (extracao dos PDFs das aulas) em `~/git/local/postech-bootstrap/lessons/phase3/Monitoramento-Avancado/`. A disciplina cobre APM em profundidade usando duas plataformas comerciais como veiculo pratico: Datadog (aulas 02-06) e New Relic (aulas 07-12), com fundamentos de SRE na aula 01 e boas praticas de alertas na aula 10.

## Resumo por aula

### Monitoramento-Avancado - Aula 01.txt (O que e APM e seus beneficios)
- Introduz APM e as Golden Metrics: Response Time, Throughput, Errors e Latencia como tipos de metricas para medir performance de aplicacoes.
- Apresenta Tracing e OpenTelemetry, e o motivo de centralizar logs para junta-los ao tracing e identificar problemas.
- Detalha os termos centrais de SRE: SLI (metricas quantitativas de qualidade — latencia, taxa de erros, disponibilidade), SLO (metas internas mensuraveis baseadas em SLIs) e SLA (contratos formais com penalidades).
- Relacao encadeada: "SLI -> SLO -> SLA" — mede-se com SLIs, definem-se metas internas com SLOs e promessas externas via SLAs.
- Explica Error Budget: quantidade aceitavel de indisponibilidade calculada a partir do SLA/SLO; quando consumido, o time prioriza estabilidade em vez de lancar features.
- Papel do SRE no mundo do APM; referencias em sre.google e Red Hat.

### Monitoramento-Avancado - Aula 02.txt (Introducao APM Datadog)
- Hands on de instrumentacao de APM com o Agent do Datadog em aplicacoes .NET e NodeJS via container, usando a documentacao oficial.
- Explica o padrao sidecar: instrumentacao desacoplada do host da aplicacao, garantindo envio de erros mesmo se o container da aplicacao "morrer"; custo maior, uso comum apenas em producao.
- Sidecar habilita monitoramento de aplicacao (CPU, memoria, latencia de rede), rastreamento distribuido, centralizacao de logs, analise de erros e monitoramento da infraestrutura subjacente.
- Analise de status codes HTTP por request (GET, POST, DELETE, OPTIONS): o Datadog coleta contagem de requisicoes, contagem de erros e latencia com base em 100% do trafego.
- "Ainda e possivel criar dashboards e alertas baseados em status codes para monitorar a saude da aplicacao diferenciando entre tipos de erros, como erros do cliente (4xx) e erros do servidor (5xx)".

### Monitoramento-Avancado - Aula 03.txt (Logs com Datadog)
- Ingestao de logs no Datadog: instrumentar logs das aplicacoes ja instrumentadas com APM e aplicar drop rules, patterns e usabilidade para troubleshooting assertivo.
- Papel dos logs: rastreamento de atividades, diagnostico de erros, seguranca, conformidade regulatoria, investigacao forense, analise de desempenho e geracao de alertas em tempo real para eventos criticos.
- Niveis de severidade de log: Debug, Info, Notice, Warning, Error, Critical, Alert, Emergency — cada nivel determina a urgencia e a acao necessaria.
- Sete tipos de logs: sistema, aplicacao, seguranca, transacao, auditoria, eventos e erros, com exemplos de onde encontrar cada um (syslog, Event Viewer, logs de banco etc.).
- Patterns permitem filtrar e encontrar logs de forma mais agil.

### Monitoramento-Avancado - Aula 04.txt (Infra com Datadog)
- Monitoramento de infraestrutura via Agent do Datadog: correlacionar problemas de CPU, memoria RAM, disco e rede com a performance da aplicacao ("e impossivel ter um problema com CPU, memoria RAM, disco ou rede e isso nao impactar negativamente a aplicacao").
- Host Maps com codigo de cores (cinza = perda de comunicacao, vermelho = problema de CPU, laranja = problema de desempenho, verde = ok) e zoom por host com servicos, integracoes e metricas.
- Menciona alternativas open source: "Ainda que tenhamos ferramentas open source como Grafana, Prometheus e Zabbix, muitas empresas acabam adotando a pratica de All-in-One".
- Caso de uso de otimizacao de custos: agrupar hosts por instance type na AWS e identificar CPU subutilizada para downgrade de instancias (~US$ 13 mil/ano no exemplo).
- Visao de containers em Docker/Kubernetes (AWS ECS, EKS, Azure) com filtros por namespaces, services, pods e configuracoes; analise de imagens inclusive com vulnerabilidades.
- Integracao com clouds para inventario de recursos (bancos, lambdas, rede, seguranca) sem dar acesso direto a cloud aos times.

### Monitoramento-Avancado - Aula 05.txt (Criando Alertas com DD)
- Alerta proativo como pilar da observabilidade: reduz MTTD e MTTR, melhora experiencia do usuario, eficiencia operacional e previne perdas financeiras.
- Anatomia de um monitor Datadog: metodo de deteccao (Threshold, Anomaly, Forecast, Outlier), definicao da metrica/query com tags, condicoes de alerta (limiares Alert/Warning, janela de avaliacao, no data, auto-resolve).
- Notificacoes com variaveis de template ({{host.name}}, {{service.name}}, {{value}}, {{threshold}}) e integracao com e-mail, Slack, PagerDuty, Microsoft Teams e webhooks; renotificacao e agrupamento (multi-alert).
- Tipos de monitores: Metric (CPU, memoria, disco, I/O de rede, taxa de requests/erros), APM (latencia p50-p99, taxa de erro, Error Tracking, SLOs com error budget), Log, Synthetic (API tests no /health, browser tests) e Composite.
- Melhores praticas: alertas acionaveis com runbook vinculado, evitar fadiga de alerta, ajuste fino de thresholds, janelas de avaliacao adequadas, revisao e iteracao continuas, e usar SLOs como guia dos alertas.
- Exemplos citados: "alertar se a latencia p95 do endpoint /api/checkout do servico servico-de-pagamento exceder 300ms por 5 minutos"; "alertar se o endpoint /health da API principal nao retornar um status 200 OK em 3 tentativas consecutivas".

### Monitoramento-Avancado - Aula 06.txt (Criando Dashboards com DD)
- Dashboards transformam metricas, traces e logs em visualizacoes acionaveis; propositos: monitoramento em tempo real, analise de tendencias, troubleshooting, comunicacao entre equipes e acompanhamento de SLOs/KPIs.
- Dois tipos: Timeboards (eixo de tempo global sincronizado; investigacao de incidentes, analise pos-deploy) e Screenboards (layout livre; NOC displays, relatorios para lideranca, visualizacoes de arquitetura).
- Widgets essenciais: Timeseries, Query Value (com formatacao condicional), Top List, Table, Note/Free Text, Image e Geomap.
- Variaveis de template ($service, $env, $host) para dashboards dinamicos, reutilizaveis e consistentes.
- Compartilhamento, permissoes, modo TV/dark para NOC e exportacao/importacao JSON (permite versionamento em Git).
- Boas praticas de design: definir proposito e audiencia, comecar simples e iterar, contar uma historia, clareza visual, performance das queries e revisao periodica.

### Monitoramento-Avancado - Aula 07.txt (Introducao APM Newrelic)
- Introducao a plataforma New Relic e comparacao com o Datadog; instrumentacao de aplicacoes .NET e NodeJS via container.
- Analise de metricas, performance e mapa da comunicacao entre aplicacoes instrumentadas e de terceiros.
- Metrica Apdex: padrao da industria para medir satisfacao do usuario com o tempo de resposta, alternativa "simplificada de SLA" a metricas distorciveis como tempo medio de resposta.
- Calculo do Apdex: (satisfeitos + tolerantes/2) / total; exemplo com T = 0,5s resultando em score 0,9; classificacoes satisfeito (<= T), tolerante (T a 4T) e frustrado (> 4T ou erro de servidor).
- Faixas de interpretacao do score por cor (< 0.5 critico ate 0.85-0.95 ideal); erros 500 sempre contam como frustracao independentemente da velocidade.
- Dissatisfaction percentage: frustracoes + tolerancias/2 por transacao e por aplicacao.

### Monitoramento-Avancado - Aula 08.txt (Logs com Newrelic)
- Logs in context no New Relic: dados de log aparecem no contexto de APM, monitoramento de infraestrutura, distributed tracing e Errors Inbox, acelerando a causa raiz.
- Cobertura de Drop Rules, Patterns e Logs in Context, com instrumentacao de logs em .NET e NodeJS.
- Tres opcoes de configuracao: encaminhamento pelo proprio agent (habilitado por padrao a partir do agente APM 9.8.0), decoracao de logs para encaminhador externo (Fluentd/Fluent Bit) e envio manual de metadados (nao mais incentivado); atencao a cobranca dupla se combinar opcoes.
- A decoracao adiciona atributos de vinculo: span.id, trace.id, hostname, entity.guid e entity.name.
- Limitacoes em Kubernetes: o log e decorado via instrumentacao, nao pela API do Kubernetes; metadados de entidade podem exigir manter Fluentd/Fluent Bit.
- Caso de uso guiado: alerta de latencia -> Log Summary -> Log Patterns (erros raros virando frequentes) -> Log Details -> Errors Inbox com stack trace -> rollback e atualizacao de runbooks.

### Monitoramento-Avancado - Aula 09.txt (Infra com Newrelic)
- Boas praticas de monitoramento de infraestrutura: instalar o agent em todo o ambiente (bancos, servidores web, todo host que suporte as aplicacoes) para reduzir MTTR; UI orientada por tags.
- Usar atributos personalizados/tags nos hosts e integracao nativa EC2 para importar tags AWS; alertas e visualizacoes dinamicas guiadas por tags escalam para hosts futuros automaticamente.
- Ativar integracoes prontas (AWS CloudWatch, AWS ELB, MySQL, NGINX etc.) com paineis pre-configurados.
- Criar condicoes de alerta a partir do grafico da metrica e baseadas em tags de filtro, nao por host individual.
- Visualizar dados de infraestrutura junto com APM (mapas de integridade) para achar a causa raiz mais rapido.
- Introducao ao NRQL: linguagem de consulta semelhante ao ANSI SQL para graficos, troubleshooting, alertas baseados em NRQL ("nosso tipo de alerta principal e mais poderoso") e consultas via API; manter agents atualizados como pilar de boas praticas.

### Monitoramento-Avancado - Aula 10.txt (Configurando alertas)
- Alertas no Datadog e New Relic baseados em regras de negocio; conceitos: condicao de alerta -> incidente ao violar limite -> politica de alerta -> notificacao via workflows.
- Nomenclatura clara dos alertas (exemplo dado: `AWS-Instancia01-Prod-SP-CPU-Critical`) e tags nas condicoes para filtros em workflows.
- Categorizar alertas com destinos distintos: proativos para Slack, reativos para PagerDuty, informativos para Jira; canais citados incluem email, SMS, WhatsApp, Slack, Jira, Teams e PagerDuty.
- Criar times de primeiro atendimento e montar runbooks (manual de procedimentos: quem faz o que, como, onde, quando).
- Revisao mensal dos alertas para evitar spam e perda de atencao; usar metricas de SRE (SLIs e SLOs) como base dos alertas.
- "Automatize a criacao de alertas usando Terraform": padronizacao, rastreabilidade e garantia de que nada nao documentado seja alterado.

### Monitoramento-Avancado - Aula 11.txt (Criando Dashboards com Newrelic)
- Dashboards no New Relic consolidam APM, Browser (RUM), Mobile, Infraestrutura e Logs em uma unica visualizacao; tudo alimentado por queries NRQL.
- Sintaxe NRQL: SELECT/FROM/WHERE/FACET/LIMIT/SINCE/UNTIL/COMPARE WITH/TIMESERIES, com tipos de dado como Transaction, PageView, SystemSample, Log e Metric.
- Data Explorer para descobrir dados disponiveis e Query Builder para escrever e testar queries antes de adicionar ao dashboard.
- Widgets: line/area/bar charts, billboards com thresholds coloridos, tabelas, pie/donut charts, histogramas, funis (funnels) e medidores (gauges), alem de texto/Markdown.
- Organizacao com paginas (abas) e variaveis de template ({{nomeDaVariavel}}) para dashboards interativos e reutilizaveis; modo Kiosk para NOC e exportacao JSON.
- Boas praticas: dominar NRQL, otimizar queries (FACET com alta cardinalidade torna o dashboard lento), foco e clareza, visualizacao apropriada, iterar com feedback.

### Monitoramento-Avancado - Aula 12.txt (Contexto MAP Newrelic)
- Mapas de servico/topologia (Service Maps, Dependency Maps, Topology Views) para arquiteturas distribuidas/microsservicos: compreensao da arquitetura, deteccao de problemas, analise de impacto (blast radius), identificacao de gargalos e otimizacao.
- Mapas sao construidos dinamicamente a partir da instrumentacao APM e do tracing distribuido: agregacao de milhares de traces infere as relacoes entre servicos.
- Elementos: nos (servicos APM, datastores, servicos externos, apps mobile/browser) e conexoes (HTTP/gRPC, queries a banco, filas), com indicadores de saude por cor baseados em Apdex, taxa de erro ou alertas ativos.
- Metricas nas conexoes: throughput (RPM), latencia media e error rate; navegacao contextual do mapa para APM, traces distribuidos e logs.
- Workloads agrupam entidades por funcionalidade de negocio (ex.: "Processamento de Pagamentos") com mapa de dependencias proprio; Lookout/Navigator dao visao panoramica tipo colmeia para achar hotspots.
- Consideracoes: qualidade da instrumentacao e propagacao de contexto de tracing determinam a completude do mapa; causalidade final ainda exige analise humana.

## Ferramentas e tecnicas enfatizadas

Observacao: o material nao usa a palavra "obrigatorio"; a classificacao abaixo reflete o peso dado pelo material (nucleo trabalhado em hands on e boas praticas vs itens apenas citados).

Tratadas como centrais/nucleo do material (hands on + boas praticas):
- APM com instrumentacao por agent (Datadog Agent, aulas 02-04; New Relic Agent, aulas 07-09) — o eixo de toda a disciplina.
- Golden Metrics: Response Time, Throughput, Errors, Latencia (aula 01).
- Tracing distribuido e OpenTelemetry (aula 01; aula 12 para service maps; aula 08 cita integracao OpenTelemetry para logs in context).
- Logs centralizados com drop rules, patterns, severidade e logs in context (aulas 03 e 08).
- Monitoramento de infraestrutura (CPU, memoria, disco, rede, containers/Kubernetes) correlacionado ao APM (aulas 04 e 09).
- Alertas/monitores proativos: thresholds, anomaly, forecast, outlier, monitores de APM/log/synthetic/composite, runbooks, combate a fadiga de alerta (aulas 05 e 10).
- Dashboards: Timeboards/Screenboards no Datadog e dashboards NRQL no New Relic, com variaveis de template (aulas 06 e 11).
- SRE: SLI, SLO, SLA, Error Budget como base para alertas (aulas 01, 05 e 10).
- NRQL como linguagem de consulta para dashboards e alertas no New Relic (aulas 09 e 11).

Citadas como opcionais/complementares (mencionadas sem hands on dedicado):
- Sidecar para instrumentacao desacoplada — apresentado como opcao com custo maior, tipico so de producao (aula 02).
- Grafana, Prometheus e Zabbix — citadas como alternativas open source ao all-in-one comercial (aula 04).
- Apdex — metrica de satisfacao do usuario, enfatizada no contexto New Relic (aula 07); Dynatrace citado apenas como exemplo de heat map.
- Terraform para automatizar criacao de alertas — recomendado como boa pratica (aula 10).
- Synthetic monitors (API tests e browser tests) — descritos entre os tipos de monitores (aula 05).
- Workloads e Lookout/Navigator do New Relic (aula 12).
- Fluentd/Fluent Bit como encaminhadores de log externos (aula 08).
- Integracoes cloud (AWS CloudWatch, ELB, EC2 tags, MySQL, NGINX) (aulas 04 e 09).

## Implicacoes para o PytStop

- A fase 2 do PytStop ja tem OpenTelemetry + Jaeger + Prometheus, exatamente a base que a aula 01 apresenta (tracing + OpenTelemetry + logs centralizados). O material da fase 3 nao exige plataforma comercial — Datadog e New Relic sao o veiculo didatico; a aula 04 reconhece explicitamente Grafana/Prometheus/Zabbix como alternativa open source. A implicacao pratica e evoluir a stack existente com as tecnicas ensinadas, nao trocar de ferramenta.
- Golden Metrics (aula 01) e monitores de APM (aula 05): expor latencia (p50/p95/p99), throughput e taxa de erros por servico/endpoint FastAPI nas metricas OpenTelemetry/Prometheus ja coletadas, segmentadas por contexto DDD (cliente_veiculo, catalogo_servicos, estoque, ordem_servico, autenticacao) via labels/atributos — equivalente as tags service/env que o material usa em todas as queries.
- Alertas (aulas 05 e 10): traduzir os exemplos do material para Prometheus Alertmanager (ou monitores equivalentes): latencia p95 de endpoint critico (ex.: criacao/aprovacao de ordem de servico), taxa de erro por servico, alerta de /health falhando (o exemplo synthetic da aula 05 mapeia para liveness/readiness probes + blackbox/uptime check no Kubernetes kind). Aplicar as boas praticas: nomenclatura descritiva, runbook no corpo do alerta, thresholds Warning/Critical, janela de avaliacao.
- SLO/SLI/Error Budget (aulas 01 e 10): definir SLIs (disponibilidade e latencia dos endpoints por contexto), SLOs internos e documentar o error budget — o material recomenda usar metricas de SRE como base dos alertas, o que se encaixa como ADR/documento no p3-docs.
- Infra e Kubernetes (aulas 04 e 09): coletar CPU/memoria de pods e nodes do cluster kind (kube-state-metrics/cAdvisor no Prometheus ja cobre o equivalente ao agent de infraestrutura) e correlacionar com as metricas de aplicacao, replicando a correlacao aplicacao x servidor que as duas aulas enfatizam.
- Logs (aulas 03 e 08): padronizar severidade (Debug..Emergency) e logs estruturados com trace_id/span_id (o "logs in context" da aula 08 e exatamente correlacao log-trace, que o OpenTelemetry do PytStop ja propaga); centralizar logs dos containers para permitir busca por patterns.
- Dashboards (aulas 06 e 11): construir dashboards Grafana equivalentes aos Timeboards (investigacao temporal: latencia + erros + CPU no mesmo eixo de tempo) e um painel de visao geral tipo Screenboard/NOC; usar variaveis de template do Grafana (service, namespace) espelhando $service/$env do material; versionar dashboards como JSON no Git, pratica citada na aula 06.
- IaC de observabilidade (aula 10): o material recomenda Terraform para criar alertas de forma rastreavel — o PytStop ja usa Terraform e kustomize, entao regras de alerta e dashboards devem entrar como codigo (ConfigMaps/kustomize ou modulos Terraform), nao criados a mao.
- Service map (aula 12): com um unico backend FastAPI modular, o mapa de servicos e simples; o Jaeger existente ja mostra dependencias (app -> PostgreSQL) a partir dos traces. Vale garantir instrumentacao SQLAlchemy para os spans de banco aparecerem como datastore no fluxo.

## Sinais de avaliacao

O material nao traz enunciado explicito do tech challenge, mas os sinais de cobranca inferidos do que ele enfatiza repetidamente sao:

- Instrumentacao de APM funcionando na aplicacao (todas as aulas de hands on instrumentam aplicacoes via agent/container) — no minimo metricas, traces e logs coletados de forma centralizada (aulas 01-04, 07-09).
- Golden Metrics visiveis: response time, throughput, errors, latencia (aula 01).
- Alertas proativos configurados e acionaveis, com boas praticas (nomenclatura, runbook, thresholds warning/critical, evitar fadiga de alerta) — duas aulas inteiras dedicadas (05 e 10) indicam peso alto.
- Dashboards construidos contando a historia da saude do sistema, com variaveis de template e widgets adequados — tambem duas aulas dedicadas (06 e 11).
- Uso de conceitos SRE: SLI/SLO/SLA/Error Budget definidos e ligados aos alertas (aulas 01, 05 e 10 — a aula 05 recomenda "Use Service Level Objectives (SLOs) como guia" e a aula 10 "Use metricas de SRE para alertas").
- Correlacao aplicacao x infraestrutura (CPU/memoria/containers vs performance) e navegacao ate causa raiz (aulas 04, 08 e 09).
- Monitoramento ativo "sem esperar que o cliente/usuario avise sobre um problema" (aula 10) — sugere que uptime/healthcheck monitorado sera valorizado.
- Automacao/rastreabilidade da configuracao de monitoramento (Terraform, dashboards em JSON versionado) como diferencial (aulas 06 e 10).

## Perguntas obrigatorias (respostas com citacao de aula/trecho)

### (a) Quais ferramentas/praticas avancadas o material cobre (APM, tracing distribuido, alertas, SLO/SLI, dashboards)? Cite.

Todas as cinco frentes sao cobertas:

- APM: e o tema-eixo. Aula 01: "Nesta aula sobre APM e seus beneficios, aprenderemos sobre Golden Metrics ... Response Time, Throughput, Errors e Latencia" (Aula 01.txt). Hands on de APM com Datadog: "implementaremos nosso Agent do Datadog APM na aplicacao .NET e NodeJS, por meio de container" (Aula 02.txt) e com New Relic: "vamos implementar nosso Agent do Newrelic APM em nossa aplicacao .NET e NodeJS atraves de container" (Aula 07.txt).
- Tracing distribuido: "Tambem entenderemos o conceito e o uso de Tracing e OpenTelemetry, abordando o motivo da necessidade de ter os logs centralizados para conseguirmos junta-los com Tracing" (Aula 01.txt); "O Datadog Sidecar pode coletar e enviar informacoes de rastreamento ... permitindo que as equipes visualizem a jornada completa de uma solicitacao" (Aula 02.txt); "O tracing distribuido e a tecnologia fundamental que alimenta muitos desses mapas. Cada trace individual e, em si, um 'mapa' da jornada de uma unica requisicao" (Aula 12.txt).
- Alertas: duas aulas dedicadas. "Dominar a criacao de alertas e essencial ... Vamos explorar os diversos tipos de monitores que o Datadog oferece" com metodos Threshold, Anomaly, Forecast e Outlier (Aula 05.txt); e boas praticas multiplataforma: "criando alertas baseados em regras de negocio ... aprendera sobre as boas praticas para manter os alertas confiaveis e corretos" (Aula 10.txt).
- SLO/SLI: "Os principais termos do SRE sao: SLI. SLO. SLA. Error Budget." e "SLI -> SLO -> SLA: SLIs sao a base para definir SLOs, que por sua vez informam os SLAs" (Aula 01.txt); "Use Service Level Objectives (SLOs) como guia ... Configurar alertas baseados na queima do 'error budget' do seu SLO e uma forma poderosa" (Aula 05.txt); "Use metricas de SRE para alertas" (Aula 10.txt).
- Dashboards: "mergulharemos na criacao de dashboards no Datadog ... distinguir entre Timeboards ... e Screenboards" com widgets Timeseries, Query Value, Top List (Aula 06.txt); e no New Relic via NRQL: "Praticamente tudo que voce visualiza em um dashboard customizado na Newrelic e alimentado por uma query NRQL" (Aula 11.txt).

### (b) O material trata monitoramento de Kubernetes (CPU, memoria, healthchecks, uptime)? Cite.

Sim, embora sem uma aula exclusiva de Kubernetes — aparece dentro do monitoramento de infraestrutura e dos monitores:

- CPU/memoria e containers/Kubernetes: "sabemos que e possivel ter a analise e visualizacao de containers, seja no AWS ECS, EKS ou Azure, independentemente de onde esteja, Docker, Kubernetes, com a lista completa de containers. Ainda e possivel filtrar por Namespaces, services, pods e configuracoes" (Aula 04.txt); Host Maps medem CPU/memoria: "com host maps e possivel analisar essa comunicacao e realizar a medicao de memoria, CPU etc." (Aula 04.txt); monitores de metrica cobrem "Infraestrutura: uso de CPU, memoria, disco, I/O de rede em hosts, containers, VMs" (Aula 05.txt); no New Relic, "O monitoramento de sua infraestrutura vai alem da utilizacao de CPU, memoria e armazenamento" (Aula 09.txt) e o tipo de dado "System Sample: dados de infraestrutura (CPU, memoria e disco)" (Aula 11.txt). A aula 02 tambem ilustra sidecar com K8s ("Figura 1 - Datadog Sidecar with K8s", Aula 02.txt) e a aula 08 discute limitacoes de logs in context em Kubernetes: "Se voce estiver usando Kubernetes, saiba que decoramos o log via instrumentacao e nao aquela do Kubernetes API" (Aula 08.txt).
- Healthchecks/uptime: via Synthetic Monitors — "API Tests: verificam a disponibilidade, tempo de resposta e correcao da resposta de seus endpoints HTTP ... Exemplo de caso de uso: alertar se o endpoint /health da API principal nao retornar um status 200 OK em 3 tentativas consecutivas" (Aula 05.txt); status de saude de containers: "o Datadog Sidecar tambem pode ser usado para monitorar a infraestrutura subjacente. Isso pode incluir coisas como o status de saude dos conteineres" (Aula 02.txt); condicao de "No Data" como sinal de host/app fora: "e possivel configurar o monitor para alertar se a metrica parar de reportar dados" (Aula 05.txt); e o objetivo de uptime aparece como "evitar que o cliente avise que sua aplicacao esteja fora do ar" (Aula 10.txt).

### (c) Que dashboards/alertas o material sugere construir? Cite.

Dashboards sugeridos:
- Timeboard de investigacao de incidentes correlacionando aplicacao e infra: "e crucial ver como diferentes metricas (CPU, memoria, latencia da aplicacao, taxa de erros etc.) se comportaram no mesmo periodo" (Aula 06.txt); exemplo de widget: "um grafico mostrando a utilizacao media de CPU, a latencia p95 de um servico e a taxa de erros desse mesmo servico nos ultimos 60 minutos" (Aula 06.txt).
- Screenboard de status de alto nivel/NOC: "criar paineis para serem exibidos em monitores grandes, mostrando o estado geral dos sistemas criticos com indicadores visuais claros (verde/amarelo/vermelho)" (Aula 06.txt).
- Dashboards por status code: "e possivel criar dashboards e alertas baseados em status codes para monitorar a saude da aplicacao diferenciando entre ... (4xx) e ... (5xx)" (Aula 02.txt).
- Tabela comparativa de microsservicos: "uma tabela mostrando para cada microsservico: taxa de requests, taxa de erro, latencia p50, p90 e p99" (Aula 06.txt); e ranking: "os 5 endpoints de API com a maior latencia p99; os 3 servicos com a maior taxa de erro" (Aula 06.txt).
- Painel unico correlacionando infra + aplicacao no New Relic: "criar um unico painel para correlacionar visualmente a integridade de sua infraestrutura com metricas de aplicativos, navegadores e sinteticas" usando NRQL (Aula 09.txt); com widgets NRQL de latencia, billboards com thresholds, histogramas de duracao e funis de conversao (Aula 11.txt).
- Dashboards dinamicos com variaveis de template ($service, $env, $host no Datadog; {{selectedApp}} no New Relic) (Aulas 06 e 11).

Alertas sugeridos:
- Metrica de infra: "alertar se a utilizacao media da CPU em todos os servidores web do ambiente de producao exceder 80% por mais de 10 minutos" (Aula 05.txt); tambem "uso de disco > 90%, taxa de erro > 5%" como exemplos de threshold (Aula 05.txt).
- APM/latencia e erro: "alertar se a latencia p95 do endpoint /api/checkout do servico servico-de-pagamento exceder 300ms por 5 minutos. Alertar se a taxa de erro do servico servico-de-usuarios for maior que 1% no ultimo periodo de 15 minutos" (Aula 05.txt).
- Logs: "alertar se mais de 10 logs contendo 'Null Pointer Exception' forem registrados pelo servico servico-catalogo no ambiente de producao nos ultimos 5 minutos" (Aula 05.txt).
- Synthetic/uptime: "alertar se o endpoint /health da API principal nao retornar um status 200 OK em 3 tentativas consecutivas de diferentes localizacoes. Alertar se a jornada de login do usuario falhar no teste de browser" (Aula 05.txt).
- Composite para reduzir ruido: "alertar SOMENTE SE (o monitor de CPU alta estiver ativo); (o monitor de alta latencia no servico X estiver ativo)" (Aula 05.txt).
- SLO/error budget: "Service Level Objectives (SLOs): permite definir metas de performance ou disponibilidade (ex: 99.9% de requests com sucesso) e alertar sobre o 'error budget' consumido" (Aula 05.txt).
- Praticas transversais: nomenclatura tipo "AWS-Instancia01-Prod-SP-CPU-Critical", categorias com destinos (proativos -> Slack, reativos -> PagerDuty, informativos -> Jira), runbooks vinculados e automacao com Terraform (Aula 10.txt).
