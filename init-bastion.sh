#!/bin/bash
echo "Install Kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

echo "Update kube config"
aws eks update-kubeconfig --region us-east-1 --name tf-created