Get-Hosts
=========

Parses and returns entries from a local or remote Windows hosts file.

    Author: Sean Whalen (@SeanTheGeek)
    Version: 1.0.1
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

Syntax
------

    Get-Hosts.ps1 [[-ComputerNames] <String[]>] [-CSV <String>] [<CommonParameters>]

Parameters
----------

    -ComputerNames <String[]>
        Optionally supply one or more computer names, or a path to a text file containing one name per line. \\ prefixes are ignored.
        
        Local admin rights are required to access a domain computer remotely.


    -CSV <String>
        Optionally export the results to the given path as a CSV file, rather than printing

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

Examples
--------

    PS C:\> # Return hosts file entries from the local machine
    PS C:\> get-hosts.ps1

    PS C:\> # Return hosts file entries from PC1
    PS C:\> get-hosts.ps1 PC1

    PS C:\> # Return hosts file entries from PC1 and PC2
    PS C:\> get-hosts.ps1 PC1,PC2

    PS C:\> # Return hosts file entries from PC1 and PC2, and export the results to hosts.csv
    PS C:\> get-hosts.ps1 PC1,PC2 -CSV hosts.csv

    PS C:\> # Return hosts file entries from the computers listed in computers.txt
    PS C:\> get-hosts.ps1 computers.txt

    PS C:\> Return the hosts file enteries for the local system
    PS C:\> get-hosts.ps1
