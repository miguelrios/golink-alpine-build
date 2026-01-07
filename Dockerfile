FROM golang:1.23-alpine AS builder
RUN apk add --no-cache git
ENV GOTOOLCHAIN=auto
WORKDIR /app
RUN git clone https://github.com/tailscale/golink.git .
RUN CGO_ENABLED=0 go build -o /golink ./cmd/golink

FROM alpine:latest
RUN apk add --no-cache ca-certificates tzdata
COPY --from=builder /golink /golink
EXPOSE 80
ENTRYPOINT ["/golink"]
