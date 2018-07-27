all: deploy

deploy:
	@kubectl create -f ./coredns.yaml

clean:
	@kubectl delete -f ./coredns.yaml
