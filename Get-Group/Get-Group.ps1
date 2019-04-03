#Requires -Version 3

[CmdletBinding()] param(
  [Parameter(Position = 0, Mandatory = $true)]
  [string[]]$GroupIdentifiers
)

$ErrorActionPreference = "Stop"
$FormatEnumerationLimit = -1

function Get-Group {
  
  param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$GroupIdentifier
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

  $objDomain = New-Object System.DirectoryServices.DirectoryEntry

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

  if ($group -eq $null) {
    throw [string]::Format("{0} was not found", $GroupIdentifier)
   }

   $group = $group.Properties

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
  
  $GroupIdentifiers = $GroupIdentifiers | sort -Unique
  
  if ($GroupIdentifiers.count -eq 1) {
    $group = Get-Group $GroupIdentifiers
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