kubectl run --image=metabol/images:jenkinstest --replicas=3 jenkinstest-pod
kubectl expose deployment/jenkinstest-pod --port=80 --name=jenkinstest-svc --type=LoadBalancer
kubectl get pods
kubectl get svc
