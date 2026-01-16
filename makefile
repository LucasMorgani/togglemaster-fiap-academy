#-------------------------------------------------------------------------------
#Adicionando variáveis

#Endpoint do ingress, é necessário adicionar para testar as aplicações (teste de integridade de todas aplicações)
CLUSTER_ENDPOINT=
#Chave da API criada pelo auth-service, é necessário adicionar para testar as aplicações (teste das aplicações flag, targeting e evaluation)
API_KEY=
#Account ID, é necessário adicionar para testar as aplicações (necessário). Pegar no console na parte superior direita.
ACCOUNT_ID=
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#Iniciando o Terraform. Ele criará toda a Infra na AWS e deixará tudo pre-pronto para o K8S
#SÓ APLIQUE O DESTROY NO FINAL, ELE DESTROI TODA A INFRA
terraform_apply:
#Planeja o Terraform
	terraform plan
#Aplica o Terraform
	terraform apply --auto-approve
	sleep 10
#Pega e aplica o context do cluster criado pelo terraform
	aws eks update-kubeconfig --region us-east-1 --profile fiapaws --name togglemaster_project-cluster

terraform_destroy:
#Destroi o terraform (depois de aplicar manifestos no kubernetes, ele da problema, portanto é necessário resetar a conta da aws manualmente)
	terraform destroy --auto-approve
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#Buildar e push das imagens para o ECR
#Esse processo só pode ser feito depois do Terraform, já que ele está criando os registries na AWS
#É necessário ter a variável ACCOUNT_ID preenchida
docker_build:
#build
	cd apps/local/1-auth-service && docker build -t  $(ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/togglemaster_auth-service:1.2.0 . && docker push $(ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/togglemaster_auth-service:1.2.0
	cd apps/local/2-flag-service && docker build -t  $(ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/togglemaster_flag-service:1.2.0 . && docker push $(ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/togglemaster_flag-service:1.2.0
	cd apps/local/3-targeting-service && docker build -t  $(ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/togglemaster_targeting-service:1.2.0 . && docker push $(ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/togglemaster_targeting-service:1.2.0
	cd apps/local/4-evaluation-service && docker build -t  $(ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/togglemaster_evaluation-service:1.2.0 . && docker push $(ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/togglemaster_evaluation-service:1.2.0
	cd apps/local/5-analytics-service && docker build -t  $(ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/togglemaster_analytics-service:1.2.0 . && docker push $(ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/togglemaster_analytics-service:1.2.0
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#Subir primeira parte dos manifestos kubernetes para o cluster (somente auth, flag e targeting)
k8s_up:
#Create-resources
#Revalida se o context foi atualizado
	aws eks update-kubeconfig --region us-east-1 --profile fiapaws --name togglemaster_project-cluster
	sleep 30
#Metrics Server para HPA
	kubectl apply -f apps/kubernetes/services/metrics.yaml
#Ingress Controller NGINX para ingress resources
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.6/deploy/static/provider/cloud/deploy.yaml
	sleep 30
#Aplica ingress resources - É necessário que o ingress controller tenha subido adequadamente
	kubectl apply -f apps/kubernetes/services/ingress.yaml

#auth-service-app
	kubectl apply -f apps/kubernetes/1-auth-service/secrets.yaml
	kubectl apply -f apps/kubernetes/1-auth-service/app/deployment.yaml
	kubectl apply -f apps/kubernetes/1-auth-service/app/cluster-ip.yaml
#auth-service-db
	kubectl apply -f apps/kubernetes/1-auth-service/rds-db/configmap.yaml
	-kubectl apply -f apps/kubernetes/1-auth-service/rds-db/job.yaml
#flag-service
	kubectl apply -f apps/kubernetes/2-flag-service/secrets.yaml
	kubectl apply -f apps/kubernetes/2-flag-service/app/deployment.yaml
	kubectl apply -f apps/kubernetes/2-flag-service/app/cluster-ip.yaml
#flag-service-db - JOB QUE CONFIGURA O DB
	kubectl apply -f apps/kubernetes/2-flag-service/rds-db/configmap.yaml
	-kubectl apply -f apps/kubernetes/2-flag-service/rds-db/job.yaml
#targeting-service - JOB QUE CONFIGURA O DB
	kubectl apply -f apps/kubernetes/3-targeting-service/secrets.yaml
	kubectl apply -f apps/kubernetes/3-targeting-service/app/deployment.yaml
	kubectl apply -f apps/kubernetes/3-targeting-service/app/cluster-ip.yaml
#targeting-service-db - JOB QUE CONFIGURA O DB
	kubectl apply -f apps/kubernetes/3-targeting-service/rds-db/configmap.yaml
	-kubectl apply -f apps/kubernetes/3-targeting-service/rds-db/job.yaml
#-------------------------------------------------------------------------------


#Para pegar o endpoint do cluster, rode o comando "kubectl get svc -Aowide"
#Ela trará o endpoint na linha do LOADBALANCER
#Configure esse endpoint na variável CLUSTER_ENDPOINT


#-------------------------------------------------------------------------------
#Necessário ter a variável CLUSTER_ENDPOINT configurada
#Testar os recursos que subiram (somente auth, flag e targeting)
test_1:
	curl http://$(CLUSTER_ENDPOINT)/auth-service/health
	curl http://$(CLUSTER_ENDPOINT)/flag-service/health
	curl http://$(CLUSTER_ENDPOINT)/targeting-service/health
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#Necessário ter a variável CLUSTER_ENDPOINT configurada para todos e API_KEY para init 2.2 e 2.3

#Criando o API_KEY - Nessa parte, terá um output sinalizando qual é a API KEY. Pegue e adicione como variável em API_KEY
init_2.1:
	curl -X POST http://$(CLUSTER_ENDPOINT)/auth-service/admin/keys -H "Content-Type: application/json" -H "Authorization: Bearer admin-secreto-123" -d '{"name": "admin-para-flag-service"}'

init_2.2:
#Criando a FLAG	- Para realizar esse passo é necessário ter setado a API_KEY
	curl -X POST http://$(CLUSTER_ENDPOINT)/flag-service/flags -H "Content-Type: application/json" -H "Authorization: Bearer $(API_KEY)" -d '{"name": "enable-new-dashboard","description": "Ativa o novo dashboard para usuários","is_enabled": true}'

init_2.3:
#Definindo regra de segmentação
	curl -X POST http://$(CLUSTER_ENDPOINT)/targeting-service/rules -H "Content-Type: application/json" -H "Authorization: Bearer $(API_KEY)" -d '{"flag_name": "enable-new-dashboard","is_enabled": true,"rules": {"type": "PERCENTAGE","value": 50}}'
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#Subir segunda parte dos manifestos kubernetes para o cluster (somente evaluation e analytics)
k8s_up_2:
#evaluation-service-app
	kubectl apply -f apps/kubernetes/4-evaluation-service/secrets.yaml
	kubectl apply -f apps/kubernetes/4-evaluation-service/app/deployment.yaml
	kubectl apply -f apps/kubernetes/4-evaluation-service/app/cluster-ip.yaml
	kubectl apply -f apps/kubernetes/4-evaluation-service/app/hpa.yaml
#analytics-service
	kubectl apply -f apps/kubernetes/5-analytics-service/secrets.yaml
	kubectl apply -f apps/kubernetes/5-analytics-service/app/deployment.yaml
	kubectl apply -f apps/kubernetes/5-analytics-service/app/cluster-ip.yaml
	kubectl apply -f apps/kubernetes/5-analytics-service/app/hpa.yaml

#Necessário ter a variável CLUSTER_ENDPOINT configurada
#Testar os recursos que subiram (somente evaluation e analytics)
test_2:
	curl http://$(CLUSTER_ENDPOINT)/evaluation-service/health
	curl http://$(CLUSTER_ENDPOINT)/analytics-service/health
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#Testes unitários

#Testar se a API_KEY é válida
key_validate:
	curl http://$(CLUSTER_ENDPOINT)/validate -H "Authorization: Bearer $(API_KEY)"

#Testar aplicações unitárias
test_auth:
	curl http://$(CLUSTER_ENDPOINT)/auth-service/health
test_flag:
	curl http://$(CLUSTER_ENDPOINT)/flag-service/health
test_targeting:
	curl http://$(CLUSTER_ENDPOINT)/targeting-service/health
test_evaluation:
	curl http://$(CLUSTER_ENDPOINT)/evaluation-service/health
test_analytics:
	curl http://$(CLUSTER_ENDPOINT)/analytics-service/health

#Testar aplicações GERAL
test_all: test_auth test_flag test_targeting test_evaluation test_analytics
#-------------------------------------------------------------------------------	