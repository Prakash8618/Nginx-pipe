pipeline {
    agent any
    
    environment {
        SCANNER_HOME = tool name: 'sonarqube', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
    }
    
    tools {
        jdk 'jdk-11'
        maven 'maven3'
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', changelog: false, credentialsId: 'Github-cred', poll: false, url: 'https://github.com/Prakash8618/Nginx-pipe.git'
            }
        }
        
        stage('Maven Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        
        stage('OWASP Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '--scan ./', odcInstallation: 'dp-check7'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        
        stage('Sonar Code Analysis') {
            steps {
                script {
                    withSonarQubeEnv('sonar') {
                        sh 'mvn sonar:sonar'
                    }
                }
            }
        }
        
        stage('Docker Build & Push NGINX App') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'DockerHub_Cred', url: '']) {
                        // Build and push the Docker image
                        sh '''
                        docker build -t my-nginx-app .
                        docker tag my-nginx-app prakash8618/my-nginx-app:latest
                        docker push prakash8618/my-nginx-app:latest
                        '''
                    }
                }
            }
        }
        
        stage('Kubernetes Deploy') {
            steps {
                script {
                    // Deploy to Kubernetes
                    sh '''
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    '''
                }
            }
        }
    }
}
