<#
.SYNOPSIS
Searches files for matching strings. Intended for searching data dumps.

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
    
.DESCRIPTION
Searches files for matching strings. Intended for searching data dumps.
 
.EXAMPLE
PS C:\> get-msert.ps1

.LINK
https://github.com/seanthegeek/powertools
#>


[CmdletBinding()] param(
  [Parameter(,Position = 0)]
  [string]$InputFiles = "*.txt",
  [Parameter(Position = 1)]
  [String]$SearchList = "mydomains.csv"
   
)

$ErrorActionPreference = "Stop"

$Results = ""


Get-Content $SearchList| ForEach-Object {

    if ($_ -ne $Null)
    { 
        $SubResults +=  (Select-String -Path $InputFiles -Pattern $_ -SimpleMatch -AllMatches)
        if ($SubResults -ne $Null)
        {
            $SubResults | ForEach-Object {
            $MatchString = $_.ToString()
            $SplitString = $MatchString.split(":")
            $Matchstring = $SplitString[2..($Splitstring.Length-1)] -join ","
            $Results += $MatchString + "`r`n"
            }
        }
    }
}

$Results | Sort-Object | Get-Unique