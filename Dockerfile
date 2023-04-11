# Multi stage building strategy for reducing image size.
FROM 696220221044.dkr.ecr.ap-northeast-2.amazonaws.com/dxp/go-lang-base:1.16.8-alpine3.13 AS build-env
ENV GO111MODULE=on
RUN mkdir /app
WORKDIR /app

# Install each dependencies
COPY go.mod /app
COPY go.sum /app
RUN go mod download
RUN apk add --no-cache --virtual git gcc make build-base alpine-sdk

# COPY main module
COPY . /app

# Check and Build
RUN go get golang.org/x/lint/golint && \
    make validate && \
    make build-linux

### If use TLS connection in container, add ca-certificates following command.
### > RUN apk add --no-cache ca-certificates
FROM alpine:3.14
COPY --from=build-env /app/main /
EXPOSE 80
ENTRYPOINT ["/main"]

