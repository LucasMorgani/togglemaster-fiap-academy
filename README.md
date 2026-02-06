# Projeto Togglemaster fase 2

### Visão Geral do Projeto

Este projeto foi desenvolvido como parte do **desafio bimestral da PósTech FIAP**.

A solução utiliza uma **aplicação local fornecida pela FIAP**, cujas imagens foram configuradas e versionadas com **Docker**, publicadas em um repositório remoto **Amazon ECR** e posteriormente **deployadas em um cluster Kubernetes**.

Todo o cluster Kubernetes, bem como a infraestrutura associada, foi **provisionado via Terraform**, garantindo uma infraestrutura totalmente **automatizada, documentada, versionada no GitHub e reproduzível**.  
Ainda por meio do Terraform, foram realizadas **provisões iniciais de recursos Kubernetes**, incluindo a criação de alguns **Jobs** necessários para o funcionamento do ambiente.

---

### Arquitetura de Serviços
De forma simplificada, o projeto é composto pelos seguintes serviços:

---

### Auth-Service

Serviço responsável pela autenticação do projeto **ToggleMaster**.  
É responsável pela **criação e validação de chaves de API**, garantindo o controle de acesso entre os serviços.

- **Aplicação:** Go  
- **Banco de dados:** Amazon RDS (PostgreSQL)

---

### Flag-Service

Serviço responsável pelo **CRUD (Create, Read, Update, Delete)** das *feature flags* do projeto **ToggleMaster**.  
Gerencia as definições e configurações das flags disponíveis no sistema.

- **Aplicação:** Python  
- **Banco de dados:** Amazon RDS (PostgreSQL)

---

### Targeting-Service

Serviço responsável pelas **regras de segmentação (targeting)** das *feature flags*.  
Permite a definição de regras mais complexas, como por exemplo:
- "50% dos usuários"
- **Aplicação:** Python  
- **Banco de dados:** Amazon RDS (PostgreSQL)

---

### Evaluation-Service

Serviço de **avaliação das feature flags**, considerado o **hot path** do projeto **ToggleMaster**.  
É o **único endpoint exposto aos clientes finais**, como aplicações mobile ou web, sendo responsável por retornar rapidamente o estado de uma feature flag.

- **Aplicação:** Go  
- **Banco de dados:** Amazon ElastiCache for Redis  
- **Fila:** Amazon SQS (entrada)

---

### Analytics-Service

Serviço responsável pela **análise e processamento de eventos (analytics)** do projeto **ToggleMaster**.  
Funciona como um **worker de backend**, não possuindo API pública (exceto o endpoint `/health`).

- **Aplicação:** Python  
- **Banco de dados:** Amazon DynamoDB  
- **Fila:** Amazon SQS (saída)

---
---

# 🚀 Como Executar o Projeto

> **Importante:**  
> Todos os comandos a seguir devem ser executados **na raiz do projeto**.

### 1. Aplicar a infraestrutura com Terraform

Provisiona toda a infraestrutura necessária do projeto.

```bash
make terraform_apply
```


### 2. Build das imagens e envio para o Amazon ECR

Realiza o build das imagens Docker das aplicações e envia para o **Amazon ECR**.

> **Dependência:**  
> Preencher a variável `ACCOUNT_ID`.

```bash
make docker_build
```


### 3. Subir as aplicações iniciais (Auth - Flag - Targeting)

```bash
make k8s_up
```

Agora pegue o endpoint do cluster que foi gerado no passo anterior com o comando "kubectl get svc -Aowide" (linha do LOADBALANCER). Preencha a variável CLUSTER_ENDPOINT com este endpoint.

---

> **Atenção:**  
> APENAS SIGA OS PRÓXIMOS PASSOS COM AS PARTES ACIMA CONFIGURADAS.

### 4. Testar se as aplicações subiram normalmente

Verifica se os serviços iniciais estão respondendo corretamente.

> **Dependência:**  
> Variável `CLUSTER_ENDPOINT` configurada.

```bash
make test_1
```

### 5. Gerar a API Key

Realiza a geração da chave de API utilizada para autenticação entre os serviços.

> **Dependência:**  
> Variável `CLUSTER_ENDPOINT` configurada.

```bash
make init_2.1
```

Pegue a API KEY que foi emitida no comando anterior "TM_..." e adicione na variável API_KEY.

---

> **Atenção:**  
> APENAS SIGA OS PRÓXIMOS PASSOS COM AS PARTES ACIMA CONFIGURADAS.

### 6. Criar uma Feature Flag

Cria uma nova *feature flag* no sistema.

> **Dependências:**  
> Variáveis `CLUSTER_ENDPOINT` e `API_KEY` configuradas.

```bash
make init_2.2
```

### 7. Definir regras de segmentação

Define regras de segmentação (*targeting*) para a *feature flag* criada.

> **Dependências:**  
> Variáveis `CLUSTER_ENDPOINT` e `API_KEY` configuradas.

```bash
make init_2.3
```

Passe o valor da variável API_KEY como secret do Evaluation Service em "app/kubernetes/4-evaluation-service/secrets.yaml"
Passe como secret do analytics os valores pegos na AWS Academy: AWS_ACCESS_KEY - AWS_SECRET_KEY - AWS_SESSION_TOKEN em "app/kubernetes/5-analytics-service/secrets.yaml"

---

> **Atenção:**  
> APENAS SIGA OS PRÓXIMOS PASSOS COM AS PARTES ACIMA CONFIGURADAS.

### 8. Subir os demais serviços no Kubernetes

Realiza o deploy dos serviços restantes no cluster Kubernetes.

```bash
make k8s_up_2
```

### 9. Testar se as aplicações subiram normalmente

Valida se os serviços adicionais foram iniciados corretamente.

> **Dependência:**  
> Variável `CLUSTER_ENDPOINT` configurada.

```bash
make test_2
```

### 10. Testar a saúde de todas as aplicações

Executa uma verificação completa para garantir que todos os serviços estejam saudáveis e operando corretamente.

```bash
make test_all
```
