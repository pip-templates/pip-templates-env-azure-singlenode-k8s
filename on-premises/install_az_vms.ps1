#!/usr/bin/env pwsh

param
(
    [Alias("c", "Path")]
    [Parameter(Mandatory = $false, Position = 0)]
    [string] $ConfigPath
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

# Set azure subscription and login if needed
try {
    az account set -s $config.az_subscription
    
    if ($lastExitCode -eq 1) {
        throw "Cann't set account subscription"
    }
}
catch {
    # Make interactive az login
    az login

    az account set -s $config.az_subscription
}

# Create resource group if not exists
if (![System.Convert]::ToBoolean($(az group exists -n $config.az_resource_group))) {
    Write-Host "Resource group with name '$($config.az_resource_group)' could not be found. Creating new resource group..."
    $out = az group create --name $config.az_resource_group `
        --location $config.az_region | Out-String | ConvertFrom-Json | ConvertObjectToHashtable

    if ($out -eq $null) {
        Write-Host "Can't create resource group '$($config.az_resource_group)'"
        return
    }
    else {
        Write-Host "Resource group '$($config.az_resource_group)' created."
    }
}
else {
    Write-Host "Using existing resource group '$($config.az_resource_group)'."
}

# Create or get ssh key
if ($config.ssh_keygen_enable) {
    Write-Host "Generating ssh key pair..."
    ssh-keygen -t rsa -b 2048
}

# Get ssh
if (!($config.az_vm_ssh_public_key_path -eq "")) {
    $sshPath = $config.az_vm_ssh_public_key_path;
}
else {
    $sshPath = "$HOME\.ssh\id_rsa.pub";
}

$sshPubKey = Get-Content -Path $sshPath
$sshPubKey = $sshPubKey -replace "`t|`n|`r", ""

$resources.k8s_worker_ips = @()
$resources.az_vm_public_key = $sshPubKey

# Create k8s instances
for ($i = 0; $i -lt $config.onprem_k8s_vm_count; $i++) {
    # Create azure resources
    Write-Host "Creating virtual machine #$i for k8s cluster, network security group and public ip..."

    # incremental number for az resource name. and set variables used in az_vm_params template
    $resources.az_vm_number = $i
    $resources.az_vm_resources_prefix = $config.onprem_k8s_vm_resources_prefix
    $resources.az_vm_vnet = $config.onprem_k8s_vm_vnet
    $resources.az_vm_size = $config.onprem_k8s_vm_size

    Build-EnvTemplate -InputPath "$($path)/../templates/az_vm_params.json" `
        -OutputPath "$($path)/../temp/az_vm_params$i.json" -Params1 $config -Params2 $resources

    $deploymentName = "$($resources.az_vm_resources_prefix)$i-deployment"
    $out = az group deployment create --name $deploymentName `
        --resource-group $config.az_resource_group `
        --template-file "$($path)/../templates/az_vm_deploy.json" `
        --parameters "$($path)/../temp/az_vm_params$i.json" | Out-String | ConvertFrom-Json | ConvertObjectToHashtable

    if ($out -eq $null) {
        Write-Host "Can't deploy VM."
        return
    }
    else {
        if ($LastExitCode -eq 0) {
            Write-Host "VM deployment '$($out.name)' has been successfully deployed."
        }
    }

    # Write first vm as master and all others and workers nodes
    if ($i -eq 0) {
        $out = az network public-ip show -g $config.az_resource_group `
            -n "$($resources.az_vm_resources_prefix)$i-ip" | Out-String | ConvertFrom-Json | ConvertObjectToHashtable

        $resources.k8s_master_ip = $out.ipAddress

        $out = az network nic show -g $config.az_resource_group `
            -n "$($resources.az_vm_resources_prefix)$i-nic" | Out-String | ConvertFrom-Json | ConvertObjectToHashtable

        $resources.k8s_master_inet_addr = $out.ipConfigurations[0].privateIpAddress
    }
    else {
        $out = az network public-ip show -g $config.az_resource_group `
            -n "$($resources.az_vm_resources_prefix)$i-ip" | Out-String | ConvertFrom-Json | ConvertObjectToHashtable

        $resources.k8s_worker_ips += $out.ipAddress
    }

    # # Open teamcity server port
    # Write-Host "Opening port 8111(teamcity server) on vm #$i..."
    # $out = az network nsg rule create -g $config.az_resource_group `
    #     --nsg-name "$($resources.az_vm_resources_prefix)$i-nsg" `
    #     --name "teamcity" `
    #     --priority 101 `
    #     --destination-port-ranges 8111 

    # if ($out -ne $null) {
    #     Write-Host "NSG rule for vm #$i to access port 8111 created."
    # }
}

# Write resources
Write-EnvResources -Path $ConfigPath -Resources $resources
