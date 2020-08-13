# 

FROM golang:alpine AS builder
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk add git
#RUN go get -u github.com/gorilla/mux
#RUN go get -u google.golang.org/grpc