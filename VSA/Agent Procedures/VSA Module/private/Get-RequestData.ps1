#region function Get-RequestData
function Get-RequestData
{
    <#
    .Synopsis
       Returns web request's response
    .DESCRIPTION
       Returns response fo formed web request.
    .PARAMETER URI
        Specifies URI for the web request.
    .PARAMETER AuthString
        Specifies authentication string.
    .PARAMETER Method
        Specifies REST API method.
    .PARAMETER Body
        Specifies the request's Body.
    .EXAMPLE
       Get-RequestData -URI $URI -AuthString $AuthString
    .EXAMPLE
       Get-RequestData -URI $URI -AuthString $AuthString
    .INPUTS
       None. You cannot pipe objects to Get-RequestData. 
    .OUTPUTS
       Array of custom objects returned by the remote server.
    #>
    [CmdletBinding()]
    param ( 
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()] 
        [string] $URI,
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()] 
        [string] $AuthString,
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)] 
        [ValidateSet("GET", "POST", "PUT", "DELETE", "PATCH")]
        [string] $Method = "GET",
        [parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)] 
        [ValidateNotNullOrEmpty()]
		[string] $Body
    )

    $authHeader = @{
        Authorization = $AuthString
    }

    $requestParameters = @{
        Uri = $URI
        Method = $Method
        Headers = $authHeader
    }
    
    Log-Event -Msg "Executing call $Method : $URI" -Id 0010 -Type "Information"
   
    try {
            if ($Body) {
	            $response = Invoke-RestMethod @requestParameters -Body $Body -ErrorAction Stop
	        } else {
                $response = Invoke-RestMethod @requestParameters -ErrorAction Stop
            }
            
            if (0 -eq $response.ResponseCode) {
                return $response.Result
            } else {
                Log-Event -Msg "$response.Error" -Id 0000 -Type "Error"
                throw $response.Error
            }
    } catch { throw $($_.Exception.Message) }
}
Export-ModuleMember -Function Get-RequestData
#endregion function Get-RequestData