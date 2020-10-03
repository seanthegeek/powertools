<#
.SYNOPSIS
Returns Active Directory details for the given user account(s). Useful for IT
support, information security teams, and pentesters. Only properties that are
reliably replicated are included. The returned object can be used with
Export-CSV and other useful outputs.

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
Comment
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
Version: 1.3.0
Required Dependencies: None
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

.PARAMETER UserIdentifiers

One or more UPNs, SAMaccountnames, or email addresses, separated by commas,
or a path to a text file containing one identifier per line. Domain prefixes
are ignored.

.PARAMETER Base

The domain/base object to search in

.EXAMPLE

Print details for one user

PS C:\> get-user alice.smith

.EXAMPLE

Get the full list of group memberships

PS C:\> $alice = get-user alice.smith
PS C:\> $alice.MemberOf

.EXAMPLE

Get the full list of proxy addresses

PS C:\> $alice = get-user alice.smith
PS C:\> $alice.ProxyAddresses

.EXAMPLE

Print details for multiple users

PS C:\> get-user alice.smith,bob.jackson

.EXAMPLE

Print details of users that are listed in a file

PS C:\> get-user users.txt 

.EXAMPLE

Export the results to a CSV

PS C:\> get-user users.txt | Export-CSV -NoTypeInformation "users.csv"

.EXAMPLE

Show the results in a GUI

PS C:\> get-user users.txt | Out-GridView

.LINK

https://github.com/seanthegeek/powertools/tree/master/Get-User
#>

#Requires -Version 3

[CmdletBinding()] param(
  [Parameter(Position = 0, Mandatory = $true)]
  [string[]]$UserIdentifiers,
  [Parameter(Position = 1, Mandatory = $false)]
  [string]$Base
)

$ErrorActionPreference = "Stop"

function Get-User {
  
  param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$UserIdentifier,
    [Parameter(Position = 1, Mandatory = $false)]
    [string]$Base
)

  $ErrorActionPreference = "Stop"

  $ExchangeMailboxValues = @(
  1,           # User Mailbox
  2,           # Linked Mailbox
  4,           # Shared Mailbox
  8,           # Legacy Mailbox
  16,          # Room Mailbox
  32,          # Equipment Mailbox
  8192,        # System Attendant Mailbox 
  16384,       # Mailbox Database Mailbox 
  2147483648,  # Remote User Mailbox
  8589934592,  # Remote Room Mailbox
  17173869184, # Remote Equipment Mailbox 
  34359738368  # Remote Shared Mailbox
  )

  $RemoteExchangeMailboxValues = @(
  2147483648,  # Remote User Mailbox
  8589934592,  # Remote Room Mailbox
  17173869184, # Remote Equipment Mailbox 
  34359738368  # Remote Shared Mailbox
  )

  $proporties = @(
    "uid",
    "userPrincipalName",
    "sAMAccountName",
    "name",
    "title",
    "jobTrack",
    "department",
    "jobFamilyDescription",
    "businessUnitDescription",
    "businessSegmentDescription",
    "company",
    "employeeNumber",
    "employeeClass",
    "employeeType",
    "Description",
    "Comment",
    "distinguishedName",
    "manager"
    "costCenter",
    "roomNumber",
    "siteCode",
    "siteName",
    "physicalDeliveryOfficeName",
    "streetAddress",
    "l",
    "st"
    "postalCode",
    "co",
    "mail",
    "telephoneNumber",
    "homeDirectory",
    "hireDate",
    "reHireDate",
    "memberOf"
    "proxyAddresses",
    "userAccountControl",
    "msExchRecipientTypeDetails",
    "lastLogonTimestamp",
    "pwdLastSet",
    "lockoutTime",
    "whenCreated"
  )

  $UserIdentifier = $UserIdentifier.Split("\")[-1]

  if ($null -eq $Base) {
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

  $FilterStr = "(&(objectClass=user)(|(userPrincipalName={0})(sAMAccountName={0})(uid={0})(mail={0})(distinguishedName={0})(cn={0})(proxyAddresses=SMTP:{0})))"
  $FilterStr = [string]::Format($FilterStr, $UserIdentifier)
  $objSearcher.Filter = $FilterStr
  $user = $objSearcher.FindOne()

   if ($null -eq $user) {
     throw [string]::Format("{0} was not found", $UserIdentifier)
    }
  
    function toString ($value) {

    if ($null -eq $value) { return $null }
    if ($value -is [System.DirectoryServices.ResultPropertyValueCollection]) { $value = $value[0] } 
    return [string]$value
  }

  function toInt ($value) {
  if ($null -eq $value) { return $null }
    $value = toString $value
    try {
     $value = [int64]$value
    }
    catch {}
    return $value
  }

  function toDatetime ($value) {

    if ($null -eq $value) { return $null }
    return [datetime][string]$value
  }


  $user = $user.Properties
  $lockedOut = $false
  $passwordLastSet = [datetime]::FromFileTime([string]($user.pwdlastset))
  $lastLogonTimestamp = [datetime]::FromFileTime([string]($user.lastlogontimestamp))
  $disabled = (([int64][string]$user.useraccountcontrol -band 2) -ne 0)
  $passwordNeverExpires = (([int64][string]$user.useraccountcontrol -band 65536) -ne 0)
  $passwordExpired = (([int64][string]$user.useraccountcontrol -band 8388608) -ne 0)
  $smartcardRequired = (([int64][string]$user.useraccountcontrol -band 262144) -ne 0)
  $exchangeMailbox = ((toInt $user.msexchrecipienttypedetails) -in $exchangeMailboxValues)
  $remoteExchangeMailbox = ((toInt $user.msexchrecipienttypedetails) -in $RemoteExchangeMailboxValues)
  if ($user.lockouttime -gt 0) {
      $lockedOut = [datetime]::FromFileTime([string]$user.lockouttime) 
  }
  

  if (((Get-Date) - $lastLogonTimestamp) -le (New-TimeSpan -Days 14)) { 
      $lastLogonTimestamp = "<= 14 days" 
  } 

  $userHash = [ordered]@{
    'uid' = toString $user.uid;
    'UserPrincipalName' = toString $user.userprincipalname; 
    'SAMAccountName' = toString $user.samaccountname;
    'Name' = toString $user.name;
    'Title' = toString $user.title;
    'JobTrack' = toString $user.jobtrack;
    'Department' = toString $user.department;
    'JobFamily' = toString $user.jobfamilydescription;
    'BusinessUnit' = toString $user.businessunitdescription;
    'BusinessSegment' = toString $user.businesssegmentdescription;
    'Company' = toString $user.company;
    'EmployeeNumber' = toInt $user.employeenumber;
    'EmployeeClass' = ToString $user.employeeclass;
    'EmployeeType' = toString $user.employeetype;
    "Description" = toString $user.description;
    "Comment" = toString $user.comment;
    'DistinguishedName' = toString $user.distinguishedname;
    'ManagerDN' = toString $user.manager;
    'CostCenter' = toInt $user.costcenter;
    'Room' = toString $user.roomnumber;
    'SiteCode' = toString $user.sitecode;
    'SiteName' = toString $user.sitename;
    'PhysicalDeliveryOfficeName' = toString $user.physicaldeliveryofficename
    'StreetAddress' = toString $user.streetaddress;
    'City' = toString $user.l;
    'State' = toString $user.st;
    'PostalCode' = toString $user.postalcode
    'Country' = toString $user.co
    'Email' = toString $user.mail
    'Phone' = toString $user.telephonenumber;
    'MemberOf' =  [Array]$user.memberof;
    'ProxyAddresses' = [Array]$user.proxyaddresses; 
    'HomeDirectory' = toString $user.homedirectory;
    'WhenCreated' = toDatetime $user.whencreated;
    'HireDate' = toDatetime $user.hiredate;
    "ReHireDate" = toDatetime $user.rehiredate;
    'PasswordNeverExpires' = $passwordNeverExpires;
    'PasswordExpired' = $passwordExpired;
    'PasswordLastSet' = $passwordLastSet;
    'LastLoginTimestamp' = $lastLogonTimestamp;
    'SmartcardRequired' = $smartcardRequired;
    "ExchangeMailbox" = $exchangeMailbox;
    "RemoteExchangeMailbox" = $remoteExchangeMailbox;
    'LockedOut' = $lockedOut;
    'Disabled' = $disabled }

  return New-Object -Type PSObject -Prop $userHash

}

if ($UserIdentifiers.Count -eq 1 -and (Test-Path -PathType Leaf $UserIdentifiers[0])) {
  $UserIdentifiers = Get-Content $UserIdentifiers[0] | Where-Object { $_ }
}

$UserIdentifiers = $UserIdentifiers | sort -Unique

if ($UserIdentifiers.Count -eq 1) {

  $user = Get-User $UserIdentifiers[0] $Base 
  return $user

}
else {
  $users = @()
  foreach ($UserIdentifier in $UserIdentifiers) {
    try {
      $user = Get-User $UserIdentifier $Base
      $users += $user
    }
    catch {
      Write-Warning $_.Exception.Message
    }
  }
  return $users
}
