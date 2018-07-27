all: deploy

deploy: export OPS=create
deploy:
	-@kubectl ${OPS} -f ./namespace.yaml
	@kubectl ${OPS} -f ./rbac.yaml
	@kubectl ${OPS} -f ./default-backend.yaml
	@kubectl ${OPS} -f ./configmap.yaml
	@kubectl ${OPS} -f ./tcp-services-configmap.yaml
	@kubectl ${OPS} -f ./udp-services-configmap.yaml
	@kubectl ${OPS} -f ./service.yaml
	@kubectl ${OPS} -f ./with-rbac.yaml

clean: export OPS=delete
clean:
	@kubectl ${OPS} -f ./rbac.yaml
	@kubectl ${OPS} -f ./default-backend.yaml
	@kubectl ${OPS} -f ./configmap.yaml
	@kubectl ${OPS} -f ./tcp-services-configmap.yaml
	@kubectl ${OPS} -f ./udp-services-configmap.yaml
	@kubectl ${OPS} -f ./service.yaml
	@kubectl ${OPS} -f ./with-rbac.yaml
	@kubectl ${OPS} -f ./namespace.yaml
