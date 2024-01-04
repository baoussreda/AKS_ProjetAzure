pipeline {
    agent any

    environment {
        ACR_LOGINSERVER = credentials('ACR_LOGINSERVER')
        ACR_ID = credentials('ACR_ID')
        ACR_PASSWORD = credentials('ACR_PASSWORD')
    }

    stages {
        stage('azure-voting-app - Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/baoussreda/azure-voting-app-CloudProjet.git']]])
            }
        }

        stage('Docker Build and Push to ACR') {
            steps {
                sh '''
                    # Azure Container Registry config
                    REPO_NAME="azure-voting-app-CloudProjet"
                    IMAGE_NAME="$ACR_LOGINSERVER/$REPO_NAME:jenkins${BUILD_NUMBER}"

                    # Docker build and push to Azure Container Registry
                    cd ./azure-vote
                    docker build -t $IMAGE_NAME .
                    cd ..

                    docker login $ACR_LOGINSERVER -u $ACR_ID -p $ACR_PASSWORD
                    docker push $IMAGE_NAME
                '''
            }
        }

        stage('Helm Deploy to K8s') {
            steps {
                sh '''
                    # Docker Repo Config
                    REPO_NAME="azure-voting-app-CloudProjet"

                    # HELM config
                    NAME="azure-voting-app-redis"
                    HELM_CHART="./helm/azure-voting-app-redis"

                    # Kubenetes config (for safety, in order to make sure it runs in the selected K8s context)
                    KUBE_CONTEXT="jenkins-k8s-azure"
                    kubectl config --kubeconfig=/var/lib/jenkins/.kube/config view
                    kubectl config set-context $KUBE_CONTEXT

                    # Helm Deployment
                    helm --kube-context $KUBE_CONTEXT upgrade --install --force $NAME $HELM_CHART --set image.repository=$ACR_LOGINSERVER/$REPO_NAME --set image.tag=jenkins${BUILD_NUMBER}
                '''
            }
        }
    }

    post {
        always {
            echo 'Build Steps Completed'
        }
    }
}
