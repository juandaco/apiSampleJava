pipeline {
   agent any 

    stages {
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


        stage('Docker-deploy') {
            steps {
                sh 'scripts/docker.sh'
            }
        }

        stage('Kubernetes-deploy') {
            steps {
                sh 'scripts/k8s.sh'
            }
        }


    }
}
