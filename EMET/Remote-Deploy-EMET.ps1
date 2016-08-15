<#
.SYNOPSIS
Downloads, Installs, and configures EMET using a remote archive.

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

$ErrorActionPreference = "Stop"

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
       [Security.Principal.WindowsBuiltInRole]"Administrator"))
{
  throw "Please re-run this script as an administrator"
}

Add-Type -assembly "system.io.compression.filesystem"

$RemoteArchivePath = "\\NAS\Shared\Deployment\EMET.zip"

$ArchiveName = $RemoteArchivePath.split("\")[-1]
$DeploymentPath = $env:SystemDrive + "\Deployment"

New-Item -ItemType Directory -Force -Path $DeploymentPath | Out-Null
cd $DeploymentPath

$Message = "Copying " + $RemoteArchivePath + " to " + $DeploymentPath + "..."
Write-Host $Message
Copy-Item $RemoteArchivePath .
Remove-Item -Recurse -Force "EMET"

$ArchivePath = $DeploymentPath + "\" + $ArchiveName
$Message = "Extracting " + $ArchivePath + "..."
Write-Host $Message
[io.compression.zipfile]::ExtractToDirectory($ArchivePath, $DeploymentPath)
Remove-Item $ArchiveName

cd EMET
.\Deploy-EMET.ps1 /install

Write-Host "Please wait..."
.\Deploy-EMET.ps1 /high
