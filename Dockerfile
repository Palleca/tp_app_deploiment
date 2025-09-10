# ---- Build stage ----
FROM golang:1.25 AS builder

WORKDIR /app

# Accélère les builds en cachant les dépendances
COPY go.mod go.sum ./
RUN go mod download

# Copie le reste (inclut ton dossier embed "swagger-ui")
COPY . .

# Build statique du binaire (plus léger et portable)
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags "-s -w" -o server .

# ---- Runtime stage (léger) ----
FROM gcr.io/distroless/static-debian12

WORKDIR /app
COPY --from=builder /app/server /app/server

# Le serveur écoute sur 8080
EXPOSE 8080

# Démarrage
USER nonroot:nonroot
ENTRYPOINT ["/app/server"]
