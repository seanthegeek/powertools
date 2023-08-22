<#
.SYNOPSIS
Runs Procmon in a minimized state for a period of time and then saves the
results as a zipped PML file.

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

Runs Procmon in a minimized state for a period of time and then saves the
results as a zipped PML file.

.PARAMETER Seconds

The number of seconds to run Procmon (Default: 60)

.PARAMETER ProcmonPath

The path to the procmon.exe (Default: .\Procmon64)

.PARAMETER BackingFilePath

The path to use for the Procmon backing file (Default: .\procmon.pml)

.PARAMETER OutputPath

The path of the output zip file (Default: $BackingFile.zip)

.LINK

https://github.com/seanthegeek/powertools/tree/master/Run-Procmon
#>

#Requires -Version 3

[CmdletBinding()] param(
    [Parameter(Mandatory = $false)]
    [int]$Seconds,
    [Parameter(Mandatory = $false)]
    [string]$ProcmonPath,
    [Parameter(Mandatory = $false)]
    [string]$BackingFilePath,
    [Parameter(Mandatory = $false)]
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"
$FormatEnumerationLimit = -1

if (0 -eq $Seconds) {
    $Seconds = 60
}

if ("" -eq $ProcmonPath) {
    $ProcmonPath = ".\Procmon64.exe"
}

if ("" -eq $BackingFilePath) {
    $BackingFilePath = ".\procmon.pml"
}

if ("" -eq $OutputPath) {
    $OutputPath = ("{0}.zip" -f $BackingFilePath) 
}

if ($false -eq (Test-Path -Path $ProcmonPath -PathType Leaf)) {
    Write-Error ("{0} not found" -f $ProcmonPath)
    exit -1
}

Start-Process $ProcmonPath  "/AcceptEula", "/Terminate"

 if (Test-Path -Path $OutputPath -PathType Leaf) {
    Write-Error ("{0} already exists." -f $OutputPath)
    exit -1
}

if (Test-Path -Path $BackingFilePath -PathType Leaf) {
    Write-Error ("{0} already exists." -f $BackingFilePath)
    exit -1
}

Start-Process $ProcmonPath "/AcceptEula", "/Quiet", "/Minimized", "/BackingFile", $BackingFilePath
Start-Sleep -Seconds $Seconds
Start-Process $ProcmonPath  "/AcceptEula", "/Terminate"
Start-Sleep 5
Compress-Archive $BackingFilePath $OutputPath
if (Test-Path -Path $BackingFilePath -PathType Leaf) {
    Remove-Item $BackingFilePath
}
