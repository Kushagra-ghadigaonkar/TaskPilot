# TaskPilot Docs —  (Complete Flow from local to production)

## 1. First Setup your secrets in .env file you can take refernce from  `.env.example file`
```
cp .env.example .env
```

## 2. Dockerfile build step

- To build docker images of frontend and backend you can use below commands in respective directory
```
docker build -t TaskPilot-frontend ./frontend
docker build -t TaskPilot-backend ./backend
```
- You can Run the postgres database using this command :
```
docker run -d --name postgres --network TaskPilot-net \
  -e POSTGRES_USER=TaskPilot \
  -e POSTGRES_PASSWORD=TaskPilot \
  -e POSTGRES_DB=TaskPilot \
  -v "$PWD/init/postgres":/docker-entrypoint-initdb.d:ro \
  -p 5432:5432 \
  postgres:16-alpine
```
- To run frontend and backend image use below commands :
```
docker run -d --name backend --network TaskPilot-net \
  -e PORT=8080 \
  -e POSTGRES_URL="postgres://TaskPilot:TaskPilot@postgres:5432/TaskPilot?sslmode=disable" \
  -p 8081:8080 \
  TaskPilot-backend
```
```
docker run -d --name frontend --network TaskPilot-net \
  -p 8080:4173 \
  TaskPilot-frontend
```

## 3. DockerCompose File Step

- You can build and run both images with one `docker compose up -d`  command in one networks with below steps :

- You can access your website on broswer on the port which you have configured as your frontend host port :
```
http://localhost:8080/health   
```

## 4. DevSecOps Ci Workflow 
```mermaid
graph LR
    %% Trigger
    Push([Push to main]) --> Trigger[DevSecOps Pipeline]

    %% Parallel Jobs
    subgraph STAGE_1 ["Stage 1: Security & Quality Checks (Parallel)"]
        Trigger --> Q[Code Quality<br/><i>ESLint / Go Vet</i>]
        Trigger --> S[Secret Scan<br/><i>Gitleaks</i>]
        Trigger --> D[Dependency Check<br/><i>govulncheck / npm audit</i>]
        Trigger --> C[Container Security<br/><i>Hadolint / Trivy</i>]
        Trigger --> SQ[SonarQube Scan<br/><i>Static Analysis</i>]
        Trigger --> T[Code Tests<br/><i>Go Test / NPM Test</i>]
    end

    %% Dependency Link
    Q & S & D & C & SQ & T -->|All Pass| P

    %% Stage 2
    subgraph STAGE_2 ["Stage 2: Deployment"]
        P[Docker Push<br/><i>Buildx Matrix</i>] --> FE[(DockerHub: Frontend)]
        P --> BE[(DockerHub: Backend)]
    end

    %% Minimal Styling
    style Push fill:#2563eb,color:#fff,stroke:none
    style Trigger fill:#1e293b,color:#fff,stroke:none
    style P fill:#16a34a,color:#fff,stroke:none
```

### How to configure SonarQube Secrets

To enable SonarQube scanning in your GitHub Actions pipeline:

1. **Get the Host URL**:
   - If using a self-hosted instance, your `SONAR_HOST_URL` is the URL where SonarQube is hosted (e.g., `http://your-sonarqube-ip:9000`).
   - If using SonarCloud, use `https://sonarcloud.io`.
2. **Generate a SonarQube Token**:
   - In SonarQube: Go to your **Profile (User Icon) > My Account > Security**.
   - Under **Generate Tokens**, enter a token name, select the **User Token** type, and click **Generate**.
   - Copy the generated token string.
3. **Add Secrets to GitHub**:
   - Go to your GitHub Repository settings.
   - Navigate to **Settings > Secrets and variables > Actions**.
   - Add two Repository Secrets:
     - `SONAR_TOKEN`: Paste the SonarQube token you copied.
     - `SONAR_HOST_URL`: Paste your SonarQube server URL.
4. **Configure Sonar-project.properties in root directory of project**

### How to configure Docker Hub Credentials

To allow the CI pipeline to build and push images to Docker Hub:
1. Navigate to **Settings > Secrets and variables > Actions**.
2. Under the **Variables** tab, add:
   - `DOCKERHUB_USERNAME`: Your Docker Hub username.
3. Under the **Secrets** tab, add:
   - `DOCKERHUB_TOKEN`: A Personal Access Token (PAT) generated from Docker Hub.

## 5. How To Configure Terraform infrastructure

**Refer Terraform folder README.md**

## 6. How to Configure Ansible Infrasturcture ?

**This is optional folder because ansible is used to setup jumphost , To automate deployment of this project**

**If You Still wants to create refer README.md, You will understand dynamic inventory file**

**Dont forget to create varibles as like ``sample_var.yml`` file and create all folder in groups_vars folder and create vault to store aws iam credentials**

## 7. How to Configure argocd , envoy gateway and observability for project in gitops folder?

**Igonre Cert-manager folder**

### 1. ArgoCd
**For ArgoCd You only have to change github repo url by opening every files in folder and subfolders , but everything else you dont have to  configure you can just use my code as it is rest**

### 2. Envoy-Gateway-Config & External Secrets folder
**Here also you dont have to configure anything just in secret folder use this region which you have used to configure terraform aws secret manager**

### 3. Observability Folder
**In this Folder, you can use this folder and subfolders as it is just apply below command ```immediatly``` after applying observability namespace**

```
kubectl -n observability create secret generic alertmanager-slack \
  --from-literal=slack_api_url='YOUR_SLACK_API_URL' \
  --dry-run=client -o yaml | kubectl apply -f -
```

## Overall Production Architecture of project :


```mermaid
graph LR
    %% Trigger & Compact CI
    Push([Push to main]) --> CI[DevSecOps CI<br/><i>Quality, Security & Tests</i>]
    
    %% CI to Docker Registry
    CI -->|Pass| PushDocker[Build & Push<br/><i>DockerHub Images</i>]

    %% GitOps Continuous Delivery (ArgoCD)
    subgraph GITOPS ["GitOps Deployment (ArgoCD)"]
        PushDocker -. Trigger Sync .-> App_TaskPilot & App_Platform

        subgraph APP_SYNC ["ArgoCD App: taskpilot (k8s/)"]
            App_TaskPilot[TaskPilot Core App<br/><i>Frontend & Backend Deployments</i>] --> Cluster_Default[(K8s Cluster: default)]
        end

        subgraph PLATFORM_SYNC ["ArgoCD App: platform (gitops/argocd/platform)"]
            App_Platform[Platform Stack] --> Envoy[Envoy Gateway]
            App_Platform --> Secrets[External Secrets]
            App_Platform --> Obs[Observability Stack]

            subgraph OBS_STACK ["Telemetry & Monitoring"]
                Obs --> Prom[Prometheus & Grafana]
                Obs --> Logs[Loki & Tempo]
                Obs --> Alerts[Alertmanager]
                Obs --> Agents[Collector Agent/Gateway]
            end
            
            Envoy & Secrets & OBS_STACK --> Cluster_ArgoCD[(K8s Cluster: argocd)]
        end
    end

    %% Minimal Styling
    style Push fill:#2563eb,color:#fff,stroke:none
    style CI fill:#1e293b,color:#fff,stroke:none
    style PushDocker fill:#16a34a,color:#fff,stroke:none
    style App_TaskPilot fill:#0284c7,color:#fff,stroke:none
    style App_Platform fill:#7c3aed,color:#fff,stroke:none
```

