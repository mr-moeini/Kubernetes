#!/bin/bash
currentuser=$(whoami)
echo "user is $currentuser"
if [ "$currentuser" != "root" ]
then
	echo "please run scipt with root"
	exit 0
else
       echo "Install kubernetes"
fi
swapon -a
sed -i 's/^\/swap/#&/g' /etc/fstab
dockersoft=("docker.io" "docker-doc" "docker-compose" "docker-compose-v2" "podman-docker" "containerd" "runc")
for pkg in ${dockersoft[@]}
do
apt remove $pkg
done
apt update
apt install ca-certificates curl -y
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install containerd.io -y
containerd config default > /etc/containerd/config.toml
sed -E -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
systemctl daemon-reload
systemctl restart containerd
modprobe br_netfilter overlay
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
apt update
apt install apt-transport-https ca-certificates curl conntrack -y
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
apt update
apt-cache policy kubeadm
apt install kubelet kubeadm kubectl -y
apt-mark hold kubelet kubeadm kubectl

echo "=================================="
echo "set mirror to clone pod componenets"
echo "=================================="
echo "50.7.85.222 k8s.io proxy.golang.org" >> /etc/hosts
kubeadm config images pull --image-repository=registry.aliyuncs.com/google_containers

