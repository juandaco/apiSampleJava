# CI/CD Pipeline.
This demo is a demonstration of "everything as code" Devops automated system using the following tools:

1) Codebase - Java
2) Packaging - Maven
3) Testing - JUnit
4) Subversion -Git
5) CI  - Jenkins
5) Container - Docker
7) CD - Kubernetes


Make sure Jenkins, Kubernetes and docker are installed on the Production environment.
You shold have access to jenkins dashboard to create the pipeline.
Install git, java and maven on your development box. 
Create a jenkins pipeline of type Github/SCM pointing to this repo or a fork of it.
Specify Jenkinsfile as build script.

Run the build and watch the pipeline thus :
Build --> Test --> Deliver --> Docker --> Kubernetes


Bonus
*******
Create a github "push" webhook pointing to your jenkins host , make changes , push to the repo and
watch the build run automatically.

**Your jenkins host might internet access to be reachable by github webhook events. 



*****************Verify in Kubernetes***************************************************8


:~$ kubectl get pods
*******************************************************************************************
NAME                              READY     STATUS      RESTARTS   AGE
jenkinstest-pod-9945cbff4-bkcfv   0/1       Completed   3          59s
jenkinstest-pod-9945cbff4-jpbsw   0/1       Completed   3          59s
jenkinstest-pod-9945cbff4-rchs4   0/1       Completed   3          59s

:~$ kubectl get svc
********************************************************************************************
NAME              TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
jenkinstest-svc   LoadBalancer   10.102.74.122   <pending>     80:31359/TCP   1m


:~$ kubectl get deployment
***********************************************************************************************
NAME              DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
jenkinstest-pod   3         3         3            0           1m

:~$ kubectl delete deployment jenkinstest-pod
*********************************************************************************************
deployment.extensions "jenkinstest-pod" deleted


:~$ kubectl delete svc jenkinstest-svc
**************************************************************************************
service "jenkinstest-svc" deleted


TODO
*******
Configure monitorization and log processing
