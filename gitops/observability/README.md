                         ┌─────────────────┐
                         │ Kubernetes apps │
                         └────────┬────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    │                           │
                    ▼                           ▼
             OTel Agent                  Envoy Gateway
             DaemonSet                  telemetry
                    │                           │
                    └─────────────┬─────────────┘
                                  ▼
                         OTel Gateway
                         Deployment
                                  │
                 ┌────────────────┼────────────────┐
                 │                │                │
                 ▼                ▼                ▼
               Loki            Tempo          Prometheus
                 │                │                │
                 └────────────────┼────────────────┘
                                  │
                                  ▼
                            ┌───────────┐
                            │  Grafana  │
                            └─────┬─────┘
                                  │
                         Your 4 new files
                                  │
                 ┌────────────────┴───────────────┐
                 │                                │
                 ▼                                ▼
          DevBoard AI — RED                 Ollama Health
             Dashboard                       Dashboard