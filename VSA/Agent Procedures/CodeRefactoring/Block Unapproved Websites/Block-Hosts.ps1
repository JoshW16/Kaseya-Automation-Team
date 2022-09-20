﻿<#
=================================================================================
Script Name:        Management: Block unapproved websites
Description:        Blocks provided webhosts by adding entries to the hosts file that point to 0.0.0.0 address.
Lastest version:    2022-05-25
=================================================================================



Required variable inputs:
None



Required variable outputs:
None
#>
#Provide array of hostnames to block
[string[]] $BlockHosts = @('example.com')

#Create VSA X Event Source if it doesn't exist
if ( -not [System.Diagnostics.EventLog]::SourceExists("VSA X")) {
    [System.Diagnostics.EventLog]::CreateEventSource("VSA X", "Application")
}

[string]   $HostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
[string[]] $HostsFileContent = Get-Content -Path $HostsPath
[string[]] $HostsFileUpdatedContent = @()

#region check if the hosts file already has entries for the hostnames provided
foreach ( $HostsFileLine in $HostsFileContent ) {
    if ( -not [string]::IsNullOrWhiteSpace( $HostsFileLine ) -and  $HostsFileLine -notmatch "^#" ) {
        [string[]] $LineElements = Select-String -InputObject $HostsFileLine -Pattern "\S+" -AllMatches | ForEach-Object {$_.matches.Value}
          
        [string] $HostToCommentOut = Compare-Object -ReferenceObject $BlockHosts -DifferenceObject $LineElements -IncludeEqual |`
                                        Where-Object {$_.SideIndicator -eq '==' } | Select-Object -ExpandProperty InputObject
        
        if ( -not [string]::IsNullOrEmpty($HostToCommentOut) ) {
            $HostsFileLine = "#`t$HostsFileLine`t# Commented out due to hostname match"
        }        
    }
    $HostsFileUpdatedContent += $HostsFileLine
}
#endregion check if the hosts file already has entries for the hostnames provided

$HostsFileUpdatedContent += $( $BlockHosts | ForEach-Object { "0.0.0.0`t$_" | Write-Output } )

$HostsFileUpdatedContent | Out-File -FilePath $HostsPath -Encoding utf8 -Force -Confirm:$false

[System.Diagnostics.EventLog]::WriteEntry("VSA X", "The hosts $($BlockHosts -join ', ') are blocked with the hosts file", "Information", 200)