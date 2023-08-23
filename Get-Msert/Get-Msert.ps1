<#
.SYNOPSIS
Downloads and runs Microsoft Safety Scanner for silent remediation, 
then sends the logs to a web server.

Author: Sean Whalen (@SeanTheGeek)
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
    
.DESCRIPTION
Downloads and runs Microsoft Safety Scanner for silent remediation, 
then sends the logs to a web server.
 
.EXAMPLE
PS C:\> get-msert.ps1

.LINK
https://github.com/seanthegeek/powertools/tree/master/Get-Msert
#>

$LogServer = "192.168.2.63" # Change this to your server address

function main {
$ErrorActionPreference = "Stop"


If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
          [Security.Principal.WindowsBuiltInRole] “Administrator”))
{
    Write-Warning “You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!”
    Return
}

$msertDir = Join-Path $env:SystemDrive "msert"  
New-Item $msertDir -ItemType Directory -Force | Out-Null

$WebClient = new-object System.Net.WebClient
$msertPath = Join-Path $msertDir "msert.exe"
$LogPath = Join-Path $env:SystemRoot "\debug\msert.log"
$NewLogPath = Join-Path $msertDir ("msert_" + $env:COMPUTERNAME +".log")
$LogServerURL = "http://" + $LogServer + ":5000/msert"

if ($env:PROCESSOR_ARCHITECTURE -eq "x86") # Actually the architecture of the OS, not the processor
{
    $msertURL = "http://definitionupdates.microsoft.com/download/definitionupdates/safetyscanner/x86/msert.exe" 
}
else 
{
    $msertURL = "http://definitionupdates.microsoft.com/download/definitionupdates/safetyscanner/amd64/msert.exe"
}

Write-Host "Downloading msert.exe..."

$WebClient.DownloadFile($msertURL, $msertPath)   

Write-Host "Scan running..."
try
{
    Start-Process -FilePath $msertPath -WindowStyle Hidden -ArgumentList "/Q /F:Y" -PassThru -Wait | Out-Null
}
catch [InvalidOperationException]
{
    Write-Warning "The downloaded file is not a valid EXE. Retrying in 10 seconds..."
    Start-Sleep 10
    main
}

Write-Host "Scan Complete."
Write-Host "Sending logs..."
Copy-Item $LogPath $NewLogPath
$WebClient.UploadFile($LogServerURL, $NewLogPath)
Write-Host "Removing temp files..."
Remove-Item -Recurse -Force $msertDir
Write-Host "Process Complete."
}

main
