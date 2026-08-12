FROM cgr.dev/chainguard/go:latest-dev@sha256:8a96275da3e6f9b644d7e417832c0d22b215d409b813d1d5b942f777aaa36860 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o TaskPilot-backend .

FROM cgr.dev/chainguard/static:latest@sha256:24dd7ff8788fdfadda39eeeaefefb6d1cec6002a545935a5f7e017484053734f
WORKDIR /
COPY --from=builder /app/TaskPilot-backend /TaskPilot-backend
USER nonroot
EXPOSE 8080
ENTRYPOINT ["./TaskPilot-backend"]