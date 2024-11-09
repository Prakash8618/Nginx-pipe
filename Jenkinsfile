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
        
        stage('Maven Compile') {
            steps {
                sh 'mvn clean compile'
            }
        }
        
        stage('Maven Test') {
            steps {
                sh 'mvn test'
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
        
        stage('Maven Package') {
            steps {
                sh 'mvn clean package'
            }
        }
        
        stage('Publish to Artifactory') {
            steps {
                script {
                    def server = Artifactory.server 'jfrogserver'
                    def uploadSpec = """{
                        "files": [
                            {
                                "pattern": "target/*.war",
                                "target": "example-repo-local/myapp/${env.BUILD_ID}/"
                            }
                        ]
                    }"""
                    def buildInfo = server.upload spec: uploadSpec
                    server.publishBuildInfo buildInfo
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
                    // Set the Kubernetes context if necessary
                    sh 'kubectl config use-context your-kube-context'  // Change to your context
                    
                    // Deploy to Kubernetes
                    sh '''
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
        success {
            echo 'Build and deployment successful!'
        }
        failure {
            echo 'Build failed. Please check the logs.'
        }
    }
}
