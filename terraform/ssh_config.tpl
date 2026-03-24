Host bastion
    HostName ${bastion_ip}

Host nat-vm
    ProxyJump bastion

Host gitlab
    ProxyJump bastion

Host harbor
    ProxyJump bastion

Host k8s-master-*
    ProxyJump bastion

Host k8s-ingress-*
    ProxyJump bastion

Host k8s-node-*
    ProxyJump bastion

Host *
    User ubuntu
    ForwardAgent yes
    ControlMaster auto
    ControlPersist 5
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    IdentityFile ${ssh_private_key_path}
