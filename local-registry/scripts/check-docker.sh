#!/bin/bash
FLAG=$(systemctl status docker.service &> /dev/null; echo $?)
if [[ $FLAG != 0 ]];then
  echo "$(date) - $0 - [WARN] - no docker service found."
  echo " - will install docker."
  INSTALL=true
fi
# 0 set env
DOCKER=/var/lib/docker
# 1 check
[ -d "$DOCKER" ] || mkdir -p $DOCKER
if [ -x "$(command -v yum)" ]; then
  yum makecache
  yum install -y yum-utils \
    device-mapper-persistent-data \
    lvm2
  if $INSTALL; then
    yum-config-manager \
      --add-repo \
      https://download.docker.com/linux/centos/docker-ce.repo
    yum install -y docker-ce
  fi
  yum install -y conntrack
  FIREWALL="firewalld"
elif [ -x "$(command -v apt-get)" ]; then
  apt-get update
  apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
  if $INSTALL; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository \
     "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) \
     stable"
    apt-get update
    apt-get install -y docker-ce
  fi
  apt-get install -y conntrack
  FIREWALL="ufw"
else
  echo "$(date) - $0 - [ERROR] - unknown Distributor ID."
  exit 1
fi
systemctl stop $FIREWALL
systemctl disable $FIREWALL
iptables -P FORWARD ACCEPT
iptables -F && iptables -X && iptables -F -t nat && iptables -X -t nat
# mk docker-iptables.service
#cp docker-iptables.service /etc/systemd/system
cat > /etc/systemd/system/docker-iptables.service <<"EOF"
[Unit]
Description=Make Iptables Rules for Docker

[Service]
Type=oneshot
ExecStart=/bin/sh \
          -c \
          "sleep 60 && /sbin/iptables -P FORWARD ACCEPT"

[Install]
WantedBy=multi-user.target
EOF
[ -d /etc/docker ] || mkdir -p /etc/docker
cat > /etc/docker/daemon.json << EOF
{
  "data-root": "$DOCKER",
  "registry-mirrors" : [
    "https://nmp34hlf.mirror.aliyuncs.com",
    "https://mirror.ccs.tencentyun.com"
  ],
  "insecure-registries" : [
    "192.168.0.0/16",
    "172.0.0.0/8",
    "10.0.0.0/8"
  ],
  "debug" : true,
  "experimental" : true,
  "max-concurrent-downloads" : 10
}
EOF
systemctl daemon-reload
systemctl enable docker
systemctl restart docker
systemctl enable docker-iptables.service
