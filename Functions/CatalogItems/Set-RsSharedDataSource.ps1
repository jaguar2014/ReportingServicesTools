# Copyright (c) 2016 Microsoft Corporation. All Rights Reserved.
# Licensed under the MIT License (MIT)

<#

.SYNOPSIS
    Overrides the reference of a report or dataset to a shared data source. 

.DESCRIPTION
    Overrides the reference of a report or dataset to a shared data source. 

.PARAMETER ReportServerUri
    Specify the Report Server URL to your SQL Server Reporting Services Instance.
    Has to be provided if proxy is not provided.

.PARAMETER ReportServerCredentials
    Specify the credentials to use when connecting to your SQL Server Reporting Services Instance.

.PARAMETER Proxy
    Report server proxy to use. 
    Has to be provided if ReportServerUri is not provided.
    
.PARAMETER ItemPath 
    Path of the report or dataset.

.PARAMETER DataSourceName 
    Name of the datasource reference to override. 

.PARAMETER DataSourcePath
    Path to the shared data source the reference will point to.

.EXAMPLE
    
    Link-RsDataSet -ReportServerUri 'http://localhost/reportserver_sql2012' -ItemPath /DataSet -DataSourceName DataSource1 -DataSourcePath /Datasources/SampleSource

    Description
    -----------
    Sets the dataset reference 'DataSource1' of dataset '/DataSet' to point to datasource '/Datasources/SampleSource'
#>


function Set-RsSharedDataSource
{
    param(
        [string]
        $ReportServerUri = 'http://localhost/reportserver',
                
        [System.Management.Automation.PSCredential]
        $ReportServerCredentials,
        
        $Proxy,

        [Parameter(Mandatory=$true)]
        [string] 
        $ItemPath,

        [Parameter(Mandatory=$true)]
        [string]
        $DataSourceName,

        [Parameter(Mandatory=$true)]
        [string]
        $DataSourcePath
    )

    if(-not $Proxy)
    {
        $Proxy = New-RSWebServiceProxy -ReportServerUri $ReportServerUri -Credentials $ReportServerCredentials 
    }

    $dataSets = $Proxy.GetItemReferences($ItemPath, "DataSource")
    $dataSourceReference = $dataSets | Where-Object {$_.Name -eq $DataSourceName} | Select-Object -First 1 

    if(-not $dataSourceReference)
    {
        throw "$ItemPath does not contain a dataSource reference with name $DataSourceName"
    }

    $proxyNamespace = $dataSourceReference.GetType().Namespace
    $dataSourceReference = New-Object ("$($proxyNamespace).ItemReference")
    $dataSourceReference.Name = $DataSourceName
    $dataSourceReference.Reference = $DataSourcePath

    Write-Verbose "Set dataSource reference '$DataSourceName' of item $ItemPath to $DataSourcePath"
    $Proxy.SetItemReferences($ItemPath, @($dataSourceReference))
}

