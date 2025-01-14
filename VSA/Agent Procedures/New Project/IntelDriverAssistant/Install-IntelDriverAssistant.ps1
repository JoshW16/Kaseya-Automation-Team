param (
    [parameter(Mandatory=$true)]
    [string] $Path
)

Function Get-InstallStatus {
    Return  (Get-Package | Where-Object {$_.Name -eq "Intel® Driver & Support Assistant"} |  Select-Object -Property Status).Status
}

$status = Get-InstallStatus


if ($Status -ne "Installed") {
    
    Write-Output "Intel Driver Assistant is not installed on this computer and proceeding with the insallation steps!"
    #Run the install command
    Start-Process -Wait -FilePath $Path -ArgumentList '/install /quiet /norestart' 

    #Check the install status again
    $Status = Get-InstallStatus
    if ($Status -eq "Installed") {
        Write-Output "Intel Driver Assistant is successfully installed on this computer!"
    } else {
        Write-Output "Intel Driver Assistant is not installed!"
    }

} else {
    Write-Output "Intel Driver Assistant is already installed on this computer!"
}