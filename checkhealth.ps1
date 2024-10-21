# Create a temporary directory
$tempDir = New-Item -Path (Join-Path -Path $env:TEMP -ChildPath "ADSecurityCheckTemp") -ItemType Directory -Force

# Download the PowerShell script to the temporary directory
$scriptPath = Join-Path -Path $tempDir.FullName -ChildPath "AD_SecurityCheck.ps1"
((Invoke-WebRequest -Uri "https://raw.githubusercontent.com/thetechsamurai/ADHealth/refs/heads/main/AD_SecurityCheck.ps1" -UseBasicParsing -OutFile $scriptPath).Content)

# Get the FQDN of the Domain Controller
$connectorDC = (Get-ADDomainController -Identity $env:COMPUTERNAME).Hostname

# Create the config.ini content
$configContent = @"
[Config]
ConnectorDC=$connectorDC
UserLogonAge=180
UserPasswordAge=180
"@

# Define the path for the config.ini file
$configFilePath = Join-Path -Path $tempDir.FullName -ChildPath "config.ini"

# Write the config content to the config.ini file
$configContent | Out-File -FilePath $configFilePath -Encoding UTF8

# Output the paths for confirmation
Write-Output "Script downloaded to: $scriptPath"
Write-Output "Config file created at: $configFilePath"

# Optionally, execute the downloaded script
& $scriptPath