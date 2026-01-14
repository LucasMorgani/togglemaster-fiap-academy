cluster_endpoint=a7e27feef316c48d1a97ec2dbb8df092-332776828.us-east-1.elb.amazonaws.com
API_KEY=tm_key_1d27ccc99d8f3f14efe9b385ad7711a7eaf62b3e8033dd58a1fd71082778a0cd

terraform_apply:
	terraform plan
	terraform apply --auto-approve
	aws eks update-kubeconfig --region us-east-1 --profile fiapaws --name togglemaster_project-cluster

terraform_destroy:
	kubectl delete svc --all --all-namespaces
	kubectl delete secrets --all --all-namespaces
	kubectl delete configmap --all --all-namespaces
	kubectl delete ingress --all --all-namespaces
	kubectl delete job --all --all-namespaces
	kubectl delete pod --all --all-namespaces
	kubectl delete pvc --all --all-namespaces
	-kubectl delete -f apps/kubernetes/services/metrics.yaml
	-kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.6/deploy/static/provider/cloud/deploy.yaml
	terraform destroy -target=module.eks --auto-approve
	terraform destroy --auto-approve

k8s_up:
#Create-resources
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

make_all: terraform_apply k8s_up

test:
	curl http://$(cluster_endpoint)/auth-service/health
	curl http://$(cluster_endpoint)/flag-service/health
	curl http://$(cluster_endpoint)/targeting-service/health
	curl http://$(cluster_endpoint)/evaluation-service/health
	curl http://$(cluster_endpoint)/analytics-service/health

init_1:
#Criando o API_KEY
	curl -X POST http://$(cluster_endpoint)/auth-service/admin/keys -H "Content-Type: application/json" -H "Authorization: Bearer admin-secreto-123" -d '{"name": "admin-para-flag-service"}'
init_2:
#Criando a FLAG	
	curl -X POST http://$(cluster_endpoint)/flag-service/flags -H "Content-Type: application/json" -H "Authorization: Bearer $(API_KEY)" -d '{"name": "enable-new-dashboard","description": "Ativa o novo dashboard para usuários","is_enabled": true}'
init_3:
#Definindo regra de segmentação
	curl -X POST http://$(cluster_endpoint)/targeting-service/rules -H "Content-Type: application/json" -H "Authorization: Bearer $(API_KEY)" -d '{"flag_name": "enable-new-dashboard","is_enabled": true,"rules": {"type": "PERCENTAGE","value": 50}}'

