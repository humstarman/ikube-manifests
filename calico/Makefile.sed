REGISTRY_PREFIX="lowyard/calico-"
TAG=v3.1.3

NODE_IMAGE=${REGISTRY_PREFIX}node
CNI_IMAGE=${REGISTRY_PREFIX}cni
KUBE_CONTROLLERS_IMAGE=${REGISTRY_PREFIX}kube-controllers
SSL=/etc/kubernetes/ssl
ETCD_KEY_PEM=`cat ${SSL}/etcd-key.pem | base64 | tr -d '\n'`
ETCD_PEM=`cat ${SSL}/etcd.pem | base64 | tr -d '\n'`
CA_PEM=`cat ${SSL}/ca.pem | base64 | tr -d '\n'`
CLUSTER_CIDR="{{.env.cluster.cidr}}"

all: deploy 

cp:
	@find ./manifest -type f -name "*.sed" | sed s?".sed"?""?g | xargs -I {} cp {}.sed {}

sed:
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.tag}}"?"${TAG}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.node.image}}"?"${NODE_IMAGE}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.cni.image}}"?"${CNI_IMAGE}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.kube-controllers.image}}"?"${KUBE_CONTROLLERS_IMAGE}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.etcd.endpoints}}"?"${ETCD_ENDPOINTS}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.etcd-key.pem}}"?"${ETCD_KEY_PEM}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.etcd.pem}}"?"${ETCD_PEM}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.ca.pem}}"?"${CA_PEM}"?g
	@find ./manifest -type f -name "*.yaml" | xargs sed -i s?"{{.cluster.cidr}}"?"${CLUSTER_CIDR}"?g

deploy: cp sed
	@kubectl create -f ./manifest/rbac.yaml
	@kubectl create -f ./manifest/calico.yaml

clean:
	@kubectl delete -f ./manifest/.
	@find ./manifest -type f -name "*.yaml" | xargs rm -f
