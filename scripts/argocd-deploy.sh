#!/bin/bash
set -euo pipefail

echo "ArgoCd Configurations"

echo -e "1. To create Argocd press 1 \n2. To delete Argocd press 2"
read -p "Enter a number : " num

if [[ ! "$num" =~ ^[12]$ ]]; then
  echo "Invalid Selection !"
  exit 1
fi

if [[ "$num" -eq 2 ]]; then
    echo -e "\nDeleting namespace argocd ..."
    kubectl delete namespace argocd

    echo -e "\nDeleting argocd crds ..."
    kubectl delete crd \
    applications.argoproj.io \
    applicationsets.argoproj.io \
    appprojects.argoproj.io
else
    if ! kubectl get namespace argocd >/dev/null 2>&1; then
        echo "Creating argocd namespace"
        kubectl create namespace argocd
    fi 

    echo -e "\nInstalling necessary resources ..."
    kubectl apply -n argocd \
    --server-side \
    -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

    echo -e "\nWaiting for Argo CD pods to become Ready..."
    kubectl wait \
    --namespace argocd \
    --for=condition=Ready \
    pods \
    --all \
    --timeout=300s

    echo -e "\nArgo CD is ready!"
    kubectl get pods -n argocd

    echo -e "\nExposing Argo CD server using NodePort..."
    kubectl patch svc argocd-server \
    -n argocd \
    -p '{"spec":{"type":"NodePort"}}'

    echo -e "\nArgo CD service:"
    kubectl get svc argocd-server -n argocd

    echo -e "\nArgo CD admin credentials:"
    echo "Username: admin"
    echo -n "Password: "
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

    echo -e "\nPortforwarding your argo cd server ..."
    echo -e "\nUse This cmd to port-forward: kubectl port-forward svc/argocd-server -n argocd 8080:443 "
fi