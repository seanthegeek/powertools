<#
.SYNOPSIS
This script CSV line for use as a corporate identifier in Microsoft Intune.
All CSV fields are sounded by double quotes, because some manufacturers
include commas in their names for example, "Dell, Inc."
periods are stripped from device serial numbers, as prescribed in Microsoft's
documentation at https://learn.microsoft.com/en-us/intune/intune-service/enrollment/corporate-identifiers-add#step-1-create-csv-file

Supported with Windows 11, version 22H2 and later with KB5035942
(OS Builds 22621.3374 and 22631.3374)

.DESCRIPTION
Outputs a CSV line for use as a corporate identifier in Microsoft Intune
#>

# Get the computer information
$computerInfo = Get-WmiObject -Class Win32_ComputerSystem
$biosInfo = Get-WmiObject -Class Win32_BIOS

# Extract the manufacturer, model, and serial number
$manufacturer = $computerInfo.Manufacturer
$model = $computerInfo.Model
$serialNumber = $biosInfo.SerialNumber

# Strip periods from the serial number
$serialNumber = $serialNumber -replace '\.',''

# Format as quoted CSV fields
$csvLine = """$manufacturer"",""$model"",""$serialNumber"""

# Output the CSV line
$csvLine
