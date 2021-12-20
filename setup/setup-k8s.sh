
set -e
install_common_packages()
{
	sudo apt-get update && sudo apt-get install -y curl apt-transport-https \
		ca-certificates gnupg lsb-release

}

containerd_config()
{
	# load these kernel modules on boot
	echo "br_netfilter" | sudo tee /etc/modules-load.d/containerd.conf
	echo "overlay" | sudo tee /etc/modules-load.d/containerd.conf
	# load them now
	sudo modprobe overlay
	sudo modprobe br_netfilter

	# set some system configurations for containerd
	echo "net.bridge.bridge-nf-call-iptables = 1" | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
	echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
	echo "net.bridge.bridge-nf-call-ip6tables = 1" | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf

	sudo sysctl --system
}

docker_install()
{
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" >> /etc/apt/sources.list.d/docker.list
	sudo apt-get update
	sudo apt-get install docker-ce docker-ce-cli containerd.io
}

containerd_install()
{
	containerd_config

	sudo apt-get update && sudo apt-get install -y containerd
	sudo mkdir -p /etc/containerd
	containerd config default | sudo  tee /etc/containerd/config.toml
	systemctl restart containerd
}

k8s_install()
{
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
	echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >> /etc/apt/sources.list.d/kuberenets.list
	apt-get update && apt-get install -y kubelet=1.21.0-00 kubeadm=1.21.0-00 kubectl=1.21.0-00
	apt-mark hold kubelet kubeadm kubectl

}




