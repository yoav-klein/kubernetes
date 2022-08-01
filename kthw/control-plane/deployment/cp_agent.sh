#!/bin/bash

cmd=$1

cp_home=~/.k8s/control-plane
k8s_version=v1.24.3



## Logging functions

GREEN="\e[32;1m"
RED="\e[31;1m"
RESET="\e[0m"
TITLE="\e[0;44m"
YELLOW="\e[33;1m"

echo_title() {
    echo -e "${TITLE} $1 ${RESET}"
}

log() {
    log_level=$1; shift
    message=$1
    if [ -z "$message" ]; then
        echo "Usage: log <message>"
        return
    fi
    echo "$log_level: cp_agent:${FUNCNAME[2]}:${BASH_LINENO[2]} $message"
}

log_warning() {
    log WARNING "$1"
}

log_info() {
    log INFO "$1"
}


log_debug() {
    log DEBUG "$1"
}

log_error() {
    log ERROR "$1"
}

log_success() {
    echo -e "${GREEN}=== $2 $RESET"
}

#####################################################################

### internal functions for installing/uninstalling services
_delete_configurations() {
    rm -rf /etc/kubernetes /var/lib/kubernetes || { log_error "failed to delete directories"; return 1; }
    
}

_delete_service_files() {
    local sc=0
    [ -f /etc/systemd/system/kube-apiserver.service ] && { rm /etc/systemd/system/kube-apiserver.service || { log_error "failed to remove service file"; sc=1; } }
    [ -f /etc/systemd/system/kube-scheduler.service ] && { rm /etc/systemd/system/kube-scheduler.service || { log_error "failed to remove service file"; sc=1; } }
    [ -f /etc/systemd/system/kube-controller-manager.service ] && { rm /etc/systemd/system/kube-controller-manager.service || { log_error "failed to remove service file"; sc=1; } }
    
    return $sc
}

_create_directories() {
    mkdir -p /etc/kubernetes/config || { log_error "failed to create /etc/kubernetes/config"; return 1; }
    mkdir -p /var/lib/kubernetes || { rm -rf /etc/kubernetes/config; log_error "failed to create \
        /var/lib/kubernetes"; return 1; }

    log_debug "created directories for services"
}


_install_configurations() {
    _create_directories || return 1
    # run a subshell so that we can use -e without exiting the script
    # if one copy fails, delete all
    (
    set -e
    trap _delete_configurations ERR
    cp ${cp_home}/ca.crt /var/lib/kubernetes
    cp ${cp_home}/ca.key /var/lib/kubernetes
    cp ${cp_home}/kube-apiserver.crt /var/lib/kubernetes
    cp ${cp_home}/kube-apiserver.key /var/lib/kubernetes
    cp ${cp_home}/apiserver-etcd-client.crt /var/lib/kubernetes
    cp ${cp_home}/apiserver-etcd-client.key /var/lib/kubernetes
    cp ${cp_home}/apiserver-kubelet-client.crt /var/lib/kubernetes
    cp ${cp_home}/apiserver-kubelet-client.key /var/lib/kubernetes
    cp ${cp_home}/service-accounts.crt /var/lib/kubernetes
    cp ${cp_home}/service-accounts.key /var/lib/kubernetes
    cp ${cp_home}/encryption-config.yaml /var/lib/kubernetes
    cp ${cp_home}/kube-scheduler.kubeconfig /var/lib/kubernetes
    cp ${cp_home}/kube-scheduler.yaml /etc/kubernetes/config
    cp ${cp_home}/kube-controller-manager.kubeconfig /var/lib/kubernetes
    )
}

_install_service_files() {(
    set -e
    trap _delete_service_files ERR
    cp ${cp_home}/kube-apiserver.service /etc/systemd/system
    cp ${cp_home}/kube-controller-manager.service /etc/systemd/system
    cp ${cp_home}/kube-scheduler.service /etc/systemd/system
    
)}

_enable_services() {
    systemctl daemon-reload || { log_error "failed to daemon-reload"; return 1; }
    
    # if one of  them fails to enable, remove the services and reload daemon
    if ! systemctl enable kube-apiserver kube-scheduler kube-controller-manager; then
        rm /etc/systemd/system/kube-* > /dev/null 2>&1
        systemctl daemon-reload
        log_error "failed to enable services"
        return 1
    fi
    
    log_debug "enabled control plane services"

}



################### commands functions ###########################


##################
#
#  install the control plane binaries
#   including kube-apiserver, kube-controller-manager,
#   and kube-scheduler
#
################

install_binaries() {
    if [ "$(_check_binaries_installed)" = "true" ]; then
        log_warning "binaries already installed"
        return 2
    fi
    
    echo_title "installing binaries"

    local kube_scheduler_url="https://dl.k8s.io/${k8s_version}/bin/linux/amd64/kube-scheduler"
    local kube_apiserver_url="https://dl.k8s.io/${k8s_version}/bin/linux/amd64/kube-apiserver"
    local kube_controller_manager_url="https://dl.k8s.io/${k8s_version}/bin/linux/amd64/kube-controller-manager"
    local kubectl_url="https://dl.k8s.io/${k8s_version}/bin/linux/amd64/kubectl"
    
    curl -sSfL $kube_scheduler_url -o /tmp/kube-scheduler || { log_error "failed downloading kube-scheduler"; return 1 ; }
    curl -sSfL $kube_apiserver_url -o /tmp/kube-apiserver || { log_error "failed downloading kube-apiserver"; return 1 ; } 
    curl -sSfL $kube_controller_manager_url -o /tmp/kube-controller-manager || \
        { log_error "failed downloading kube-controller-manager"; return 1 ; }

    chmod +x /tmp/kube-scheduler /tmp/kube-apiserver /tmp/kube-controller-manager

    mv /tmp/kube-scheduler /tmp/kube-apiserver /tmp/kube-controller-manager \
        /usr/local/bin || { log_error "failed moving binaries to /usr/local/bin"; return 1 ; }

    log_info "installed control plane binaries"
}

################
#
#   uninstall the control plane binaries
#
#################

uninstall_binaries() {
    if [ "$(_check_services_loaded)" = "true" ]; then
        log_warning "services are loaded, unload them first"
        return 3
    fi
    if [ "$(_check_binaries_installed)" = "false" ]; then
        log_warning "binaries already uninstalled"
        return 2
    fi
    
    echo_title "uninstalling binaries"
    rm /usr/local/bin/kube-* || { log_error "failed to remove binaries"; return 1; } 
    log_info "uninstalled control plane binaries"
}

###################
#
#   do all the preparations for installing
#   the control plane services, i.e. creating
#   directories, copying certifiates, etc.
#
###################

install_services() {
    if [ "$(_check_services_loaded)" = "true" ]; then
        log_warning "services already loaded"
        return 2
    fi
    if [ "$(_check_binaries_installed)" = "false" ]; then
        log_warning "binaries uninstalled, install them first"
        return 3
    fi 
    
    echo_title "installing services"

    _install_configurations || {  log_error "failed installing certificates and kubeonfigs"; return 1; } 
    _install_service_files || { _delete_configurations; log_error "failed intsalling service files"; return 1; }
    _enable_services || { _delete_configurations; _delete_service_files; log_error "failed to enable services"; return 1; }

    log_info "installed services"

}

####################
#
#   undo the install_services function
#
####################

uninstall_services() {
    if [ "$(_check_services_loaded)" = "false" ]; then
         log_warning "services already uninstalled"
         return 2
    fi
    if [ "$(_check_services_active)" = "true" ]; then
         log_warning "services are active, stop them first";
         return 3
    fi
    
    echo_title "uninstalling services"

    # we don't need to disable the services, just delete and they'll automatically be disabled
    local sc=0
    { _delete_service_files && systemctl daemon-reload; } || { log_error "failed to remove services"; sc=1; }
    _delete_configurations || { log_error "failed to delete configuarions"; sc=1; }
    
    log_info "uninstalled services"
    return $sc
}


#######################
#
#   start the control plane services
#
#########################

start_services() {
    if [ $(_check_services_active) = "true" ]; then
        log_warning "service already running"
        return 2
    fi
    if [ $(_check_services_loaded) = "false" ]; then
        log_warning "service is not loaded, load service first"
        return 3
    fi
    if [ $(_check_binaries_installed) = "false" ]; then
        log_warning "etcd binaries uninstalled, install first"
        return 3
    fi


    # if one fails to start, the others are started, but the exit code is non-zero
    systemctl start kube-apiserver kube-scheduler kube-controller-manager || { log_error "failed to start services"; return 1;  }

    log_info "started control plane services"
}

#################
#   
#   stop the contorl plane services
#
###################

stop_services() {
    # if one fails to stop, the others are stopped, but exit code is non-zero
     if [ "$(_check_services_active)" = "false" ]; then
        log_warning "service already stopped"
        return 2
    fi

    systemctl stop kube-apiserver kube-scheduler kube-controller-manager || { log_error "failed to stop services"; return 1; }

    log_info "stopped control plane services"
}



############### status functions


status() {
    json='{"installed": true, "loaded": true}'
    local is_installed=$(_check_binaries_installed)
    local is_loaded=$(_check_services_loaded)
    local is_landed=$(_check_landed)
    local is_active=$(_check_services_active)
    echo $json | jq ".installed |= $is_installed | .loaded |= $is_loaded | .active |= $is_active | .landed |= $is_landed"
}


####
#
# check services active
# 
# true if all services are active

_check_services_active() {
    systemctl is-active kube-apiserver > /dev/null 2>&1 && \
    systemctl is-active kube-scheduler > /dev/null 2>&1 && \
    systemctl is-active kube-controller-manager > /dev/null 2>&1 && echo "true" || echo "false"
}



#### 
#
#   check service loaded
#   
#   true if: 
#       - directories exist (making an assumption that the files are there)
#       - all services enabled: kube-apiserver, kube-scheduler, kube-controller-manager

_check_services_loaded() {
    test -d /etc/kubernetes && test -d /var/lib/kubernetes && \
       systemctl is-enabled kube-apiserver > /dev/null 2>&1 && \
       systemctl is-enabled kube-scheduler > /dev/null 2>&1  && \
       systemctl is-enabled kube-controller-manager > /dev/null 2>&1 && echo "true" || echo "false"
}

_check_binaries_installed() {
    test -f /usr/local/bin/kube-apiserver && test -f /usr/local/bin/kube-controller-manager && \
        test -f /usr/local/bin/kube-scheduler && echo "true" || echo "false"
     
}

_check_landed() {    
    ### file_list - a global variable that holds the file list necessary for the control plane
    local file_list=(
    ca.crt \
    ca.key \
    kube-apiserver.crt \
    kube-apiserver.key \
    apiserver-etcd-client.crt \
    apiserver-etcd-client.key \
    apiserver-kubelet-client.crt \
    apiserver-kubelet-client.key \
    service-accounts.crt \
    service-accounts.key \
    encryption-config.yaml \
    kube-scheduler.kubeconfig \
    kube-scheduler.yaml \
    kube-controller-manager.kubeconfig
    )
    
    for file in ${file_list[@]}; do
        [ ! -f "$cp_home/$file" ]  && { echo "false"; return ;}
    done

    echo "true"
}

usage() {
    echo "Usage:"
    echo "cp_agent.sh <command>"
    echo ""
    echo "Commands:"
    echo "install_binaries   - Install the control plane binaries"
    echo "uninstall_binaries - Uninstall the control plane binaries"
    echo "install_services   - Install the control plane services"
    echo "uninstall_services - Uninstal the control plane services"
    echo "start              - Start the control plane"
    echo "stop               - Stop the control plane"
    echo "test               - Test if control plane is running"
    echo "status             - Get the control plane status of the node"

}

### verify running with sudo

user_id=`id -u`
if [ $user_id -ne 0 ]; then
    echo "Must run as sudo"
    exit 1
fi


case $cmd in
    install_binaries) install_binaries;;
    uninstall_binaries) uninstall_binaries;;
    install_services) install_services;;
    uninstall_services) uninstall_services;;
    start) start_services;; 
    stop) stop_services;;
    test) test_control_plane;;
    status) status;;
    *) usage;;
esac


### TODO:
#
#   * logical problem - is the status functions is_active and is_loaded
#        there's a probelm - it returns true only if all are true
#        so the stop_services function won't do anything in case only part of them are active
#
#


## LIMITATIONS
#
#   1. if some services are loaded, check_services_loaded will return false,
#      so that uninstall_services will not do anything
#


# 
#   TEST
#   1. one service file is corrupt, see behaviour
#
#