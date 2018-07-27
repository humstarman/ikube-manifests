NAME=registry
IP={{.cmd.ip}}
PORT={{.cmd.port}}
CLUSTER_IP={{.cmd.cluster.ip}}
CLUSTER_IP_PORT={{.cmd.cluster.ip.port}}
REGISTRY_PATH=/var/lib/docker/registry
LOCAL_REGISTRY=${CLUSTER_IP}:${CLUSTER_IP_PORT}
TMP=tmp

all: run deploy 

link: deploy

check:
	@./scripts/mk-ansible-hosts.sh -i ${IP} -g ${TMP} -o
	@ansible ${TMP} -m ping 
	@ansible ${TMP} -m script -a ./check-docker.sh 
	@./scripts/rm-ansible-group.sh -g ${TMP}

cp:
	@yes | cp ./manifest/service.yaml.sed ./manifest/service.yaml
	@yes | cp ./manifest/endpoint.yaml.sed ./manifest/endpoint.yaml

sed:
	@sed -i s?"{{.name}}"?"${NAME}"?g ./manifest/service.yaml
	@sed -i s?"{{.port}}"?"${PORT}"?g ./manifest/service.yaml
	@sed -i s?"{{.cluster.ip.port}}"?"${CLUSTER_IP_PORT}"?g ./manifest/service.yaml
	@sed -i s?"{{.cluster.ip}}"?"${CLUSTER_IP}"?g ./manifest/service.yaml
	@sed -i s?"{{.name}}"?"${NAME}"?g ./manifest/endpoint.yaml
	@sed -i s?"{{.ip}}"?"${IP}"?g ./manifest/endpoint.yaml
	@sed -i s?"{{.port}}"?"${PORT}"?g ./manifest/endpoint.yaml

deploy: cp sed
	@kubectl create -f ./manifest/service.yaml
	@kubectl create -f ./manifest/endpoint.yaml

run: check
	@./scripts/mk-ansible-hosts.sh -i ${IP} -g ${TMP} -o
	-@ansible ${TMP} -m shell -a "mkdir -p ${REGISTRY_PATH}"
	-@ansible ${TMP} -m shell -a "docker run -d -p ${PORT}:5000 --restart=always --name ${NAME} -v ${REGISTRY_PATH}:/var/lib/registry registry" 
	@./scripts/rm-ansible-group.sh -g ${TMP}

rm:
	@./scripts/mk-ansible-hosts.sh -i ${IP} -g ${TMP} -o
	@ansible ${TMP} -m shell -a "docker stop ${NAME} && docker rm ${NAME}"
	@./scripts/rm-ansible-group.sh -g ${TMP}

del:
	@kubectl delete -f ./manifest/service.yaml
	@kubectl delete -f ./manifest/endpoint.yaml
	@rm -f ./manifest/service.yaml
	@rm -f ./manifest/endpoint.yaml

clean: rm del

.PHONY : test
test:
	@curl http://${LOCAL_REGISTRY}/v2/_catalog

test1:
	@docker pull busybox
	@docker tag busybox ${LOCAL_REGISTRY}/busybox
	@docker push ${LOCAL_REGISTRY}/busybox

clean-test:
	@kubectl delete -f ./test/test-claim.yaml -f ./test/test-pod.yaml
