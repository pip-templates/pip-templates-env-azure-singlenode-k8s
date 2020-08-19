# Overview

This is a built-in module to environment [pip-templates-env-master](https://github.com/pip-templates/pip-templates-env-master). 
This module stores scripts for management azure single node kubernetes environment, also this module can be used for on-premises kubernetes environment.

# Usage

- Download this repository
- Copy *src* and *templates* folder to master template
- Add content of *.ps1.add* files to correspondent files from master template
- Add content of *config/config.k8s.json.add* to json config file from master template and set the required values

# Config parameters

Config variables description

| Variable | Default value | Description |
|----|----|---|
| env_type | on-premises | Type of environment |
| az_region | eastus | Azure region where resources will be created |
| az_resource_group | piptemplates-stage-east-us | Azure resource group name |
| az_subscription | piptemplates-DI | Azure subscription name |
| onprem_instance_username | piptemplatesadmin | On premises instance username to ssh |
| az_vm_ssh_keygen_enable | false | Switch for creation new ssh keys. If set to *true* - then new ssh keys in home directory will be created, if set to *false* you should set *ssh_private_key_path* and *az_vm_ssh_public_key_path* |
| az_vm_ssh_public_key_path | ./config/id_rsa.pub | Path to id_rsa.pub wich will be used for azure virtual machines |
| ssh_private_key_path | ./config/id_rsa | Path to id_rsa wich will be used for azure virtual machines |
| onprem_k8s_vm_vnet | piptemplates-vm-vnet | Azure virtual network name for kubernetes cluster |
| onprem_k8s_vm_resources_prefix | piptemplates-vm-k8s | Azure resources name prefix for kubernetes cluster |
| onprem_k8s_vm_size | Standard_DS1_v2 | Azure virtual machine size for kubernetes cluster |
| onprem_k8s_vm_count | 2 | Azure virtual machine count for kubernetes cluster |
| onprem_k8s_network | 10.244.0.0/16 | Azure address pool for kubernetes cluster |
| onprem_kubernetes_cni_version | 0.6.0-00 | Kubernetes cni version to install |
| onprem_kubelet_version | 1.10.13-00 | Kubelet version to install |
| onprem_kubeadm_version | 1.10.13-00 | Kubeadm version to install |
| onprem_kubectl_version | 1.10.13-00 | Kubectl version to install |

# Testing enviroment
To test created environment after installation you can use *test_instances.ps1* script:
`
./src/test_instances.ps1 ./config/test_config.json
`
You have to create test config  before running *test_instances* script.
* Test config parameters

| Variable | Default value | Description |
|----|----|---| 
| username | piptemplatesadmin | Instance username |
| ssh_private_key_path | ./config/id_rsa | Path to private key used for ssh |
| nodes_ips | ["40.121.104.231", "40.121.133.1", "40.121.133.132"] | Public IP's of testing instances |
