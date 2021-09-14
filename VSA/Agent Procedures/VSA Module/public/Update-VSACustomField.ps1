﻿function Update-VSACustomField
{
    <#
    .Synopsis
       Updates an existing Custom field.
    .DESCRIPTION
       Renames VSA an custom field or changes value of the field of an agent.
       Takes either persistent or non-persistent connection information.
    .PARAMETER VSAConnection
        Specifies existing non-persistent VSAConnection.
    .PARAMETER URISuffix
        Specifies URI suffix if it differs from the default.
    .PARAMETER FieldName
        Custom field name to rename or change value.
    .PARAMETER FieldValue
        Value to assign to the provided field for provided AgentID.
    .PARAMETER NewFieldName
        New Field Name.
    .EXAMPLE
       Update-VSACustomField -FieldName 'MyField' -FieldValue 'New Value' -AgentID '100001'
    .EXAMPLE
       Update-VSACustomField -FieldName 'OldFieldName' -NewFieldName 'NewFieldName'
    .INPUTS
       Accepts piped non-persistent VSAConnection 
    .OUTPUTS
       True if update was successful
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false, 
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'RenameField')]
        [parameter(Mandatory = $false, 
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'UpdateValue')]
        [ValidateNotNull()]
        [VSAConnection] $VSAConnection,

        [parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName = 'RenameField')]
        [parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName = 'UpdateValue')]
        [ValidateNotNullOrEmpty()] 
        [string] $FieldName,

        [parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName = 'RenameField')]
        [string] $NewFieldName,

        [parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName = 'UpdateValue')]
        [ValidateNotNullOrEmpty()] 
        [string] $FieldValue,

        [parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            ParameterSetName = 'UpdateValue')]
        [ValidateNotNullOrEmpty()] 
        [string] $AgentID,

        [parameter(Mandatory = $false, 
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'RenameField')]
        [parameter(Mandatory = $false, 
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'UpdateValue')]
        [ValidateNotNullOrEmpty()] 
        [string] $URISuffix = "api/v1.0/assetmgmt/assets/{1}/customfields/{0}"
        )

    [string]  $Body
    [string[]]$Values = @($FieldName)

    if ( $FieldValue ) {
        #update fiel value
        $Values += $AgentID
        $Body = ConvertTo-Json @(@{"key"="FieldValue";"value"=$FieldValue })
    } else {
        #rename field
        $TheField = $OldFieldName
        $Values += ''
        $Body = ConvertTo-Json @(@{"key"="NewFieldName";"value"=$NewFieldName})
    }
    $Body | Write-Verbose

    $URISuffix = $("api/v1.0/assetmgmt/assets/{1}/customfields/{0}" -f $Values) -replace '//', '/'

    [hashtable]$Params =@{
    URISuffix = $URISuffix
    Method = 'PUT'
    Body = $Body
    }

    if($VSAConnection) {$Params.Add('VSAConnection', $VSAConnection)}

    [string[]]$ExistingFields = Get-VSACustomFields | Select-Object -ExpandProperty FieldName 


    If ($FieldName -notin $ExistingFields) {
        throw "The custom field $FieldName does not exist"
    }

    if ( -not [string]::IsNullOrEmpty($NewFieldName) -and ($NewFieldName -in $ExistingFields) ) {
        throw "Cannot rename $FieldName to $NewFieldName. The custom field name $NewFieldName does not exist"
    }
    if ($FieldName -eq $NewFieldName) {
        throw "Cannot rename $FieldName to $NewFieldName"
    }

    return Update-VSAItems @Params
        
}
Export-ModuleMember -Function Update-VSACustomField