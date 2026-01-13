FROM golang:1.21-alpine

WORKDIR /app

COPY *.go .

COPY go.mod .

COPY key-generator/data/api_key.txt .

RUN go mod tidy

RUN env

#RUN echo SERVICE_API_KEY=$(cat /app/api_key.txt) >> ~/.bashrc

RUN touch /entrypoint.sh

# Copia o entrypoint corretamente
RUN cat <<'EOF' > /entrypoint.sh
#!/bin/sh

set -e

# Carrega a API key
if [ -f /app/api_key.txt ]; then
    export SERVICE_API_KEY=$(cat /app/api_key.txt)
fi

echo "SERVICE_API_KEY carregada: $SERVICE_API_KEY"

echo "Entrypoint recebeu args: $@"
exec "$@"
EOF

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
CMD ["go", "run", "."]