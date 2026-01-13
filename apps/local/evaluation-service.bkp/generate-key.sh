#!/bin/sh

#Valida se a variavel de ambiente necessária foi criada
echo "A variável $MASTER_KEY está setada"

#Valida se o diretório /data existe
ls /data

#Verifica o endpoint
if ! curl -fsS http://auth-service:8001/health ; then
    echo "Erro: endpoint não encontrado"
    exit 1
fi
echo "Certo: endpoint validado"

#Captura o key necessária
KEY=$(curl -X POST http://auth-service:8001/admin/keys \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $MASTER_KEY" \
  -d '{"name": "evaluation-service-key"}' | jq -r ".key") 

#Deleta qualquer linha que comece com $SERVICE_API_KEY
FILE="/data/api_key.txt"

if [ -f "$FILE" ]; then
  sed -i '/^[[:space:]]*SERVICE_API_KEY.*/d' "$FILE"
fi

#Armazena a key
touch /data/api_key.txt
echo -e "\nSERVICE_API_KEY=\"$KEY\"" >> /data/api_key.txt
echo -e "variável direta: \n $KEY"
echo "lendo o arquivo /data/api_key.txt:"
cat /data/api_key.txt