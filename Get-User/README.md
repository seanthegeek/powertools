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

 **UserIdentifiers** (String, Required)

One or more UPNs, SAMaccountnames, or email addresses, separated by commas,
or a path to a text file containing one identifier per line. Domain prefixes
are ignored.

 **Base** (String, Optional)

The domain/ base object to search in.


Examples
--------

Get the properties of the user `alice.smith`:

    PS C:\> get-user alice.smith

Get the properties of multiple users:

    PS C:\> get-user alice.smith,bob.jackson

Get the properties of usernames listed in the given file

    PS C:\> get-user users.txt

Output the results to a CSV file:

    PS C:\> get-user users.txt | Export-CSV -NoTypeInformation "users.csv"

Output the results to a searchable and sortable GUI:

    PS C:\> get-user users.txt | Out-GridView
