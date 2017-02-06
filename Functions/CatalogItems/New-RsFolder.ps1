# Copyright (c) 2016 Microsoft Corporation. All Rights Reserved.
# Licensed under the MIT License (MIT)

function New-RsFolder
{
    <#
    .SYNOPSIS
        This script creates a new folder in the Report Server

    .DESCRIPTION
        This script creates a new folder in the Report Server

    .PARAMETER ReportServerUri (optional)
        Specify the Report Server URL to your SQL Server Reporting Services Instance.

    .PARAMETER ReportServerCredentials (optional)
        Specify the credentials to use when connecting to your SQL Server Reporting Services Instance.

    .PARAMETER Proxy (optional)
        Specify the Proxy to use when communicating with Reporting Services server. If Proxy is not specified, connection to Report Server will be created using ReportServerUri, ReportServerUsername and ReportServerPassword.

    .PARAMETER Destination
        Specify the location where the folder should be created 

    .PARAMETER Name
        Specify the name of the the new data folder

    .EXAMPLE 
        New-RsFolder -Destination '/' -Name 'My new folder'
        Description
        -----------
        This command will establish a connection to the Report Server located at http://localhost/reportserver using current user's credentials and create a new folder 'My new folder' at the root folder.

    .EXAMPLE 
        New-RsFolder -ReportServerUri 'http://remoteServer/reportserver' -Destination '/existingfolder' -Name 'My new folder'	
        Description
        -----------
        This command will establish a connection to the Report Server located at http://remoteServer/reportserver using current user's credentials and create a new folder 'My new folder' at the folder existingfolder in the root.	

    #>

    [cmdletbinding()]
    param
    (
        [string]
        $ReportServerUri = 'http://localhost/reportserver',

        [System.Management.Automation.PSCredential]
        $ReportServerCredentials,

        $Proxy,

        [Parameter(Mandatory=$True)]
        [string]
        $Destination,

        [Parameter(Mandatory=$True)]
        [string]
        $Name
    )

    if (-not $Proxy)
    {
        $Proxy = New-RSWebServiceProxy -ReportServerUri $ReportServerUri -Credentials $ReportServerCredentials
    }

    try
    {
        Write-Verbose "Creating folder..."
        $Proxy.CreateFolder($Name, $Destination, $null)
        Write-Information "folder created successfully!"
    }
    catch
    {
       Write-Error "Exception occurred while creating folder! $($_.Exception.Message)"
       break 
    }
}