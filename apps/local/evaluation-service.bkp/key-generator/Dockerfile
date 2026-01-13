FROM alpine/curl

RUN apk add --no-cache jq

WORKDIR /app

RUN mkdir -p /data

COPY generate-key.sh /app/generate-key.sh

RUN chmod +x /app/generate-key.sh

ENTRYPOINT ["/app/generate-key.sh"]