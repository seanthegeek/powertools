<#
.SYNOPSIS
Returns Active Directory details for the given user account(s). Useful for IT support,
information security teams, and pentesters. Only properties that are reliably replicated
are included. The returned object can be used with Export-CSV and other useful outputs.

Rather than using a combination of the GAL, Active Directory Users and Computers, and/or
SharePoint, users can use this script to obtain the following user properties:  

SAMAccountName	
Name
Title
JobFamilyDescription
BusinessUnitDescription
BusinessSegmentDescription
Company
EmployeeNumber
JobTrack
DestinguishedName
Manager
CostCenter
Room
SiteCode
SiteName
StreetAddress
City
State
PostalCode
Courtry
Email
Phone
MemberOf
WhenCreated
HireDate
PasswordNeverExpires
PasswordExpired
PasswordSet
LoggedOnRecently
SmartcardRequired
LockedOut
Disabled

Author: Sean Whalen (@SeanTheGeek - Sean@SeanPWhalen.com)
Version: 1.0.0
Required Dependencies: None
Optional Dependencies: None

   Copyright 2015 Sean Whalen

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

Returns Active Directory details for the given user account(s). Useful for IT support,
information security teams, and pentesters.

.PARAMETER SAMAccountNames

One or more account usernames, seperated by commas, oe  a path to a text file containing usernames. 
Domain prefixes and suffexes are ignored.
    
.PARAMETER recentLogonThreshold
    
The threshold number of days considered "recent". 30 by default. Cannot be lower than 14.

.EXAMPLE

PS C:\> get-user alice.smith

.EXAMPLE

PS C:\> get-user alice.smith,bob.jackson

.EXAMPLE

PS C:\> get-user users.txt 14
 
.EXAMPLE

PS C:\> get-user users.txt 14 | Export-CSV -NoTypeInformation "users.csv"

.EXAMPLE

PS C:\> get-user users.txt 14 | Out-GridView

.LINK

https://github.com/seanthegeek/powertools
#>

#Requires -Version 2

[CmdletBinding()] param(
  [Parameter(,Position = 0,Mandatory = $true)]
  [string[]]$SAMAccountNames,
  [Parameter(Position = 1)]
  [int]$recentLogonThreshold = 30
)

$ErrorActionPreference = "Stop"

function Get-User {
  [CmdletBinding()] param(
    [Parameter(,Position = 0,Mandatory = $true)]
    [string]$SAMAccountName,
    [Parameter(Position = 1)]
    [int]$recentLogonThreshold = 30
  )

  $ErrorActionPreference = "Stop"

  if ($recentLogonThreshold -lt 14) { throw "lastlogontimestamp is not accurate to less than 14 days" }

  $SAMAccountName = $SAMAccountName.Split("\")[-1].Split("@")[0].Trim()

  $strFilter = [string]::Format("(&(objectCategory=User)(samAccountName={0}))",$SAMAccountName)

  $objDomain = New-Object System.DirectoryServices.DirectoryEntry

  $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
  $objSearcher.SearchRoot = $objDomain

  $objSearcher.Filter = $strFilter
  $objSearcher.SearchScope = "Subtree"


  $user = $objSearcher.FindOne()
  if ($user -eq $null) { throw [string]::Format("User {0} was not found",$SAMAccountName) }
  $user = $user.Properties
  $disabled = $false
  $lockedOut = $false
  $passwordNeverExpires = $false
  $passwordExpired = $false
  $smartcardRequired = $false
  $loggedOnRecently = $true
  $passwordLastSet = [datetime]::FromFileTime([string]($user.pwdlastset))
  $lastLogonTimestamp = [datetime]::FromFileTime([string]($user.lastlogontimestamp))
  if ($lastLogonTimestamp -lt ((Get-Date).AddDays($recentLogonThreshold * -1))) { $loggedOnRecently = $False }
  if (([int64][string]$user.useraccountcontrol -band 2) -ne 0) { $disabled = $true }
  if (([int64][string]$user.useraccountcontrol -band 65536) -ne 0) { $passwordNeverExpires = $true }
  if (([int64][string]$user.useraccountcontrol -band 8388608) -ne 0) { $passwordExpired = $true }
  if (([int64][string]$user.useraccountcontrol -band 262144) -ne 0) { $smartcardRequired = $true }
  if ($user.lockouttime -gt 0) { $lockedOut = [datetime]::FromFileTime([string]$user.lockouttime) }

  function toString ($value) {

    if ($value -eq $null) { return $null }
    return [string]$value
  }

  function toInt ($value) {

    if ($value -eq $null) { return $null }
    return [int64][string]$value
  }

  function toDatetime ($value) {

    if ($value -eq $null) { return $null }
    return [datetime][string]$value
  }

  $userHash = [ordered]@{ 'SAMAccountName' = $SAMAccountName;
    'Name' = toString $user.name;
    'Title' = toString $user.title;
    'JobFamilyDescription' = toString $user.jobfamilydescription;
    'BusinessUnitDescription' = toString $user.businessunitdescription;
    'BusinessSegmentDescription' = toString $user.businesssegmentdescription;
    'Company' = toString $user.company;
    'EmployeeNumber' = toInt $user.employeenumber;
    'JobTrack' = toString $user.jobtrack;
    'DestinguishedName' = toString $user.distinguishedname;
    'Manager' = toString $user.manager;
    'CostCenter' = toInt $user.costcenter;
    'Room' = toString $user.roomnumber;
    'SiteCode' = toString $user.sitecode;
    'SiteName' = toString $user.sitename;
    'StreetAddress' = toString $user.streetaddress;
    'City' = toString $user.l;
    'State' = toString $user.st;
    'PostalCode' = toString $user.postalcode
    'Courtry' = toString $user.co
    'Email' = toString $user.mail
    'Phone' = toString $user.telephonenumber;
    'MemberOf' = toString $user.memberof;
    'WhenCreated' = toDatetime $user.whencreated;
    'HireDate' = toDatetime $user.hiredate;
    'PasswordNeverExpires' = $passwordNeverExpires;
    'PasswordExpired' = $passwordExpired;
    'PasswordSet' = $passwordLastSet;
    'LoggedOnRecently' = $loggedOnRecently;
    'SmartcardRequired' = $smartcardRequired;
    'LockedOut' = $lockedOut;
    'Disabled' = $disabled }

  return New-Object –Type PSObject –Prop $userHash

}

if ($SAMAccountNames.Count -eq 1 -and (Test-Path -PathType Leaf $SAMAccountNames[0])) {
  $SAMAccountNames = Get-Content $SAMAccountNames[0] | Where-Object { $_ }
}

if ($SAMAccountNames.Count -eq 1) {

  $user = Get-User $SAMAccountNames[0] $recentLogonThreshold
  return $user

}
else {
  $users = @()
  foreach ($AccountName in $SAMAccountNames) {
    $user = Get-User $AccountName $recentLogonThreshold
    $users += $user
  }
  return $users
}
