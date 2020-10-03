Get-UsersByJobTrack.ps1
=======================

Returns Active Directory details for user accounts in the given job track(s). Useful for IT support, information security teams, and pentesters. Only properties that are reliably replicated are included. The returned object can be used with Export-CSV and other useful outputs.

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

Parameters
----------

 **JobTracks** (String, Required)

One or more job tracks seperated by commas.

 **Base** (String, Optional)

The domain/ base object to search in.

Examples
--------

Get the properties of users with a `M1` job track:

    PS C:\> get-usersbyjobtrack M1

Get the properties of users for multiple job tracks:

    PS C:\> get-usersbyjobtrack M1,M2

Get the job track user properties of the job tracks listed in the given file

    PS C:\> get-userbyjobtracks tracks.txt

Output the results to a CSV file:

    PS C:\> get-usersbyjobtracks tracks.txt | Export-CSV -NoTypeInformation "users.csv"

Output the results to a searchable and sortable GUI:

    PS C:\> get-user users.txt | Out-GridView
