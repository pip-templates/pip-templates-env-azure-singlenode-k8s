#!/usr/bin/env pwsh

param
(
    [Alias("c", "Path")]
    [Parameter(Mandatory=$false, Position=0)]
    [string] $ConfigPath
)

$ErrorActionPreference = "Stop"

# Load support functions
$rootPath = $PSScriptRoot
if ($rootPath -eq "") { $rootPath = "." }
. "$($rootPath)/lib/include.ps1"
$rootPath = $PSScriptRoot
if ($rootPath -eq "") { $rootPath = "." }

# Read config and resources
$config = Read-EnvConfig -Path $ConfigPath
$resources = Read-EnvResources -Path $ConfigPath

switch ($config.env_type) {
    "on-premises" { 
        . "$($rootPath)/on-premises/install_az_vms.ps1" $ConfigPath
        . "$($rootPath)/on-premises/install_k8s.ps1" $ConfigPath
        . "$($rootPath)/on-premises/install_platform_services.ps1" $ConfigPath
     }
     Default {
         Write-Host "Platform type not specified in config file. Please add 'env_type' to config."
     }
}
