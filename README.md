# Overview
Scriptable environments introduce “infrastructure as a code” into devops practices. They allow to:

* Have controllable and verifiable environment structure
* Quickly spin up fully-functional environments in minutes
* Minimize differences between environments
* Provide developers with environment to run and test their components integrated into the final system and expand their area of responsibilities

# Syntax
All sripts have one required paramenter - *$ConfigPath*. This is the path to config, path can be absolute or relative. 

**Examples of installing privatek8s**
Relative path example:
`
./on-premises/install_k8s.ps1 ./config/onprem_config.json
`
Absolute path example:
`
~/pip-templates-env-privatek8s/on-premises/install_k8s.ps1 ~/pip-templates-env-privatek8s/config/onprem_config.json
`

**Example delete script**
`
./on-premises/destroy_k8s.ps1 ./config/onprem_config.json
`

Also you can install environment using single script:
`
./create_env.ps1 ./config/onprem_config.json
`

Delete whole environment:
`
./delete_env.ps1 ./config/onprem_config.json
`

If you have any problem with not installed tools - use `install_prereq_` script for you type of operation system.

# Project structure
| Folder | Description |
|----|----|
| Config | Config files for scripts. Store *example* configs for each environment, recomendation is not change this files with actual values, set actual values in duplicate config files without *example* in name. Also stores *resources* files, created automaticaly. | 
| Lib | Scripts with support functions like working with configs, templates etc. | 
| On-premises | Scripts related to management on premises environment | 
| Temp | Folder for storing automaticaly created temporary files. | 
| Templates | Folder for storing templates, such as kubernetes yml files, az resource manager json files, ansible playbooks, etc. | 
| Test | Script for testing created environment using ansible and comparing results to expected values. | 

# Environment types
There are 3 types of enviroment: 

* Cloud - resources created by azure resource manager, use azure kubernetes services (AKS) for deploying kubernetes cluster, etc.
* On premises - use existing instances and via ansible install kubernetes cluster using kubeadm. Also created install azure virtual machines script to simulate existing instances.
* Local - use minikube to install kubernetes cluster. 


### On premises environment

* On premises config parameters

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
To test created environment after installation you can use script in *test* folder:
`
./test/test_instances.ps1 ./config/test_config.json
`
You have to create test config  before running *test_instances* script.
* Test config parameters

| Variable | Default value | Description |
|----|----|---| 
| username | piptemplatesadmin | Instance username |
| ssh_private_key_path | ./config/id_rsa | Path to private key used for ssh |
| nodes_ips | ["40.121.104.231", "40.121.133.1", "40.121.133.132"] | Public IP's of testing instances |
