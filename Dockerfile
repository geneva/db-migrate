FROM golang:1.24-alpine

RUN apk add --no-cache postgresql-client g++ && \
    rm -rf /var/cache/apk/* && \
    go install github.com/rubenv/sql-migrate/...@v1.7.2

COPY entrypoint.sh entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
