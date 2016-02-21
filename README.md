# powertools
PowerShell scripts written by a Linux user. You have been warned.

As I'm working more and more with Windows systems, I've found myself leveraging more native features using PowerShell. This repository contains scripts I have written that might be useful to other IT and InfoSec professionals.

## Running PowerShell scripts

By defualt, the PowerShell [execution policy](https://technet.microsoft.com/en-us/library/hh847748.aspx) will block you from running any PowerShell script. To turn this off for your user account, run:

    PowerShell.exe Set-ExecutionPolicy -Force 'Unrestricted' -Scope CurrentUser
    
Or use the `bypass` switch when you run the script

    PowerShell.exe -ExecutionPolicy Bypass -File runme.ps1
