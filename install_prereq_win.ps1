#!/usr/bin/env pwsh

Write-Host "Remember to run this script as Administrator!"

Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Azure Cli
choco install --yes azure-cli
