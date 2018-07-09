docker build -t  jenkinstest .
docker tag jenkinstest metabol/images:jenkinstest
docker push metabol/images:jenkinstest
docker run --name jenkinstest-con metabol/images:jenkinstest
docker container rm jenkinstest-con -f
