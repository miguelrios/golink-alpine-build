FROM golang:1.23-alpine AS builder
RUN apk add --no-cache git
ENV GOTOOLCHAIN=auto
WORKDIR /app
RUN git clone https://github.com/tailscale/golink.git .
RUN CGO_ENABLED=0 go build -o /golink ./cmd/golink

FROM alpine:latest
RUN apk add --no-cache ca-certificates tzdata curl sqlite
COPY --from=builder /golink /golink

# Create startup script that seeds links then runs golink
RUN echo '#!/bin/sh' > /start.sh && \
    echo '# Wait for golink to create db, then add links' >> /start.sh && \
    echo '(sleep 15 && sqlite3 /data/golink.db "INSERT OR REPLACE INTO Links (Short, Long, Created, LastEdit, Owner) VALUES (\"dashboard\", \"https://p01--dashboard-service--2xht425f6qpg.xv8dbc9lt5.code.run\", datetime(\"now\"), datetime(\"now\"), \"\");" 2>/dev/null || true) &' >> /start.sh && \
    echo 'exec /golink -sqlitedb /data/golink.db' >> /start.sh && \
    chmod +x /start.sh

RUN mkdir -p /data
EXPOSE 80
CMD ["/start.sh"]
