#!/bin/bash

containerd_version=2.1.4
arch=amd64
cni_version=1.7.1
kube_version=1.33

#
## install runc and containerd

function system_config() {
    sudo swapoff -a # this is temp, to do it permanent, see in the docs
    cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

    # Apply sysctl params without reboot
    sudo sysctl --system

}

function install_kube_components() {
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl gpg
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.${kube_version}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${kube_version}/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
    sudo systemctl enable --now kubelet
}

function install_containerd() {
    containerd_url="https://github.com/containerd/containerd/releases/download/v${containerd_version}/containerd-${containerd_version}-linux-${arch}.tar.gz"
    echo $containerd_url
    curl -o containerd.tar.gz -L $containerd_url

    sudo tar xf containerd.tar.gz -C /usr/local/

    sudo mkdir -p /usr/local/lib/systemd/system
    sudo cp containerd.service /usr/local/lib/systemd/system/containerd.service
    sudo systemctl daemon-reload
    sudo systemctl enable --now containerd

}

function install_runc() {
    runc_url="https://github.com/opencontainers/runc/releases/download/v1.3.0/runc.${arch}"
    curl -o runc -L $runc_url
    sudo install -m 755 runc /usr/local/sbin/runc
}

function install_cni() {
    cni_url="https://github.com/containernetworking/plugins/releases/download/v${cni_version}/cni-plugins-linux-amd64-v${cni_version}.tgz"
    sudo mkdir -p /opt/cni/bin
    curl -o cni.tar.gz -L $cni_url
    sudo tar Cxzvf /opt/cni/bin cni.tar.gz
}

function init_cluster() {
    #sudo kubeadm init --pod-network-cidr=182.168.0.0/16
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

}

#install_containerd
#install_runc
#install_cni

install_kube_components

init_cluster
