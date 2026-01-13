FROM golang:1.21-alpine

WORKDIR /app

COPY *.go .

COPY go.mod .

RUN go mod tidy

RUN env

CMD ["go", "run", "."]