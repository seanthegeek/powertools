Run-Procmon.ps1
===============

Runs Procmon in a minimized state for a period of time and then saves the
results as a zipped PML file.

    Author: Sean Whalen (@SeanTheGeek)
    Version: 1.0.
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

    Run-Procmon.ps1 [[-Seconds] <Int32>] [[-ProcmonPath]       
    <String>] [[-BackingFilePath] <String>] [[-OutputPath] <String>] [<CommonParameters>]

Parameters
----------

    -Seconds <Int32>
        The number of seconds to run Procmon (Default: 60)

    -ProcmonPath <String>
        The path to the procmon.exe (Default: .\Procmon64.exe)

    -BackingFilePath <String>
        The path to use for the Procmon backing file (Default: .\procmon.pml)

    -OutputPath <String>
        The path of the output zip file (Default: $BackingFile.zip)

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).
