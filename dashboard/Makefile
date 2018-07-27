COMPONENT="dashborad"

all: deploy

deploy: export OPS=create
deploy:
	@kubectl ${OPS} -f ./${COMPONENT}-rbac.yaml
	@kubectl ${OPS} -f ./${COMPONENT}-configmap.yaml
	@kubectl ${OPS} -f ./${COMPONENT}-secret.yaml
	@kubectl ${OPS} -f ./${COMPONENT}-service.yaml
	@kubectl ${OPS} -f ./${COMPONENT}-controller.yaml

clean: export OPS=delete
clean:
	@kubectl ${OPS}  -f ./${COMPONENT}-rbac.yaml
	@kubectl ${OPS} -f ./${COMPONENT}-configmap.yaml
	@kubectl ${OPS} -f ./${COMPONENT}-secret.yaml
	@kubectl ${OPS} -f ./${COMPONENT}-service.yaml
	@kubectl ${OPS} -f ./${COMPONENT}-controller.yaml
