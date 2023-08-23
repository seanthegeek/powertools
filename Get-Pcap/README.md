Get-Pcap.ps1
=============

Obtains a zipped packet capture (PCAP) using `netsh trace` and
[etl2pcapng][etl2pcapng].

Inspired by [Baker Street Forensics][bakerstreet].

    Author: Sean Whalen (@SeanTheGeek)
    Version: 1.0.0
    Required Dependencies: None
    Optional Dependencies: None

    Copyright 2023 Sean Whalen

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

Syntax
------

    Get-Pcap.ps1 [[-Seconds] <Int32>] [[-OutputPath] <String>]    
    [[-Etl2pcapngPath] <String>] [[-EtlPath] <String>] [[-PcapPath] <String>] [[-InterfaceIPv4Address] <String>]     
    [<CommonParameters>]

Parameters
----------

    -Seconds <Int32>
        The duration of the packet capture in seconds (Default: 60)

    -OutputPath <String>
        The output path (Default: $PcapPath.zip)

    -Etl2pcapngPath <String>
        The path to etl2pcapng.exe (Default: .\etl2pcapng.exe)

    -EtlPath <String>
        The output path for the ETL file (Default: .\capture.etl)

    -PcapPath <String>
        The output path for the PCAP file (Default: .\capture.pcap)

    -InterfaceIPv4Address <String>
        Overrides the interface to capture instead of auto-detecting it

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).

[etl2pcapng]: https://github.com/microsoft/etl2pcapng/releases
[bakerstreet]: https://bakerstreetforensics.com/2022/01/07/quickpcap-capturing-a-pcap-with-powershell/
