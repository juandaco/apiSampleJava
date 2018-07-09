
# CI/CD Pipeline.
This demo is a demonstration of "everything as code" Devops automated system using the following tools:

1) Codebase - Java
2) Packaging - Maven
3) Testing - JUnit
4) Subversion -Git
5) CI  - Jenkins
5) Container - Docker
7) CD - Kubernetes

#Installation
Make sure Jenkins, Kubernetes and docker are installed on the Production environment.
You shold have access to jenkins dashboard to create the pipeline.
Install git, java and maven on your development box. 

#Proceedure
Create a jenkins pipeline of type Github/SCM pointing to this repo or a fork of it.
Specify Jenkinsfile as build script.

Run the build and watch the pipeline thus :
Build --> Test --> Deliver --> Docker --> Kubernetes


*******
#Bonus
Create a github "push" webhook pointing to your jenkins host , make changes , push to the repo and
watch the build run automatically.

**Your jenkins host might internet access to be reachable by github webhook events. 


*******
#Verify in Kuberne8es


:~$ kubectl get pods
*******************************************************************************************


:~$ kubectl get svc
********************************************************************************************


:~$ kubectl get deployment
***********************************************************************************************

:~$ kubectl delete deployment jenkinstest-pod
*********************************************************************************************


:~$ kubectl delete svc jenkinstest-svc
**************************************************************************************


TODO
*****************************************************************************************************
Configure monitorization and log processing
