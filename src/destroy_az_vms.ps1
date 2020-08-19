#!/usr/bin/env pwsh

param
(
    [Alias("c", "Path")]
    [Parameter(Mandatory=$false, Position=0)]
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

# Set subscription
az account set -s $config.az_subscription

# Delete all k8s resources and deployment
for($i = 0; $i -lt $config.onprem_k8s_vm_count; $i++) {
    $vmName = "$($config.onprem_k8s_vm_resources_prefix)$i"
    Write-Host "Deleting virtual machine $vmName..."
    az vm delete -g $config.az_resource_group -n $vmName -y
    if ($LastExitCode -eq 0) {
        Write-Host "VM '$vmName' deleted."
    }

    Write-Host "Deleting disk..."
    $diskName = "$vmName-disk"
    az disk delete -g $config.az_resource_group -n $diskName -y
    if ($LastExitCode -eq 0) {
        Write-Host "Disk '$diskName' deleted."
    }

    Write-Host "Deleting network interface..."
    $nicName = "$vmName-nic"
    az network nic delete -g $config.az_resource_group -n $nicName
    if ($LastExitCode -eq 0) {
        Write-Host "NIC '$nicName' deleted."
    }

    Write-Host "Deleting public ip..."
    $ipName = "$vmName-ip"
    az network public-ip delete -g $config.az_resource_group -n $ipName
    if ($LastExitCode -eq 0) {
        Write-Host "PublicIp '$ipName' deleted."
    }

    Write-Host "Deleting network security group..."
    $nsgName = "$vmName-nsg"
    az network nsg delete -g $config.az_resource_group -n $nsgName
    if ($LastExitCode -eq 0) {
        Write-Host "NSG '$nsgName' deleted."
    }

    Write-Host "Deleting deployment..."
    $deploymentName = "$vmName-deployment"
    az group deployment delete -g $config.az_resource_group -n $deploymentName
    if ($LastExitCode -eq 0) {
        Write-Host "Deployment '$deploymentName' deleted."
    }
}

# Write resources
#Write-EnvResources -Path $ConfigPath -Resources $resources