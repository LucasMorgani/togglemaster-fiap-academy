# Projeto Togglemaster fase 2

--Todos os comandos a seguir devem ser feitos na raiz do projeto--

1 - Aplicar o terraform
  Comando: make terraform_apply

2 - Buildar a imagem das aplicações e enviar para o ECR
  Dependências: preencher a variável ACCOUNT_ID
  Comando: make docker_build

3 - Subir as aplicações iniciais (Auth - Flag - Targeting)
  Comando: make k8s_up

Agora pegue o endpoint do cluster que foi gerado no passo anterior com o comando "kubectl get svc -Aowide" (linha do LOADBALANCER). Preencha a variável CLUSTER_ENDPOINT com este endpoint.

APENAS SIGA OS PRÓXIMOS PASSOS COM A PARTE ACIMA CONFIGURADA

4 - Teste se as aplicações subiram normalmente
  Dependências: preencher a variável CLUSTER_ENDPOINT
  comando: make test_1

5 - Pegando a API KEY
  Dependências: preencher a variável CLUSTER_ENDPOINT
  comando: make init_2.1

Pegue a API KEY que foi emitida no comando anterior "TM_..." e adicione na variável API_KEY.

APENAS SIGA OS PRÓXIMOS PASSOS COM A PARTE ACIMA CONFIGURADA

6 - Criando a Flag
  Dependências: Variráveis CLUSTER_ENDPOINT e API_KEY configuradas
  comando: make init_2.2

7 - Definindo regra de segmentação
  Dependência: Variráveis CLUSTER_ENDPOINT e API_KEY configuradas
  comando: make init_2.3

Passe o valor da variável API_KEY como secret do Evaluation Service em "app/kubernetes/4-evaluation-service/secrets.yaml"
Passe como secret do analytics os valores pegos na AWS Academy: AWS_ACCESS_KEY - AWS_SECRET_KEY - AWS_SESSION_TOKEN em "app/kubernetes/5-analytics-service/secrets.yaml"

APENAS SIGA OS PRÓXIMOS PASSOS COM A PARTE ACIMA CONFIGURADA

8 - Subir os outros serviços para o K8S
  Comando: make k8s_up_2

9 - Teste se as aplicações subiram normalmente
  Dependências: preencher a variável CLUSTER_ENDPOINT
  comando: make test_2

10 - Testar se todas as aplicações estão saudáveis
  comando: make test_all
