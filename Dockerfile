FROM golang:1.16-alpine

RUN apk add --no-cache postgresql-client g++ && \
    rm -rf /var/cache/apk/* && \
    go get -v github.com/rubenv/sql-migrate/...

COPY entrypoint.sh entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
