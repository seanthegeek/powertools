Get-User.ps1
============

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

Parameters
----------

 **GroupIdentifiers** (String, Required)

One or more UPNs, group names, separated by commas,
or a path to a text file containing one identifier per line. Domain prefixes
are ignored.

 **Base** (String, Optional)

The domain/base object to search in.

Examples
--------

Print details for one group

PS C:\> get-group HR

Get the full list of group memberships

PS C:\> $hr = get-group HR
PS C:\> $hr.MemberOf

Print details for multiple users

PS C:\> get-user HR,Finance

Print details of users that are listed in a file

PS C:\> get-group users.txt

Export the results to a CSV

PS C:\> get-groups groups.txt | Export-CSV -NoTypeInformation "groups.csv"

Show the results in a GUI

PS C:\> get-group groups.txt | Out-GridView
