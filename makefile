cluster_endpoint=a9f14118ef6124e7fb383dc2d3d45e6a-2144892360.us-east-1.elb.amazonaws.com
API_KEY=tm_key_1ef7e5f8ed00afc4ddd7ed7f6c3734072f6e79180ea95e72688e9cba426675f2
ACCOUNT_ID=449954007039

terraform_apply:
	terraform plan
	terraform apply --auto-approve
	sleep 10
	aws eks update-kubeconfig --region us-east-1 --profile fiapaws --name togglemaster_project-cluster

terraform_destroy:
	echo -e "\e[33m⚠ Toda a infra será desligada em..\e[0m \n"
	for i in {5..1}; do echo $i; sleep 1; done
	kubectl delete svc --all --all-namespaces
	kubectl delete secrets --all --all-namespaces
	kubectl delete configmap --all --all-namespaces
	kubectl delete ingress --all --all-namespaces
	kubectl delete job --all --all-namespaces
	kubectl delete pod --all --all-namespaces
	kubectl delete pvc --all --all-namespaces
	-kubectl delete -f apps/kubernetes/services/metrics.yaml
	-kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.6/deploy/static/provider/cloud/deploy.yaml
	terraform destroy -target=module.kubernetes --auto-approve
	terraform destroy -target=module.eks_mng --auto-approve
	terraform destroy -target=module.eks_cluster --auto-approve
	terraform destroy -target=module.resources --auto-approve
	terraform destroy -target=module.eks_network --auto-approve
	terraform destroy --auto-approve

k8s_up:
#Create-resources
	aws eks update-kubeconfig --region us-east-1 --profile fiapaws --name togglemaster_project-cluster
	sleep 30
	kubectl apply -f apps/kubernetes/services/metrics.yaml
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.6/deploy/static/provider/cloud/deploy.yaml
	sleep 30
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
#flag-service-db
	kubectl apply -f apps/kubernetes/2-flag-service/rds-db/configmap.yaml
	-kubectl apply -f apps/kubernetes/2-flag-service/rds-db/job.yaml
#targeting-service
	kubectl apply -f apps/kubernetes/3-targeting-service/secrets.yaml
	kubectl apply -f apps/kubernetes/3-targeting-service/app/deployment.yaml
	kubectl apply -f apps/kubernetes/3-targeting-service/app/cluster-ip.yaml
#targeting-service-db
	kubectl apply -f apps/kubernetes/3-targeting-service/rds-db/configmap.yaml
	-kubectl apply -f apps/kubernetes/3-targeting-service/rds-db/job.yaml
k8s_down:
#auth-service
	kubectl delete -f apps/kubernetes/1-auth-service/app/cluster-ip.yaml
	kubectl delete -f apps/kubernetes/1-auth-service/app/deployment.yaml
	kubectl delete -f apps/kubernetes/1-auth-service/secrets.yaml
#auth-service-db
	kubectl delete -f apps/kubernetes/1-auth-service/rds-db/configmap.yaml
	kubectl delete -f apps/kubernetes/1-auth-service/rds-db/job.yaml
#flag-service
	kubectl delete -f apps/kubernetes/2-flag-service/app/cluster-ip.yaml
	kubectl delete -f apps/kubernetes/2-flag-service/app/deployment.yaml
	kubectl delete -f apps/kubernetes/2-flag-service/secrets.yaml
#flag-service-db
	kubectl delete -f apps/kubernetes/2-flag-service/rds-db/configmap.yaml
	kubectl delete -f apps/kubernetes/2-flag-service/rds-db/job.yaml
#targeting-service
	kubectl delete -f apps/kubernetes/3-targeting-service/app/cluster-ip.yaml
	kubectl delete -f apps/kubernetes/3-targeting-service/app/deployment.yaml
	kubectl delete -f apps/kubernetes/3-targeting-service/secrets.yaml
#targeting-service-db
	kubectl delete -f apps/kubernetes/3-targeting-service/rds-db/configmap.yaml
	kubectl delete -f apps/kubernetes/3-targeting-service/rds-db/job.yaml
#delete-resources
	kubectl delete -f apps/kubernetes/namespaces.yaml
	kubectl delete -f apps/kubernetes/metrics.yaml
	kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.6/deploy/static/provider/cloud/deploy.yaml

test_1:
	curl http://$(cluster_endpoint)/auth-service/health
	curl http://$(cluster_endpoint)/flag-service/health
	curl http://$(cluster_endpoint)/targeting-service/health

project_apply: terraform_apply k8s_up test_1

init_2.1:
#Criando o API_KEY
	curl -X POST http://$(cluster_endpoint)/auth-service/admin/keys -H "Content-Type: application/json" -H "Authorization: Bearer admin-secreto-123" -d '{"name": "admin-para-flag-service"}'
init_2.2:
#Criando a FLAG	
	curl -X POST http://$(cluster_endpoint)/flag-service/flags -H "Content-Type: application/json" -H "Authorization: Bearer $(API_KEY)" -d '{"name": "enable-new-dashboard","description": "Ativa o novo dashboard para usuários","is_enabled": true}'
init_2.3:
#Definindo regra de segmentação
	curl -X POST http://$(cluster_endpoint)/targeting-service/rules -H "Content-Type: application/json" -H "Authorization: Bearer $(API_KEY)" -d '{"flag_name": "enable-new-dashboard","is_enabled": true,"rules": {"type": "PERCENTAGE","value": 50}}'

init_2.4:
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

test_2:
	curl http://$(cluster_endpoint)/evaluation-service/health
	curl http://$(cluster_endpoint)/analytics-service/health

key_validate:
	curl http://$(cluster_endpoint)/validate -H "Authorization: Bearer $(API_KEY)"


docker_build:
#build
	cd apps/local/1-auth-service && docker build -t  $(ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/togglemaster_auth-service:1.2.0 . && docker push $(ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/togglemaster_auth-service:1.2.0
	cd apps/local/2-flag-service && docker build -t  $(ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/togglemaster_flag-service:1.2.0 . && docker push $(ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/togglemaster_flag-service:1.2.0
	cd apps/local/3-targeting-service && docker build -t  $(ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/togglemaster_targeting-service:1.2.0 . && docker push $(ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/togglemaster_targeting-service:1.2.0
	cd apps/local/4-evaluation-service && docker build -t  $(ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/togglemaster_evaluation-service:1.2.0 . && docker push $(ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/togglemaster_evaluation-service:1.2.0
	cd apps/local/5-analytics-service && docker build -t  $(ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/togglemaster_analytics-service:1.2.0 . && docker push $(ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/togglemaster_analytics-service:1.2.0
	