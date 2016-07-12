Get-User.ps1
============

Returns Active Directory details for the given user account(s). Useful for IT
support, information security teams, and pentesters. Only properties that are
reliably replicated are included. The returned object can be used with
Export-CSV and other useful outputs.

Rather than using a combination of the GAL, Active Directory Users and
Computers, and/or SharePoint, staff can use this script to obtain the following
user properties:

    SAMAccountName
    Name
    Title
    JobFamilyDescription
    BusinessUnitDescription
    BusinessSegmentDescription
    Company
    EmployeeNumber
    JobTrack
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
    WhenCreated
    HireDate
    PasswordNeverExpires
    PasswordExpired
    PasswordSet
    LoggedOnRecently
    SmartcardRequired
    LockedOut
    Disabled

Parameters
----------

 **SAMAccountNames** (String, Required)

One or more account usernames, separated by commas, or a path to a text file
containing one username per line.

Domain prefixes and suffixes are ignored.

**recentLogonThreshold** (Integer, Optional)

The threshold number of days considered "recent".

30 by default. Cannot be lower than 14.

Examples
--------

Get the properties of the user `alice.smith`:

    PS C:\> get-user alice.smith

Get the properties of multiple users:

    PS C:\> get-user alice.smith,bob.jackson

Get the properties of usernames listed in the given file, and consider
logins recent if they are 14 days old or less:

    PS C:\> get-user users.txt 14

Output the results to a CSV file:

    PS C:\> get-user users.txt 14 | Export-CSV -NoTypeInformation "users.csv"

Output the results to a searchable and sortable GUI:

    PS C:\> get-user users.txt 14 | Out-GridView
