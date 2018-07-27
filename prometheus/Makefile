all: deploy

deploy: export OPS=create
deploy:
	@kubectl ${OPS} -f ./manifests-all.yaml

clean: export OPS=delete
clean:
	@kubectl ${OPS} -f ./manifests-all.yaml
