function Get-UrlScanModuleConfiguration {
    <#
    .SYNOPSIS
        Retrieves the current configuration values for the PSUrlscan Module
    .PARAMETER Persisted
        Retrieve the configuration persisted to disk
    
    .PARAMETER Cache
        Instructs this function to cache the configuration settings in a variable accesible to subsequent requests so that saved configuration does not need to be retrieved for every request
    #>
    [CmdletBinding(DefaultParameterSetName="Cached")]
    Param(
        [Parameter(Mandatory=$True,ParameterSetName="Persisted")]
        [Switch]
        $Persisted,

        [Parameter(Mandatory=$False,ParameterSetName="Persisted")]
        [Switch]
        $Cache
    )
    # Log the command executed by the user
    $InitializationLog = $MyInvocation.MyCommand.Name
    $MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { $InitializationLog = $InitializationLog + " -$($_.Key) $($_.Value)"}
    Write-Log -Message $InitializationLog -Level Verbose

    if ($Persisted) {
        $Configuration = Read-UrlscanModuleConfiguration -Path $Script:PSUrlScan.ConfPath

        if ($Cache) {
            Write-Log -Message "Caching configuration settings for future queries." -Level Verbose
            if ($Configuration.URI -and -not $Script:PSUrlScan.URL) {
                $Script:PSUrlScan.Add("URL", $Configuration.URI)
            }
			
			#If We don't have the environment variable populated we set it from teh Configuration variable read from disk 
            if ($Configuration.ApiToken -and -not $Script:PSUrlScan.ApiToken) {
                $Script:PSUrlScan.Add("ApiToken", $Configuration.ApiToken)
            }
            return
        }

        return $Configuration
    } else {
        return $Script:PSUrlScan
    }
}