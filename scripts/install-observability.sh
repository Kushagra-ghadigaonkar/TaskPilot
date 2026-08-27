#!/bin/bash

set -e
NAMESPACE=observability

PROMETHEUS_VALUES="/mnt/e/linux/docker/projects/TaskPilot/argocd/observability/prometheus-values.yml"
LOKI_VALUES="/mnt/e/linux/docker/projects/TaskPilot/argocd/observability/loki-values.yml"
TEMPO_VALUES="/mnt/e/linux/docker/projects/TaskPilot/argocd/observability/tempo-values.yml"
OTEL_GATEWAY_VALUES="/mnt/e/linux/docker/projects/TaskPilot/argocd/observability/collector-gateway-values.yml"
OTEL_AGENT_VALUES="/mnt/e/linux/docker/projects/TaskPilot/argocd/observability/collector-agent-values.yml"
GRAFANA_VALUES="/mnt/e/linux/docker/projects/TaskPilot/argocd/observability/grafana-values.yml"

install_if_missing(){
  local RELEASE_NAME="$1"
  local CHART="$2"
  local VALUES_FILE="$3"

  if helm status "$RELEASE_NAME" -n "$NAMESPACE" > /dev/null 2>&1; then
    echo "[$RELEASE_NAME] already installed !"
  else
    echo "[$RELEASE_NAME] not found. Installing..."
    helm upgrade --install "$RELEASE_NAME" "$CHART" \
      -n "$NAMESPACE" \
      -f "$VALUES_FILE "\
      --wait \
      --timeout 10m
  fi
}

echo "Checking namespace..."

kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || {
    echo "Namespace '$NAMESPACE' not found. Creating..."
    kubectl create namespace "$NAMESPACE"
}

echo "Namespace '$NAMESPACE' is ready."


install_if_missing "prometheus" "prometheus-community/kube-prometheus-stack" "$PROMETHEUS_VALUES"
echo "Waiting for Prometheus..."
kubectl rollout status statefulset/prometheus-prometheus-kube-prometheus-prometheus \
  -n "$NAMESPACE" \
  --timeout=10m || true

  
install_if_missing "loki" "grafana/loki" "$LOKI_VALUES"
echo "Waiting for Loki..."
kubectl wait \
  --for=condition=ready pod \
  -l app.kubernetes.io/name=loki \
  -n "$NAMESPACE" \
  --timeout=10m

install_if_missing "tempo" "grafana/tempo" "$TEMPO_VALUES"
echo "Waiting for Tempo..."
kubectl wait \
  --for=condition=ready pod \
  -l app.kubernetes.io/name=tempo \
  -n "$NAMESPACE" \
  --timeout=10m

install_if_missing "otel-collector-gateway" "open-telemetry/opentelemetry-collector" "$OTEL_GATEWAY_VALUES"
echo "Waiting for OTEL Gateway..."
kubectl rollout status deployment/otel-collector-gateway-opentelemetry-collector \
  -n "$NAMESPACE" \
  --timeout=10m || true

install_if_missing "otel-collector-agent" "open-telemetry/opentelemetry-collector" "$OTEL_AGENT_VALUES"
echo "Waiting for OTEL Agent..."
kubectl rollout status daemonset/otel-collector-agent-opentelemetry-collector \
  -n "$NAMESPACE" \
  --timeout=10m || true

install_if_missing "grafana" "grafana/grafana" "$GRAFANA_VALUES"
echo "Waiting for Grafana..."
kubectl rollout status deployment/grafana \
  -n "$NAMESPACE" \
  --timeout=10m

echo ""
echo "======================================"
echo "All observability components deployed!"
echo "======================================"

kubectl get pods -n "$NAMESPACE"

echo -e "\nPortForward for all tools : "
echo -e "\nGrafana : kubectl port-forward svc/grafana 3000:80 -n observability"
echo -e "\nPrometheus : kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n observability"
echo -e "\nLoki : kubectl port-forward svc/loki 3100:3100 -n observability"
echo -e "\nTempo : kubectl port-forward svc/tempo 3200:3200 -n observability"
echo -e "\nOTEL Collector Gateway (GRPC): kubectl port-forward svc/otel-collector-gateway 4317:4317 -n observability"
echo -e "\nOTEL Collector Gateway (HTTP): kubectl port-forward svc/otel-collector-gateway 4318:4318 -n observability"
echo -e "\nOTEL Collector Prometheus Exporter : kubectl port-forward svc/otel-collector-gateway 8889:8889 -n observability"


# kubectl port-forward svc/observability-grafana  3000:80 -n observability