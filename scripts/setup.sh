#!/bin/bash
set -e

export k8sClusterName="jenkins-k8s-azure"
export RG="jenkins-k8s-azure"
export LOCATION=eastus

#Install az aks-cli & kubectl
sudo az aks install-cli

#Create azure resources
az group create -n $RG -l $LOCATION
az aks create -n $k8sClusterName -g $RG --generate-ssh-keys
az aks get-credentials -n $k8sClusterName -g $RG

#Copy kube config and set permissions for jenkins user
sudo cp -R ~/.kube /var/lib/jenkins
sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube/

#Install Docker
curl -sSL https://get.docker.com | sudo -E sh
sudo usermod -aG docker jenkins

#Restart jenkins
sudo service jenkins restart

#Install Helm
sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudo chmod 700 get_helm.sh
sudo ./get_helm.sh