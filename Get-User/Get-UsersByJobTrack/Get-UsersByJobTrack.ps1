<#
.SYNOPSIS
Returns Active Directory details for active users with the given job track(s). 
Useful for IT support, information security teams, and pentesters. 
Only properties that are reliably replicated are included. 
The returned object can be used with Export-CSV and other useful outputs.

Rather than using a combination of the GAL, Active Directory Users and
Computers, and/or SharePoint, staff can use this script to obtain the following
user properties:

uid
UserPrincipalName
SAMAccountName
Name
Title
JobTrack
Department
JobFamily
BusinessUnit
BusinessSegment
Company
EmployeeNumber
EmployeeClass
EmployeeType
Description
Commment
DistinguishedName
ManagerDN
CostCenter
Room
SiteCode
SiteName
PhysicalDeliveryOfficeName
StreetAddress
City
State
PostalCode
Country
Email
Phone
MemberOf
ProxyAddresses
HomeDirectory
WhenCreated
HireDate
ReHireDate
PasswordNeverExpires
PasswordExpired
PasswordSet
LastLoginTimestamp
SmartcardRequired
ExchangeMailbox
RemoteExchangeMailbox
LockedOut
Disabled

Author: Sean Whalen (@SeanTheGeek)
Version: 1.1.0
Required Dependencies: Get-Users.ps1
Optional Dependencies: None

Copyright 2020 Sean Whalen

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

Returns Active Directory details for the given user account(s). Useful for IT
support, information security teams, and pentesters.

.PARAMETER JobTracks

One or more job tracks separated by commas.

.PARAMETER Base

The domain/base object to search in

.EXAMPLE

Print details for one job track

PS C:\> get-usersbyjobtrack M1

.EXAMPLE

Print details for multiple job tracks

PS C:\> get-usersbyjobtrack M1,M2

.EXAMPLE

Print details of users that are listed in a file

PS C:\> get-usersbyjobtrack tracks.txt

.EXAMPLE

Export the results to a CSV

PS C:\> get-usersbyjobtrack M1 | Export-CSV -NoTypeInformation "M1-users.csv"

.EXAMPLE

Show the results in a GUI

PS C:\> get-usersbyjobtrack M1 | Out-GridView

.LINK

https://github.com/seanthegeek/powertools/tree/master/Get-User/Get-UsersByJobTrack
#>

#Requires -Version 3

[CmdletBinding()] param(
  [Parameter(Position = 0, Mandatory = $true)]
  [string[]]$JobTracks,
  [Parameter(Position = 1, Mandatory = $false)]
  [string]$Base
)

$ErrorActionPreference = "Stop"

function Get-UsersByJobTrack {
  param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$JobTrack,
    [Parameter(Position = 1, Mandatory = $false)]
    [string]$Base
  )

  $ErrorActionPreference = "Stop"


  $proporties = @(
    "uid",
    "userPrincipalName",
    "sAMAccountName"
  )

  if ("" -eq $Base) {
    $objDomain = New-Object System.DirectoryServices.DirectoryEntry
    }
    else {
      $Base = $Base.ToLower()
      $Base = $Base -replace "ldap://", ""
      $Base = "LDAP://" + $Base
      $objDomain = New-Object System.DirectoryServices.DirectoryEntry $Base
    }

  $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
  $objSearcher.SearchRoot = $objDomain

  foreach ($proporty in $proporties) {
    $objSearcher.PropertiesToLoad.Add($proporty) | Out-Null
  }

  $FilterStr = "(&(objectClass=user)(jobTrack={0})(!(UserAccountControl:1.2.840.113556.1.4.803:=2)))"
  $FilterStr = [string]::Format($FilterStr, $JobTrack)
  $objSearcher.Filter = $FilterStr
  $_users = $objSearcher.FindAll()

   if ($null -eq $_users) {
     throw [string]::Format("Users with job track {0} were not found", $JobTrack)
    }
    $users = @()
    foreach ($user in $_users) {
      $_user = Get-User.ps1 $user.Properties.uid $Base
      $users += $_user
    }
    return $users
}

$users = @()
  foreach ($JobTrack in $JobTracks) {
    try {
      $_users = Get-UsersByJobTrack $JobTrack
      $users += $_users
    }
    catch {
      Write-Warning $_.Exception.Message
    }
  }
  return $users
