FROM --platform=$BUILDPLATFORM golang:1.22-alpine AS builder

WORKDIR /app

COPY main.go go.mod go.sum .

ARG TARGETOS
ARG TARGETARCH
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /app/wasabi_exporter main.go

FROM alpine:3.20

RUN apk add --no-cache ca-certificates && \
    adduser -D -u 65534 exporter

WORKDIR /home/exporter

COPY --from=builder /app/wasabi_exporter .

USER exporter

EXPOSE 8080

CMD ["./wasabi_exporter"]

