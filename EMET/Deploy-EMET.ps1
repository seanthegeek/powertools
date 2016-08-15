<#
.SYNOPSIS
Installs/configures Microsoft's Enhanced Mitigation Experience Toolkit (EMET)

Author: Sean Whalen (@SeanTheGeek - Sean@SeanPWhalen.com)
Version: 1.0.0
Required Dependencies: None
Optional Dependencies: None

Copyright 2016 Sean Whalen

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

.LINK
https://github.com/seanthegeek/powertools/EMET
#>


[CmdletBinding()] param(
  [Parameter(Position = 0)]
  [string]$Command = ""
)

$ErrorActionPreference = "Stop"


$DotNETInstallerPath = "NDP462-KB3151800-x86-x64-AllOS-ENU.exe"

$MyPath = [string]$(Get-Location)
$EMETPath = ${env:ProgramFiles(x86)} + "\EMET 5.5"

function printHelp {

  Write-Host @"
Installs/configures Microsoft's Enhanced Mitigation Experience Toolkit (EMET)

Usage:

/install   - Install EMET 5.51 and apply low configuration
/low       - DEP=ApplicationOptIn SEHOP=ApplicationOptIn ASLR=ApplicationOptIn Pinning=Enabled Fonts=Audit
/medium    - DEP=ApplicationOptOut SEHOP=ApplicationOptOut ASLR=ApplicationOptIn Pinning=Enabled Fonts=Audit
/high      - DEP=AlwaysOn SEHOP=AlwaysOn ASLR=ApplicationOptIn Pinning=Enabled Fonts=AlwaysOn
/uninstall - Resets system settings and uninstalls EMET
"@
}

function checkEMET {
  $list = Get-WmiObject Win32_Product | where { $_.Name.StartsWith("EMET ") }
  $m = $list | measure

  if ($m.Count -ne 1) {

    throw "EMET is not installed"
  }
}

function disableBDEProtectors {
  $ArgumentList = "-protectors -disable " + $env:SystemDrive

  try {
    Start-Process "Manage-Bde" -WindowStyle Hidden -ArgumentList $ArgumentList -Passthru -Wait | Out-Null
  }

  catch [invalidoperationexception]{
    # Home systems don't have BitLocker
  }
}

function enableBDEProtectors {
  $ArgumentList = "-protectors -enable " + $env:SystemDrive

  try {
    Start-Process "Manage-Bde" -WindowStyle Hidden -ArgumentList $ArgumentList -Passthru -Wait | Out-Null
  }

  catch [invalidoperationexception]{
    # Home systems don't have BitLocker
  }
}

function preConfig {
  CheckEMET

  cd $env:SystemDrive
  cd $EMETPath

  disableBDEProtectors

  Start-Process "EMET_Conf" -WindowStyle Hidden -ArgumentList '--import "Deployment\Protection Profiles\Popular Software.xml"' -Passthru -Wait | Out-Null
  Start-Process "EMET_Conf" -WindowStyle Hidden -ArgumentList '--import "Deployment\Protection Profiles\CertTrust.xml"' -Passthru -Wait | Out-Null

  Start-Process "EMET_Conf" -WindowStyle Hidden -ArgumentList "--system ASLR=ApplicationOptIn Pinning=Enabled" -Passthru -Wait | Out-Null
}

function postConfig {
  cd $env:SystemDrive
  cd $EMETPath

  $ArgumentList = "--agentstarthidden enabled --reporting -telemetry +trayicon +eventlog"

  Start-Process "EMET_Conf" -WindowStyle Hidden -ArgumentList $ArgumentList -Passthru -Wait | Out-Null

  enableBDEProtectors

  cd $MyPath
}

function setLow {
  preConfig

  Write-Host "Applying low configuration..."

  $ArgumentList = "--system DEP=ApplicationOptIn SEHOP=ApplicationOptIn"

  Start-Process "EMET_Conf" -WindowStyle Hidden -ArgumentList $ArgumentList -Passthru -Wait | Out-Null

  $ArgumentList = "--system Fonts=Audit"

  Start-Process "EMET_Conf" -WindowStyle Hidden -ArgumentList $ArgumentList -Passthru -Wait | Out-Null

  postConfig
}

function setMedium {
  preConfig

  Write-Host "Applying medium configuration..."

  $ArgumentList = "--system DEP=ApplicationOptOut SEHOP=ApplicationOptOut"

  Start-Process "EMET_Conf" -WindowStyle Hidden -ArgumentList $ArgumentList -Passthru -Wait | Out-Null

  $ArgumentList = "--system Fonts=Audit"

  Start-Process "EMET_Conf" -WindowStyle Hidden -ArgumentList $ArgumentList -Passthru -Wait | Out-Null

  postConfig
}

function setHigh {
  preConfig

  Write-Host "Applying high configuration..."

  $ArgumentList = "--system DEP=AlwaysOn SEHOP=AlwaysOn"

  Start-Process "EMET_Conf" -WindowStyle Hidden -ArgumentList $ArgumentList -Passthru -Wait | Out-Null

  $ArgumentList = "--system Fonts=AlwaysOn"

  Start-Process "EMET_Conf" -WindowStyle Hidden -ArgumentList $ArgumentList -Passthru -Wait | Out-Null

  postConfig
}

function installEMET {
  if (-not (Test-Path "EMET Setup.msi")) {

    throw "EMET Setup.msi does not exist"

  }

  Write-Host "Installing EMET..."

  $ArgumentList = '/i "EMET Setup.msi" /qn /norestart'


  cd $MyPath
  Start-Process "msiexec" -WindowStyle Hidden -ArgumentList $ArgumentList -Passthru -Wait | Out-Null

  setLow
}

function installDotNET {
  Write-Host "Installing .NET..."

  $ArgumentList = "/q /norestart"

  cd $MyPath
  Start-Process $DotNETInstallerPath -WindowStyle Hidden -ArgumentList $ArgumentList -Passthru -Wait | Out-Null
}

function install {
  if (Test-Path $DotNETInstallerPath) {
    installDotNET
  }
  installEMET
}

function uninstallEMET {
  setLow
  Write-Host "Uninstalling EMET..."

  $listing = Get-WmiObject Win32_Product | where { $_.Name.StartsWith("EMET ") }

  [string]$MSIGuid = $listing.IdentifyingNumber


  $ArgumentList = '/x "' + $MSIGuid + '" /qn /norestart'


  cd $MyPath
  Start-Process "msiexec" -WindowStyle Hidden -ArgumentList $ArgumentList -Passthru -Wait | Out-Null
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
       [Security.Principal.WindowsBuiltInRole]"Administrator"))
{
  throw "Please re-run this script as an administrator"
}

if ($Command -eq "/install") {
  install
}
elseif ($Command -eq "/uninstall") {
  uninstallEMET
}
elseif ($Command -eq "/low") {
  setLow
}
elseif ($Command -eq "/medium") {
  setMedium
}
elseif ($Command -eq "/high") {
  setHigh
}
else {
  printHelp
  return
}

Write-Host ""
Write-Warning "Restart the system to fully apply the changes."
