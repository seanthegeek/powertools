<#
.SYNOPSIS
Returns Active Directory details for the given user account(s). Useful for IT
support, information security teams, and pentesters. Only properties that are
reliably replicated are included. The returned object can be used with
Export-CSV and other useful outputs.

Rather than using a combination of the GAL, Active Directory Users and
Computers, and/or SharePoint, staff can use this script to obtain the following
user properties:

UserPrincipalName
SAMAccountName
Name
Title
JobTrack
Department
JobFamilyDescription
BusinessUnitDescription
BusinessSegmentDescription
Company
EmployeeNumber
EmployeeClass
EmployeeType
DistinguishedName
Manager
CostCenter
Room
SiteCode
SiteName
StreetAddress
City
State
PostalCode
Country
Email
Phone
MemberOf
ProxyAddresses
WhenCreated
HireDate
PasswordNeverExpires
PasswordExpired
PasswordSet
LastLoginTimestamp
SmartcardRequired
LockedOut
Disabled

Author: Sean Whalen (@SeanTheGeek - Sean@SeanPWhalen.com)
Version: 1.2.0
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

Returns Active Directory details for the given user account(s). Useful for IT
support, information security teams, and pentesters.

.PARAMETER UserIdentifiers

One or more UPNs, SAMaccountnames, or email addresses, separated by commas,
or a path to a text file containing one identifier per line. Domain prefixes
are ignored.

.EXAMPLE

Print details for one user

PS C:\> get-user alice.smith

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
  [Parameter(,Position = 0,Mandatory = $true)]
  [string[]]$UserIdentifiers
)

$ErrorActionPreference = "Stop"
$FormatEnumerationLimit = -1

function Get-User {
  [CmdletBinding()] param(
    [Parameter(,Position = 0,Mandatory = $true)]
    [string]$UserIdentifier
  )

  $ErrorActionPreference = "Stop"
    $FormatEnumerationLimit = -1

  $proporties = @(
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

  $objDomain = New-Object System.DirectoryServices.DirectoryEntry

  $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
  $objSearcher.SearchRoot = $objDomain

foreach ($proporty in $proporties) {
  $objSearcher.PropertiesToLoad.Add($proporty) | Out-Null
}

  $FilterStr = "(&(objectClass=user)(|(userPrincipalName={0})(sAMAccountName={0})(uid={0})(mail={0})(distinguishedName={0})(proxyAddresses=SMTP:{0})))"
  $FilterStr = [string]::Format($FilterStr, $UserIdentifier)
  $objSearcher.Filter = $FilterStr
  $user = $objSearcher.FindOne()

   if ($user -eq $null) {
     throw [string]::Format("{0} was not found", $UserIdentifier)
    }
  
  $user = $user.Properties
  $lockedOut = $false
  $passwordLastSet = [datetime]::FromFileTime([string]($user.pwdlastset))
  $lastLogonTimestamp = [datetime]::FromFileTime([string]($user.lastlogontimestamp))
  $disabled =  (([int64][string]$user.useraccountcontrol -band 2) -ne 0)
  $passwordNeverExpires = (([int64][string]$user.useraccountcontrol -band 65536) -ne 0)
  $passwordExpired = (([int64][string]$user.useraccountcontrol -band 8388608) -ne 0)
  $smartcardRequired = (([int64][string]$user.useraccountcontrol -band 262144) -ne 0)
  $validMailbox = (($user.msexchrecipienttypedetails -eq 1) -or ($user.msexchrecipienttypedetails -eq 2147483648))
  if ($user.lockouttime -gt 0) {
      $lockedOut = [datetime]::FromFileTime([string]$user.lockouttime) 
  }
  

  if (((Get-Date) - $lastLogonTimestamp) -le (New-TimeSpan -Days 14)) { 
      $lastLogonTimestamp = "<= 14 days" 
  }

  function toString ($value) {

    if ($value -eq $null) { return $null }
    if ($value -is [System.DirectoryServices.ResultPropertyValueCollection]) { $value =$value[0] } 
    return [string]$value
  }

  function toInt ($value) {
  if ($value -eq $null) { return $null }
    $value = toString $value
    try {
     $value = [int64]$value
    }
    catch {}
    return $value
  }

  function toDatetime ($value) {

    if ($value -eq $null) { return $null }
    return [datetime][string]$value
  }

  $userHash = [ordered]@{
    'UserPrincipalName' = toString $user.userprincipalname; 
    'SAMAccountName' = toString $user.samaccountname;
    'Name' = toString $user.name;
    'Title' = toString $user.title;
    'JobTrack' = toString $user.jobtrack;
    'Department' = toString $user.department;
    'JobFamilyDescription' = toString $user.jobfamilydescription;
    'BusinessUnitDescription' = toString $user.businessunitdescription;
    'BusinessSegmentDescription' = toString $user.businesssegmentdescription;
    'Company' = toString $user.company;
    'EmployeeNumber' = toInt $user.employeenumber;
    'EmployeeClass' = ToString $user.employeeclass;
    'EmployeeType' = toString $user.employeetype;
    'DistinguishedName' = toString $user.distinguishedname;
    'Manager' = toString $user.manager;
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
    'PasswordSet' = $passwordLastSet;
    'LastLoginTimestamp' = $lastLogonTimestamp;
    'SmartcardRequired' = $smartcardRequired;
    "ValidMailbox" = $validMailbox;
    'LockedOut' = $lockedOut;
    'Disabled' = $disabled }

  return New-Object –Type PSObject –Prop $userHash

}

if ($UserIdentifiers.Count -eq 1 -and (Test-Path -PathType Leaf $UserIdentifiers[0])) {
  $UserIdentifiers = Get-Content $UserIdentifiers[0] | Where-Object { $_ }
}

$UserIdentifiers = $UserIdentifiers | sort -Unique

if ($UserIdentifiers.Count -eq 1) {

  $user = Get-User $UserIdentifiers[0]
  return $user

}
else {
  $users = @()
  foreach ($UserIdentifier in $UserIdentifiers) {
    try {
      $user = Get-User $UserIdentifier
      $users += $user
    }
    catch {
      Write-Warning $_.Exception.Message
    }
  }
  return $users
}
