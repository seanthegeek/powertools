<#
.SYNOPSIS
Searches files for matching strings. Intended for searching data dumps.

Author: Sean Whalen (@SeanTheGeek - Sean@SeanPWhalen.com)
Version: 1.0.2
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

.PARAMETER InputFiles

A filename or wildcard matching the file(s) to search.
Optional - *.txt by default
    
.PARAMETER SearchList
    
The path to a file containing a list of strings to search for, such as domain names.
Optional - mydomains.csv by defualt

.LINK

https://github.com/seanthegeek/powertools
#>


[CmdletBinding()] param(
  [Parameter(Position = 0)]
  [string]$InputFiles = "*.txt",
  [Parameter(Position = 1)]
  [String]$SearchList = "mydomains.csv"
)

$ErrorActionPreference = "Stop"

$Results = New-Object System.Collections.ArrayList

Get-Content $SearchList| ForEach-Object {

    if ($_ -ne $Null)
    { 
        $SearchString = "\b" + $_ + "\b"
        $SubResults = (Get-ChildItem $InputFiles -Recurse | Select-String $SearchString -AllMatches)
        if ($SubResults -ne $Null)
        {
            $SubResults | ForEach-Object {
            $MatchString = $_.ToString()
            $SplitString = $MatchString.split(":")
            $MatchString = $SplitString[3..($SplitString.Length-1)] -join ":"
            $Results.Add($MatchString) | Out-Null
            }
        }
    }
}

$Results | Sort-Object -Unique

