
echo_title()
{
    TITLE="\e[0;44m"
    RESET="\e[0m"
    echo -e "${TITLE}$1${RESET}"
}

install_common_packages()
{
    sudo apt-get update && sudo apt-get install -y curl apt-transport-https \
		ca-certificates gnupg lsb-release

}

containerd_config()
{
    echo_title "configuring containerd"
	# load these kernel modules on boot
    echo "br_netfilter" | sudo tee /etc/modules-load.d/containerd.conf
    echo "overlay" | sudo tee -a /etc/modules-load.d/containerd.conf
	# load them now
    sudo modprobe overlay
    sudo modprobe br_netfilter

	# set some system configurations for containerd
    echo "net.bridge.bridge-nf-call-iptables = 1" | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
    echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.d/99-kubernetes-cri.conf
    echo "net.bridge.bridge-nf-call-ip6tables = 1" | sudo tee -a /etc/sysctl.d/99-kubernetes-cri.conf

    sudo sysctl --system
}

docker_install()
{
    echo_title "installing docker"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" >> /etc/apt/sources.list.d/docker.list
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io
}

containerd_install()
{
    echo_title "installing containerd"
    containerd_config

    sudo apt-get update && sudo apt-get install -y containerd
    sudo mkdir -p /etc/containerd
    containerd config default | sudo  tee /etc/containerd/config.toml
    sudo systemctl restart containerd
}

k8s_install()
{
    echo_title "installing kubernetes components"
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kuberenets.list
    sudo apt-get update && sudo apt-get install -y kubelet=1.21.0-00 kubeadm=1.21.0-00 kubectl=1.21.0-00
    sudo apt-mark hold kubelet kubeadm kubectl

}


init_cluster()
{
    echo_title "bootstrapping cluster"
    sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --kubernetes-version=1.21.0
    mkdir -p $HOME/.kube
    sudo cp -i  /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
}

calico()
{
    echo_title "applying calico network plugin"
    kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
}

setup_base()
{
    install_common_packages || exit 1
	
    containerd_config || exit 1
    containerd_install || exit 1

    k8s_install || exit 1
}

setup_master()
{

    setup_base
    init_cluster
    calico

    echo 'source <(kubectl completion bash)' >>~/.bashrc
}

