pipeline {
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: maven
            image: maven:3.8.1-jdk-11
            command:
            - sleep
            args:
            - 99d
          - name: gitleaks
            image: zricethezav/gitleaks:v7.6.1
            command:
            - sleep
            args:
            - 99d
          - name: snyk
            image: snyk/snyk:maven-3-jdk-11
            command:
            - sleep
            args:
            - 99d
          - name: kaniko
            image: gcr.io/kaniko-project/executor:v1.7.0-debug
            command:
            - /busybox/sleep
            args:
            - 99d
            volumeMounts:
            - name: jenkins-docker-cfg
              mountPath: /kaniko/.docker
          - name: trivy
            image: aquasec/trivy:0.20.2
            command:
            - sleep
            args:
            - 99d
          - name: helm
            image: alpine/helm:3.7.1
            command:
            - sleep
            args:
            - 99d
          volumes:
          - name: jenkins-docker-cfg
            projected:
              sources:
              - secret:
                  name: regcred
                  items:
                  - key: .dockerconfigjson
                    path: config.json
        '''
    }
  }

  parameters{
    string(name: 'DOCKER_REPOSITORY', defaultValue: 'juandaco', description: 'Docker repo name.')
    string(name: 'DOCKER_IMAGE', defaultValue: 'sre-challenge', description: 'Docker image name.')
    choice(name: 'TRIVY_SCAN_TYPE', choices: ['library', 'os,library'], description: 'library: only application code.\nos,library: application and os.')
  }

  stages {
    stage('SCM Checkout') {
      steps {
        sh 'echo Checking out git repo...'
        git branch: "${env.GIT_BRANCH}", url: 'https://github.com/juandaco/apiSampleJava.git'
      }
    }
    stage('Build') {
      steps {
        container('maven') {
          sh 'mvn -B -DskipTests clean package'
        }
      }
    }
    stage('Testing') {
      parallel {
        stage('Tests') {
          steps {
            container('maven') {
              sh 'mvn test'
            }
          }
        }
        stage('SonarCloud') {
          environment {
            SONAR_TOKEN = credentials('SONAR_TOKEN')
          }
          steps {
            container('maven') {
              sh 'mvn verify org.sonarsource.scanner.maven:sonar-maven-plugin:sonar -DskipTests -Dsonar.projectKey=adidas-sre-challenge'
            }
          }
        }
        stage('Snyk') {
          environment {
            SNYK_TOKEN = credentials('SNYK_TOKEN')
          }
          steps {
            container('snyk') {
              sh 'snyk test'
              sh 'snyk monitor'
            }
          }
        }
        // SAST
        // stage('Checkmarx') {}
        stage('GitLeaks') {
          steps {
            container('gitleaks') {
              sh 'gitleaks --path=./ -v --config-path=gitleaks.config'
            }
          }
        }
      }
    }
    stage('Docker build') {
      steps {
        container('kaniko') {
          sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --cache=true --destination="$DOCKER_REPOSITORY/$DOCKER_IMAGE:$BUILD_NUMBER"'
        }
      }
    }
    stage('Image security test') {
      steps {
        container('trivy') {
          sh 'trivy image --severity HIGH,CRITICAL --exit-code=1 --vuln-type "$TRIVY_SCAN_TYPE" "$DOCKER_REPOSITORY/$DOCKER_IMAGE:$BUILD_NUMBER"'
        }
      }
    }
    stage('Helm deploy') {
      steps {
        container('helm') {
          sh 'if [[ $GIT_BRANCH == "master" ]]; then NAMESPACE=prod; else NAMESPACE=$GIT_BRANCH; fi'
          sh 'echo $NAMESPACE'
          // helm upgrade --namespace dev --install --values /home/vsts/work/1/ContinuousIntegration/values.yaml --set devops.app.env=dev,devops.app.name=beer-ambassador-front,devops.image.registry=crtechpeople.azurecr.io,devops.image.tag=1318519 --wait --atomic beer-ambassador-front
          // sh 'helm upgrade --namespace $NAMESPACE --values helm/values.yaml --set fullnameOverride=$,image.'
        }
      }
    }
  }
}