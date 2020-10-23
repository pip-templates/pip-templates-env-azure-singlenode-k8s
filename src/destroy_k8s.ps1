#!/usr/bin/env pwsh

param
(
    [Alias("c", "Path")]
    [Parameter(Mandatory=$true, Position=0)]
    [string] $ConfigPath,
    [Alias("p")]
    [Parameter(Mandatory=$false, Position=1)]
    [string] $Prefix
)

$ErrorActionPreference = "Stop"

# Load support functions
$path = $PSScriptRoot
if ($path -eq "") { $path = "." }
. "$($path)/../lib/include.ps1"
$path = $PSScriptRoot
if ($path -eq "") { $path = "." }

# Read config and resources
$config = Read-EnvConfig -Path $ConfigPath
$resources = Read-EnvResources -Path $ConfigPath

# Prepare hosts file
$ansible_inventory = @("[masters]")
$ansible_inventory += "master ansible_host=$($resources.k8s_master_ip) ansible_ssh_user=$($config.onprem_instance_username) ansible_ssh_private_key_file=$($config.ssh_private_key_path)"
$ansible_inventory += "`r`n[workers]"
$i = 0
foreach ($node in $resources.k8s_worker_ips) {
    $ansible_inventory += "worker$i ansible_host=$node ansible_ssh_user=$($config.onprem_instance_username) ansible_ssh_private_key_file=$($config.ssh_private_key_path)"
    $i++
}

Set-Content -Path "$path/../temp/onprem_k8s_ansible_hosts" -Value $ansible_inventory

# Whitelist nodes
Build-EnvTemplate -InputPath "$($path)/../templates/ssh_keyscan_playbook.yml" -OutputPath "$($path)/../temp/ssh_keyscan_playbook.yml" -Params1 $config -Params2 $resources
ansible-playbook -i "$path/../temp/onprem_k8s_ansible_hosts" "$path/../temp/ssh_keyscan_playbook.yml"

# Destroy k8s cluster
Build-EnvTemplate -InputPath "$($path)/../templates/onprem_k8s_uninstall_playbook.yml" -OutputPath "$($path)/../temp/onprem_k8s_uninstall_playbook.yml" -Params1 $config -Params2 $resources
ansible-playbook -i "$path/../temp/onprem_k8s_ansible_hosts" "$path/../temp/onprem_k8s_uninstall_playbook.yml"
