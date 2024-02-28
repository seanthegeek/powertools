Get-User.ps1
============

Returns Active Directory details for the given user account(s). Useful for IT support, information security teams, and pentesters. Only properties that are reliably replicated are included. The returned object can be used with Export-CSV and other useful outputs.

Rather than using a combination of the GAL, Active Directory Users and
Computers, and/or SharePoint, staff can use this script to obtain the following user properties:

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
    WhenChanged
    HireDate
    ReHireDate
    TerminationDate
    PasswordNeverExpires
    PasswordExpired
    PasswordSet
    LastLoginTimestamp
    SmartcardRequired
    ExchangeMailbox
    RemoteExchangeMailbox
    LockedOut
    Disabled

License
-------

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

Parameters
----------

 **UserIdentifiers** (String, Required)

One or more UPNs, SAMaccountnames, or email addresses, separated by commas,
or a path to a text file containing one identifier per line. Domain prefixes
are ignored.

 **Base** (String, Optional)

The domain/base object to search in.

Examples
--------

Print details for one user

    PS C:\> get-user alice.smith

Get the full list of group memberships

    PS C:\> $alice = get-user alice.smith
    PS C:\> $alice.MemberOf

Get the full list of proxy addresses

    PS C:\> $alice = get-user alice.smith
    PS C:\> $alice.ProxyAddresses

Print details for multiple users

    PS C:\> get-user alice.smith,bob.jackson

Print details of users that are listed in a file

    PS C:\> get-user users.txt

Export the results to a CSV

    PS C:\> get-user users.txt | Export-CSV -NoTypeInformation "users.csv"

Show the results in a GUI

    PS C:\> get-user users.txt | Out-GridView
