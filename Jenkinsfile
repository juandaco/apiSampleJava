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
    string(name: 'DOMAIN', defaultValue: 'skylurker.art', description: 'Root domain to be used for the application.')
  }

  environment {
    NAMESPACE = """${sh(
      returnStdout: true,
      script: 'if [ "$BRANCH_NAME" = "master" ]; then echo "prod"; elif [ "$BRANCH_NAME" = "stage" ]; then  echo "stage"; elif [ "$BRANCH_NAME" = "develop" ]; then echo "dev"; fi'
    )}"""
    PROJECT_NAME = """${sh(
      returnStdout: true,
      script: 'echo ${JOB_NAME%%/*}'
    )}"""
  }

  stages {
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
          sh '/kaniko/executor -f `pwd`/Dockerfile -c `pwd` --cache=true --destination="$DOCKER_REPOSITORY/$DOCKER_IMAGE:$NAMESPACE-$BUILD_NUMBER"'
        }
      }
    }
    stage('Image security test') {
      steps {
        container('trivy') {
          sh 'trivy image --severity HIGH,CRITICAL --exit-code=1 --vuln-type "$TRIVY_SCAN_TYPE" "$DOCKER_REPOSITORY/$DOCKER_IMAGE:$NAMESPACE-$BUILD_NUMBER"'
        }
      }
    }
    stage('Helm deploy') {
      environment {
        SUBDOMAIN = """${sh(
          returnStdout: true,
          script: 'if [ "$NAMESPACE" = "prod" ]; then echo "$PROJECT_NAME.$DOMAIN"; else echo "$PROJECT_NAME-$NAMESPACE.$DOMAIN"; fi'
        )}"""
      }
      steps {
        container('helm') {
          sh 'helm upgrade --namespace $NAMESPACE --values helm/values.yaml --set fullnameOverride=$PROJECT_NAME,image.registry="$DOCKER_REPOSITORY/$DOCKER_IMAGE",image.tag="$NAMESPACE-$BUILD_NUMBER,ingress.hosts[0].jost=$SUBDOMAIN,ingress.tls[0].hosts[0]=$SUBDOMAIN" --wait --atomic $PROJECT_NAME ./helm'
        }
      }
    }
  }
}
