<#
.SYNOPSIS
    Launcher for the AD Health Report script.
    Downloads AD_HealthReport.ps1 from GitHub and executes it on the local machine.

.DESCRIPTION
    Run this script on any Domain Controller (or domain-joined machine with RSAT).
    It will:
      1. Create a temporary directory
      2. Download AD_HealthReport.ps1 from the thetechsamurai GitHub repo
      3. Execute the downloaded script

    No config file required — the main script auto-detects the Domain Controller.

.NOTES
    Powered by The Tech Samurai
    Requires: ActiveDirectory module (RSAT), PowerShell 5.1+
    Must be run as Administrator on a Domain Controller or domain-joined machine.

.EXAMPLE
    # Run with default Full Inventory (Option 1):
    .\Launch_ADHealthReport.ps1

    # Run with a custom job timeout (minutes):
    .\Launch_ADHealthReport.ps1 -JobTimeout 120
#>

param (
    [int]$JobTimeout     = 180,
    [int]$UserLogonAge   = 180,   # Days since last logon before considered inactive
    [int]$UserPasswordAge = 180   # Days since last password set before considered stale
)

#----------------------------------------------------------
# Verify running as Administrator
#----------------------------------------------------------
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host '[ERROR] This script must be run as Administrator.' -ForegroundColor Red
    exit 1
}

#----------------------------------------------------------
# Verify ActiveDirectory module is available
#----------------------------------------------------------
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Host '[ERROR] The ActiveDirectory PowerShell module is not installed.' -ForegroundColor Red
    Write-Host '        Install RSAT: Install-WindowsFeature RSAT-AD-PowerShell' -ForegroundColor Yellow
    exit 1
}

#----------------------------------------------------------
# Download main script from GitHub
#----------------------------------------------------------
$ScriptUrl    = 'https://raw.githubusercontent.com/thetechsamurai/ADHealth/refs/heads/main/AD_HealthReport.ps1'
$TempDir      = New-Item -Path (Join-Path $env:TEMP 'ADHealthReportTemp') -ItemType Directory -Force
$ScriptPath   = Join-Path $TempDir.FullName 'AD_HealthReport.ps1'

Write-Host 'Downloading AD Health Report script...' -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $ScriptUrl -UseBasicParsing -OutFile $ScriptPath -ErrorAction Stop
    Write-Host "Script downloaded to: $ScriptPath" -ForegroundColor Green
}
catch {
    Write-Host "[ERROR] Failed to download the script: $_" -ForegroundColor Red
    exit 1
}

#----------------------------------------------------------
# Execute the main script
#----------------------------------------------------------
Write-Host 'Launching AD Health Report...' -ForegroundColor Cyan
& $ScriptPath -JobTimeout $JobTimeout -UserLogonAge $UserLogonAge -UserPasswordAge $UserPasswordAge
