<#.SYNOPSIS
Returns Active Directory details for the given groups. Useful for IT
support, information security teams, and pentesters. Only properties that are
reliably replicated are included. The returned object can be used with
Export-CSV and other useful outputs.

Rather than using a combination of the GAL, Active Directory Users and
Computers, and/or SharePoint, staff can use this script to obtain the following
group properties:

name
distinguishedName
managedBy
info
memberOf
whenCreated
whenChanged

Author: Sean Whalen (@SeanTheGeek)
Version: 1.0.0
Required Dependencies: None
Optional Dependencies: None

Copyright 2019 Sean Whalen

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

.PARAMETER GroupIdentifiers

One or more UPNs, group names, separated by commas,
or a path to a text file containing one identifier per line. Domain prefixes
are ignored.

.PARAMETER Base

The domain/base object to search in

.EXAMPLE

Print details for one group

PS C:\> get-group HR

.EXAMPLE

Get the full list of group memberships

PS C:\> $hr = get-group HR
PS C:\> $hr.MemberOf

.EXAMPLE

Print details for multiple users

PS C:\> get-user HR,Finance

.EXAMPLE

Print details of users that are listed in a file

PS C:\> get-group users.txt

.EXAMPLE

Export the results to a CSV

PS C:\> get-groups groups.txt | Export-CSV -NoTypeInformation "groups.csv"

.EXAMPLE

Show the results in a GUI

PS C:\> get-group groups.txt | Out-GridView

.LINK

https://github.com/seanthegeek/powertools/tree/master/Get-Group
#>

#Requires -Version 3

[CmdletBinding()] param(
  [Parameter(Position = 0, Mandatory = $true)]
  [string[]]$GroupIdentifiers,
  [Parameter(Position = 1, Mandatory = $false)]
  [string]$Base
)

$ErrorActionPreference = "Stop"
$FormatEnumerationLimit = -1

function Get-Group {
  
  [CmdletBinding()] param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$GroupIdentifier,
    [Parameter(Position = 1, Mandatory = $false)]
    [string]$Base
  )

  $proporties = @(
    "name",
    "distinguishedName",
    "managedBy",
    "info",
    "memberOf",
    "whenCreated",
    "whenChanged"
  )

  $GroupIdentifier = $GroupIdentifier.Split("\")[-1]

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

foreach ($property in $proporties) {
  $objSearcher.PropertiesToLoad.Add($property) | Out-Null
}

# Setup range limits.
$last = $False
$rangeStep = 999
$lowRange = 0
$highRange = $lowRange + $rangeStep
$exitFlag = $False


  $FilterStr = "(&(objectClass=group)(|(cn={0})(sAMAccountName={0})(name={0})(distinguishedName={0})))"
  $FilterStr = [string]::Format($FilterStr, $GroupIdentifier)
  $objSearcher.Filter = $FilterStr
  $group = $objSearcher.FindOne()

  if ($null -eq $group) {
    throw [string]::Format("{0} was not found", $GroupIdentifier)
   }

   $group = $group.Properties

   function toString ($value) {

   if ($null -eq $value) { return $null }
   if ($value -is [System.DirectoryServices.ResultPropertyValueCollection]) { $value =$value[0] } 
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

$allMembers = @()

 Do
{
    If ($last -eq $True)
    {
        # Retrieve remaining members (less than 1000).
        $property = "member;range=$lowRange-*"
    }
    Else
    {
        # Retrieve 1000 members.
        $property = "member;range=$lowRange-$highRange"
    }
    $objSearcher.PropertiesToLoad.Add($property) | Out-Null
    $count = 0

    $members = $objSearcher.FindOne().Properties.$property
    Write-Output $members.GetType()
    #$members = $objSearcher.FindOne().Properties.("$property")
        # If $members is not an array, no members were retrieved.
        If ($members.GetType().Name -eq "Object[]")
        {
            ForEach ($member In $members)
            {
                # Output the distinguished name of each direct member of the group.
                $allMembers.Add($member)
                $count = $count + 1
            }
        }

    # If this is the last query, exit the Do loop.
    If ($last -eq $True) {$exitFlag = $True}
    Else
    {
        # If the previous query returned no members, the query failed.
        # Perform one more query to retrieve remaining members (less than 1000).
        If ($count -eq 0) {$last = $True}
        Else
        {
            # Retrieve the next 1000 members.
            $lowRange = $highRange + 1
            $highRange = $lowRange + $rangeStep
        }
    }
} Until ($exitFlag -eq $True)
  
  $groupHash = [ordered]@{
      'name' = toString $group.name;
      'distinguishedName' = toString $group.distinguishedname;
      'managedBy' = toString $group.managedby
      'description' = toString $group.info;
      'whenCreated'  =  toDatetime $group.whencreated;
      'WhenChanged' = toDatetime $group.whenchanged;
      'memberOf' = [Array]$group.memberof;
      'members' = [Array]$group.member
  }

  return New-Object -Type PSObject -Property $groupHash

}

if ($GroupIdentifiers.count -eq 1 -and (Test-Path -PathType Leaf $GroupIdentifiers[0])) {
    $GroupIdentifiers = Get-Content $GroupIdentifiers[0] | Where-Object { $_ }
  }
  
  $GroupIdentifiers = $GroupIdentifiers | Sort-Object -Unique
  
  if ($GroupIdentifiers.count -eq 1) {
    $group = Get-Group $GroupIdentifiers $Base
    return $group
  
  }
  else {
    $groups = @()
    foreach ($GroupIdentifier in $GroupIdentifiers) {
      try {
        $group = Get-Group $GroupIdentifier
        $groups += $group
      }
      catch {
        Write-Warning $_.Exception.Message
      }
    }
    return $groups
  }