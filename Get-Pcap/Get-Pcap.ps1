<#
.SYNOPSIS
Obtains a zipped packet capture (PCAP) using netsh trace and etl2pcapng.

Inspired by https://bakerstreetforensics.com/2022/01/07/quickpcap-capturing-a-pcap-with-powershell/

Author: Sean Whalen (@SeanTheGeek)
Version: 1.0.0
Required Dependencies: None
Optional Dependencies: None

Copyright 2023 Sean Whalen

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
Obtains a zipped packet capture (PCAP) using netsh trace and etl2pcapng.

.PARAMETER Seconds

The duration of the packet capture in seconds (Default: 60)

.PARAMETER OutputPath

The output path (Default: $PcapPath.zip)

.PARAMETER Etl2pcapngPath

The path to etl2pcapng.exe (Default: .\etl2pcapng.exe)

.PARAMETER EtlPath

The output path for the ETL file (Default: .\capture.etl)

.PARAMETER PcapPath

The output path for the PCAP file (Default: .\capture.pcap)

.PARAMETER InterfaceIPv4Address

Overrides the interface to capture instead of auto-detecting it

.LINK

https://github.com/seanthegeek/powertools/Get-PCAP
#>

#Requires -Version 3

[CmdletBinding()] param(
    [Parameter(Mandatory = $false)]
    [int]$Seconds,
    [Parameter(Mandatory = $false)]
    [string]$OutputPath,
    [Parameter(Mandatory = $false)]
    [string]$Etl2pcapngPath,
    [Parameter(Mandatory = $false)]
    [string]$EtlPath,
    [Parameter(Mandatory = $false)]
    [string]$PcapPath,
    [Parameter(Mandatory = $false)]
    [string]$InterfaceIPv4Address
)

$ErrorActionPreference = "Stop"
$FormatEnumerationLimit = -1

if (0 -eq $Seconds) {
    $Seconds = 60
}

if ("" -eq $Etl2pcapngPath) {
    $Etl2pcapngPath = ".\etl2pcapng.exe"
}

if ("" -eq $EtlPath) {
    $EtlPath = ".\capture.etl"
}

if ("" -eq $PcapPath) {
    $PcapPath = ".\capture.pcap"
}

if ("" -eq $OutputPath) {
    $OutputPath = (".\{0}.zip" -f $PcapPath)
}

if (Test-Path -Path $OutputPath -PathType Leaf) {
    Write-Output ("{0} already exists." -f $OutputPath)
    exit -1
}

if (Test-Path -Path $EtlPath -PathType Leaf) {
    Write-Output ("{0} already exists." -f $EtlPath)
    exit -1
}

if (Test-Path -Path $PcapPath -PathType Leaf) {
    Write-Output ("{0} already exists." -f $PcapPath)
    exit -1
}

if ("" -eq $InterfaceIPv4Address) {
    $InterfaceIPv4Address = (
        Get-NetIPConfiguration |
        Where-Object {
            $_.IPv4DefaultGateway -ne $null -and
            $_.NetAdapter.Status -ne "Disconnected"
        }
    ).IPv4Address.IPAddress
}

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if (-Not $myWindowsPrincipal.IsInRole($adminRole))
{
    Write-Output "This script must be ran as an administrator"
    exit -1
}
netsh trace start capture=yes IPv4.Address=$InterfaceIPv4Address tracefile=$EtlPath
Start-Sleep -Seconds $Seconds
netsh trace stop
Write-Output ("Converting {0} to {1}" -f $EtlPath,$PcapPath)
Start-Process -Wait $Etl2pcapngPath $EtlPath,$PcapPath
Compress-Archive $PcapPath $OutputPath
if (Test-Path -Path $PcapPath -PathType Leaf) {
    Remove-Item $PcapPath
}
if (Test-Path -Path $EtlPath -PathType Leaf) {
    Remove-Item $EtlPath
}
$cabPath = $EtlPath.Replace(".etl", ".cab")
if (Test-Path -Path $cabPath -PathType Leaf) {
    Remove-Item $cabPath
}


