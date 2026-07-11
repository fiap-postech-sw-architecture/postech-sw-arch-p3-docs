# Fichamento: Serverless (fase 3)

Fonte: `~/git/local/postech-bootstrap/lessons/phase3/Serverless/` (6 aulas, prof. Luiz Zenha, disciplina "Desenvolvimento Serverless"). Todo o material usa AWS como provedor e um cenario ficticio de plataforma de venda de ingressos migrando de on-premises para cloud.

## Resumo por aula

### Serverless - Aula 01.txt
- Define serverless como arquitetura nativa de nuvem que transfere responsabilidades operacionais (provisionamento, SO, disco, capacidade) para o provedor cloud; foco exclusivo em AWS.
- Computacao: AWS Lambda para rotinas/scripts rapidos e APIs menores (paga pelo uso, orientado a eventos, invocavel por 200+ servicos); AWS Fargate (ECS/EKS) para containers com processamento/memoria mais intensos e execucao continua.
- Integracoes: EventBridge (eventos em tempo real, arquitetura hibrida on-premises/cloud), Step Functions (orquestracao de fluxos com editor visual), SQS (filas, resiliencia contra picos), SNS (topicos/notificacoes), AppSync (GraphQL/tempo real).
- API Gateway apresentado como "a grande estrela" da migracao serverless: criar, publicar, monitorar e proteger APIs, com gestao de trafego, CORS, autorizacao e versionamento; integra com Lambdas, containers e instancias.
- Armazenamento: EFS (file system compartilhado) vs S3 (objetos via API/SDK); bancos: DynamoDB (NoSQL), Aurora Serverless (compativel com MySQL/PostgreSQL), Neptune Serverless (grafos), RDS Proxy (gestao de conexoes RDS) e Redshift Serverless (analytics).

### Serverless - Aula 02.txt
- POC de custos: DynamoDB com agenda de eventos + API GET; arquitetura API Gateway -> Lambda -> DynamoDB, pois "por si so a Lambda nao e capaz de expor uma API RESTful, sera preciso uma API Gateway".
- Cobranca do Lambda: por solicitacao + duracao (arredondada a 1ms) x memoria configurada; free tier de 1 milhao de solicitacoes/mes e 400.000 GB-segundos/mes; tabelas de preco distintas para x86 e ARM.
- Licao de design: "Lambdas devem ser simples e o mais otimizados possivel, para que executem rapido, pois refletira no custo final".
- API Gateway: modos HTTP, REST e WebSocket com precos diferentes (REST tem mais recursos — API keys, throttling por cliente, WAF, endpoints privados — HTTP e mais barato); cobranca por chamada, free tier de 1 milhao/mes, cache opcional pago.
- DynamoDB: modos on-demand (uso imprevisivel) vs provisioned capacity (trafego conhecido, previsibilidade financeira); free tier de 25 GB.
- AWS Pricing Calculator (calculator.aws) usada no hands-on para estimar a POC: 3 milhoes de acessos/mes, itens de ate 1kb, ~20 eventos/mes => ~17.98 USD/mes (~215.76 USD/ano) sem considerar free tier.

### Serverless - Aula 03.txt
- Deploy de aplicacao existente em ECS Fargate: adequar app para container, buildar imagem e publicar no ECR; alerta explicito de que ECS Fargate gera custos enquanto executa.
- Conceitos ECS: cluster (EC2 ou Fargate), task definition (portas, env vars, CPU/memoria, logs), task role (permissoes da aplicacao: S3, Secrets Manager) vs task execution role (agente que baixa imagem do ECR e coleta logs).
- Service garante resiliencia (substitui tasks com falha), auto scaling e load balancer entre tasks; tasks tambem servem para cron jobs rapidos.
- Hands-on com API Node.js/Express (app.js que retorna lista de shows) e Dockerfile simples (alpine + npm), buildada com `docker build . -t events:latest`.
- Fluxo ECR via AWS CLI: `aws ecr create-repository`, `aws ecr get-login-password | docker login`, `docker tag` e `docker push` para o registry; validacao pelo console.

### Serverless - Aula 04.txt
- Problema: balancear carga e nao expor a API do ECS por IP direto; solucao: ALB dentro de subnet privada + API Gateway como porta de entrada publica.
- Redes: VPC como escopo regional isolado; sub-redes privadas para banco e microsservicos sem autenticacao propria; Internet Gateway e NAT Gateway como componentes principais; VPC default nao e recomendada para producao.
- Load Balancers: Application Load Balancer (camada de aplicacao, gRPC, roteamento por requisicao, um pouco mais caro) vs Network Load Balancer (TCP/UDP/TLS); target groups com health checks (endpoint que retorna 200/500) para substituicao de tasks doentes.
- API Gateway oferece 3 tipos: HTTP API (leve, barata, ideal para serverless/microsservicos), REST API (recursos avancados, autorizacao, versionamento) e WebSocket API (tempo real); para a validacao do ECS o material usa HTTP API.
- VPC Link conecta o API Gateway a recursos privados (NLB ou VPC), com aviso de taxas adicionais de transferencia; resultado final: endpoint publico HTTPS/SSL na frente do ALB privado.

### Serverless - Aula 05.txt
- Autenticacao da API com Amazon Cognito, sem alterar o servico que ja roda no ECS: user pool gera token JWT que e exigido pelo API Gateway.
- Funcionalidades do Cognito: confirmacao de e-mail/telefone, MFA, atributos customizados, grupos de usuarios, multi-tenant/B2B, fluxos de autenticacao personalizados, login social e federacao SAML/OIDC; SDKs em Java, C++, PHP, Python, Golang, Ruby, .NET e JavaScript (+ Amplify para mobile).
- Teoria OAuth 2.0 com os 3 fluxos: Authorization Code Grant (preferido), Implicit Grant (tokens expostos, usar so em ultimo caso) e Client Credentials Grant (M2M, com client ID e secret).
- User pools (autenticar/autorizar usuarios do app/API, emitem JWTs) vs identity pools (emitem credenciais AWS para acesso a recursos, aceitam IdPs externos, RBAC/ABAC).
- Hands-on: criar user pool, cadastrar usuario, fazer login, obter JWT, configurar o API Gateway para exigir autenticacao e validar o acesso.

### Serverless - Aula 06.txt
- Aprofundamento em Lambda: modelo de funcoes com responsabilidade unica, linguagens suportadas (Node.js, Python, Java, C#, entre outras), precificacao por memoria/CPU, trigger -> funcao -> destination (sucesso ou falha, ex.: mensagem em fila).
- Principais triggers: API Gateway, AWS IoT, S3 (chegada de arquivo), SNS e SQS; casos de uso: processamento de arquivos (S3 -> Lambda -> S3), dados/analytics (DynamoDB Streams -> Lambda), sites (API Gateway -> Lambda como endpoint HTTP) e apps moveis.
- Criacao de Lambda pelo console com 3 opcoes: "Container Image", "Use a blueprint" e "Author from scratch" (exemplo usa Node.js 18.x); teste pela aba Test do console.
- AWS SAM (Serverless Application Model): framework open source com sintaxe YAML do CloudFormation para descrever Lambda, APIs, tabelas DynamoDB etc.; integrado ao AWS CodePipeline para implantacao continua.
- SAM CLI: pre-requisitos AWS CLI configurado + Docker; permite criar projeto de template, testar/depurar localmente emulando o ambiente AWS e fazer deploy (`sam`); hands-on cria Lambda em Java com SAM, roda local, faz deploy e integra ao API Gateway.
- Desvantagem apontada 2x: SAM gera forte acoplamento com a AWS, dificultando portabilidade para outro provedor.

## Ferramentas e tecnicas enfatizadas

Tratadas como obrigatorias (nucleo do curso, usadas nos hands-on):
- AWS Lambda — servico central da disciplina (Aulas 01, 02, 06).
- Amazon API Gateway — frente de toda API, tanto para Lambda quanto para ECS (Aulas 01, 02, 04, 05, 06).
- ECS Fargate + ECR — deploy de containers serverless, com docker build/tag/push (Aulas 03, 04).
- Amazon DynamoDB — banco da POC de custos (Aula 02).
- VPC, subnets privadas, security groups, ALB, target groups e VPC Link — base de rede do hands-on (Aula 04).
- Amazon Cognito (user pools + JWT) — autenticacao da API via API Gateway (Aula 05).
- AWS SAM / SAM CLI — criacao, teste local e deploy de Lambdas (Aula 06).
- AWS CLI configurada com credenciais — pre-requisito dos hands-on (Aulas 03, 06).
- AWS Pricing Calculator — estimativa de custos da POC (Aula 02).

Tratadas como opcionais/contextuais (apresentadas como alternativas ou "quando fizer sentido"):
- EventBridge, Step Functions, SQS, SNS, AppSync — catalogo de integracoes serverless (Aula 01).
- EFS vs S3; Aurora Serverless, Neptune Serverless, RDS Proxy, Redshift Serverless — opcoes de armazenamento/dados (Aula 01).
- Network Load Balancer — alternativa ao ALB (Aula 04).
- Identity pools do Cognito — alternativa aos user pools para credenciais AWS (Aula 05).
- REST API e WebSocket API do API Gateway — o material usa HTTP API no hands-on (Aula 04).
- Cache do API Gateway e provisioned concurrency do Lambda — otimizacoes com custo extra (Aula 02).

## Implicacoes para o PytStop

- Lambda em Python: o material usa Node.js e Java nos exemplos, mas lista Python explicitamente entre as linguagens suportadas (Aula 06). Para o PytStop, funcoes Lambda em Python mantem a stack homogenea; atencao ao runtime disponivel na AWS (o material nao cobre versoes de Python — Python 3.14 provavelmente exigira container image ou runtime custom, ja que runtimes gerenciados costumam atrasar em relacao ao release).
- O criterio de particao do material (Aula 01) mapeia bem para o PytStop: a API FastAPI monolitica modular (contextos cliente_veiculo, catalogo_servicos, estoque, ordem_servico) e caso de "execucao continua" -> ECS Fargate ou o Kubernetes ja existente; o contexto autenticacao e o candidato natural a Lambda + API Gateway + Cognito, exatamente o fluxo da Aula 05 (user pool emite JWT, API Gateway valida).
- API Gateway na frente de tudo: a Aula 04 mostra o padrao API Gateway (HTTP API) -> VPC Link -> ALB -> servico em subnet privada. Se o PytStop mantiver o cluster (kind local / EKS-like na nuvem), esse e o desenho para nao expor a API por IP: gateway publico, workload privado.
- Banco: o material empurra DynamoDB para a POC (Aula 02) e cita Aurora Serverless como opcao SQL compativel com PostgreSQL (Aula 01). Com SQLAlchemy 2.0 imperativo + PostgreSQL 16, Aurora Serverless (ou RDS + RDS Proxy para conexoes de Lambda, Aula 01) preserva o codigo de persistencia; DynamoDB exigiria reescrever os repositories do contexto que migrar. Cuidado classico com Lambda + Postgres: pool de conexoes — o RDS Proxy citado na Aula 01 existe para isso.
- Docker multi-stage e docker-compose seguem uteis: o fluxo ECR da Aula 03 (build/tag/push) e o mesmo que o CI do PytStop ja faz no GitHub Actions; basta adicionar steps de login/push no ECR e, se usar SAM, `sam build`/`sam deploy` no pipeline (a Aula 06 cita integracao do SAM com CodePipeline, mas o conceito transfere para GitHub Actions).
- IaC: o material nao usa Terraform (ver pergunta d) — provisiona via console e AWS CLI, e usa SAM/CloudFormation para Lambda. Para o PytStop, que ja padroniza Terraform, o equivalente e provisionar Lambda, API Gateway, Cognito e VPC via Terraform, mantendo SAM CLI apenas como ferramenta de execucao local se desejado.
- Observabilidade: o material so menciona coleta de logs via task definition/CloudWatch (Aula 03); nada de OpenTelemetry/Jaeger/Prometheus. Instrumentar a Lambda com OpenTelemetry ficaria por conta do time, fora do escopo do material.
- Custos como criterio de arquitetura (Aula 02): documentar uma estimativa na AWS Pricing Calculator para a parte serverless do PytStop e barato e alinha com o que o material valoriza (Lambda enxuta, memoria calibrada, HTTP API em vez de REST API quando bastar).

## Sinais de avaliacao

- A Aula 06 encerra com "nao se esqueca de fazer o desafio", conectando a disciplina diretamente ao tech challenge (Aula 06).
- O percurso completo do curso desenha o entregavel esperado: expor API via API Gateway (Aulas 02/04), proteger com autenticacao Cognito/JWT (Aula 05) e ter funcao Lambda integrada ao API Gateway (Aulas 02/06) — este e o nucleo provavel de cobranca serverless da fase 3.
- Justificativa de escolha Lambda vs Fargate: o material insiste no criterio (rotinas rapidas/APIs pequenas -> Lambda; processamento continuo/intenso -> Fargate) (Aulas 01, 03), sinalizando que a decisao arquitetural fundamentada sera valorizada.
- Consciencia de custos: aula inteira dedicada a precificacao e a AWS Pricing Calculator, incluindo free tier e a regra "Lambda simples e otimizada custa menos" (Aula 02).
- Seguranca de rede: nao expor servicos por IP publico; subnet privada + ALB + VPC Link + API Gateway com HTTPS (Aula 04) e API com autenticacao obrigatoria via Cognito (Aula 05).
- Dominio do fluxo de empacotamento e deploy: imagem Docker -> ECR -> ECS Fargate via AWS CLI (Aula 03) e Lambda via SAM CLI com teste local antes do deploy (Aula 06).

## Perguntas obrigatorias (respostas com citacao de aula/trecho)

### (a) Qual runtime/linguagem e formato de empacotamento de Lambda o material usa (zip, imagem, framework)?

O material usa Node.js 18.x no exemplo de console e Java no exemplo com SAM; o empacotamento demonstrado e via framework AWS SAM (template YAML/CloudFormation), nao zip manual. A Aula 06 mostra a criacao pelo console: "'Author from scratch' comecando de um simples rascunho, damos um nome para Lambda no campo function name e escolhemos a linguagem. No nosso caso, vamos de Node.js 18.x" e tambem lista a opcao "'Container Image' para criarmos a partir de uma imagem de container" (Aula 06). Para o projeto real da aula: "Utilizaremos o aprendizado de Lambda e do SAM para criar outro Lambda, agora com Java" e "criamos nossa primeira funcao Lambda com o AWS SAM CLI e fizemos a implantacao para testa-la juntamente com um API Gateway" (Aula 06). Linguagens suportadas citadas: "Node.js, Python, Java, C#, entre outras" (Aula 06). O material nao mostra upload de zip explicitamente.

### (b) O material cobre execucao/emulacao local (SAM CLI, LocalStack, serverless-offline, RIE)?

Sim — cobre SAM CLI com emulacao local (e exige Docker para isso). Aula 06: "o SAM CLI, que nos auxiliara muito, principalmente na padronizacao necessaria para os projetos lambda, alem de facilitar o teste local"; no hands-on: "Rodaremos localmente, mostrando a vantagem do SAM para depuracao de codigo"; e na teoria: "O AWS SAM CLI permite emular o ambiente da AWS em sua maquina local, o que e util para depurar e testar o aplicativo antes da implantacao". Pre-requisito citado: "Docker, para executar e testar localmente suas aplicacoes" (Aula 06). LocalStack, serverless-offline e RIE nao sao mencionados em nenhuma aula.

### (c) Como o material integra Lambda com API Gateway e com banco de dados?

API Gateway como endpoint HTTP na frente da Lambda, e Lambda consultando DynamoDB. Aula 02 (POC): "Como por si so a Lambda nao e capaz de expor uma API RESTful, sera preciso uma API Gateway, que recepcionara as requisicoes e repassar para o Lambda, que entao fara a consulta no banco de dados" — banco esse definido como "um banco de dados DynamoDB que tera uma base com a agenda de todos os eventos disponiveis e uma API GET" (Aula 02). Aula 06 reforca o padrao: "Voce pode invocar sua funcao do Lambda pelo HTTP usando o Amazon API Gateway como o endpoint HTTP" e, para dados, cita DynamoDB Streams como trigger: "os DynamoDB Streams poderao publicar eventos de atualizacao do item para um fluxo associado a tabela (...) Podemos escrever uma funcao do Lambda para gerar metricas personalizadas" (Aula 06). Nao ha exemplo de Lambda com banco relacional; o RDS Proxy e citado apenas como catalogo na Aula 01 ("gerencia as conexoes com bancos RDS").

### (d) O material menciona provisionamento da Lambda via Terraform ou outra IaC?

Terraform nao e mencionado em nenhuma aula. A unica IaC presente e o AWS SAM, baseado em CloudFormation: "Ele usa a sintaxe YAML do CloudFormation, o que facilita a descricao dos recursos necessarios para a implantacao de um aplicativo serverless" e "O modelo traz todas as instrucoes de CloudFormation dos recursos da AWS necessarios, como funcoes Lambda, APIs, tabelas do DynamoDB e outros recursos" (Aula 06). O restante do provisionamento (ECR, ECS, VPC, ALB, API Gateway, Cognito) e feito via console AWS e AWS CLI (Aulas 03, 04, 05), sem ferramenta de IaC declarativa.
