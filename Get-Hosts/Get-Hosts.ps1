<#
.SYNOPSIS
Parses and returns entries from a local or remote Windows hosts file.

Author: Sean Whalen (@SeanTheGeek - Sean@SeanPWhalen.com)
Version: 1.0.0
Required Dependencies: None
Optional Dependencies: None

Copyright 2017 Sean Whalen
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
Parses and returns entries from a local or remote Windows hosts file.
 
.PARAMETER ComputerNames
Optionally supply one or more computer names, or a path to a text file containing one name
per line. \\ prefixes are ignored.

.PARAMETER CSV
Optionally export the results to the given path as a CSV file, rather than printing

.NOTES
Local admin rights are required to access a domain computer remotely.

.EXAMPLE
# Return hosts file entries from the local machine
PS C:\> get-hosts.ps1

.EXAMPLE
# Return hosts file entries from PC1
PS C:\> get-hosts.ps1 PC1

.EXAMPLE
 # Return hosts file entries from PC1 and PC2
 PS C:\> get-hosts.ps1 PC1,PC2

.EXAMPLE
# Return hosts file entries from PC1 and PC2, and export the results to hosts.csv
PS C:\> get-hosts.ps1 PC1,PC2 -CSV hosts.csv

.EXAMPLE
# Return hosts file entries from the computers listed in computers.txt
PS C:\> get-hosts.ps1 computers.txt

.EXAMPLE
PS C:\> # Return the hosts file enteries for the local system
PS C:\> get-hosts.ps1

.LINK
https://github.com/seanthegeek/powertools/get-hosts
#>

[CmdletBinding()] param(
  [Parameter(Position= 0, mandatory = $False)]
  [string[]]$ComputerNames,
  [Parameter(Mandatory = $False)]
  [String]$CSV
)

$ErrorActionPreference = "Stop"

<#
.DESCRIPTION
Parses and returns entries from a local or remote Windows hosts file.
 
.PARAMETER ComputerName
Optionally supply a remote computer name to access. The \\ prefix is ignored.

.PARAMETER CSV
Optionally export the results to the given path as a CSV file, rather than printing

.NOTES
Local admin rights are required to access a domain computer remotely.

.EXAMPLE
# Return hosts file entries from the local machine
Get-Hosts

.EXAMPLE
# Return hosts file entries from PC1
Get-Hosts PC1

#>
function Get-Hosts {
    [CmdletBinding()] param(
    [Parameter(Position = 0, Mandatory = $False)]
    [string]$ComputerName
    )
    $root = "$env:HOMEDRIVE\"
    if ($ComputerName -ne "") {
    $ComputerName = $ComputerName.Replace("\", "")
    $root =  "\\$ComputerName\C$"
  }
  try {
    Remove-PSDrive -Name "Root" -ErrorAction Ignore
    New-PSDrive -Name "Root" -PSProvider FileSystem -Root $root > $null
    $hosts_content = Get-Content Root:\Windows\System32\drivers\etc\hosts | Where-Object { $_ } 
  }
  Catch [System.IO.IOException] {
    Write-Warning "$root could not be found. Is the host down?"
  }

  Catch [System.UnauthorizedAccessException] {
    Write-Warning "You do not have permission to access $root."
  }

    $pattern = "^\s*([\w.:]+)\s+([\w.]+)"
    $hosts = @()

    foreach ($line in $hosts_content) {
      $match = ([regex]::Match($line, $pattern).Groups)
      if ($match.Groups[0].Success -eq $true) {
      $proporties = [ordered]@{
      "Address" = $match.Groups[0].Groups[1].Value;
      "Hostname" = $match.Groups[0].Groups[2].Value
        }
        $entry = New-Object -TypeName PSObject -Property $proporties
      $hosts += $entry 
      }
    }

    $hosts
}

if ($ComputerNames.Count -eq 0) {
  $results =  Get-Hosts
}

elseif ($ComputerNames.Count -eq 1) {
  if (Test-Path -PathType Leaf $ComputerNames[0]) {
    $ComputerNames = Get-Content $ComputerNames[0] | Where-Object { $_ }
  }
  else {
    $results = Get-Hosts $ComputerNames[0]
  }
}

if ($ComputerNames.Count -gt 1) {
  $ComputerNames = $ComputerNames | Sort-Object -Unique
  $results = @()
  foreach ($ComputerName in $ComputerNames) {
    foreach($entry in Get-Hosts $ComputerName) {
    $properties = [ordered]@{Computer = $ComputerName.Replace("\", "");
                             Address = $entry.Address;
                             Hostname = $entry.hostname}
    $results += New-Object -TypeName PSObject -Property $properties
    }
  }
}

if ($CSV -ne "") {
  $results | Export-Csv -NoTypeInformation $CSV
}

else {
  return $results
}
