pipeline {
   agent any 

    stages {
        stage('Prepare') {
            steps {
              sh 'export MAVEN_HOME=/opt/maven'
              sh 'export PATH=$PATH:$MAVEN_HOME/bin'
              sh 'mvn --version'
              sh 'mvn clean package'
            }
        }
        stage('Build') {
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('Deliver') { 
            steps {
                sh 'scripts/deliver.sh' 
            }
        }
        stage('Docker') {
            steps {
                sh 'scripts/docker.sh'
            }
        }
        stage('Kubernetes') {
            steps {
                sh 'scripts/k8s.sh'
            }
        }
    }
}
