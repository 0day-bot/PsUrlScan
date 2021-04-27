function Set-UrlscanModuleConfiguration {
    <#
    .SYNOPSIS
        Sets the PSUrlscan module configuration values for connecting to urlscan
    
    .DESCRIPTION
        Sets the PSUrlscan module configuration values for connecting to the SentinelOne console
        Values can be set for the session only, or persisted to disk
    
    .PARAMETER URI
        Set the URI for your SentinelOne management console
    
    .PARAMETER ApiToken
        Set your ApiToken

    .PARAMETER Persist
        Switch to specify that the configuration values should be saved to disk. Tokens are a secure string saved to disk. Path is in the user's local AppData directory
    #>
    [CmdletBinding()]
    Param(
		[Parameter(Mandatory=$False)]
		[String]
        $URI = "https://urlscan.io/",

		[Parameter(Mandatory=$False)]
		[String]
        $ApiToken,
        
        [Parameter(Mandatory=$False)]
        [Switch]
        $Persist
    )
    # Log the command executed by the user
    $InitializationLog = $MyInvocation.MyCommand.Name
    $MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { $InitializationLog = $InitializationLog + " -$($_.Key) $($_.Value)"}
    Write-Log -Message $InitializationLog -Level Verbose

    # Serialize Tokens as SecureString
    if ($ApiToken) {
        $ApiTokenSecure = Protect-UrlscanToken -String $APIToken
    }

    if ($URI) {
        if ($Script:PSUrlScan.URL) {
            $Script:PSUrlScan.URL = $URI
        } else {
            $Script:PSUrlScan.Add("URL", $URI)
        }
    }
    if ($ApiToken) {
        if ($Script:PSUrlScan.ApiToken) {
            $Script:PSUrlScan.ApiToken = $ApiTokenSecure
        } else {
            $Script:PSUrlScan.Add("ApiToken", $ApiTokenSecure)
        }
    }

    if ($Persist) {
        $Configuration = Read-UrlscanModuleConfiguration -Path $Script:PSUrlScan.ConfPath

        if (-not $Configuration) {
            $Configuration = [PSCustomObject]@{}
        }

        if ($URI) {
            if (-not $Configuration.URI) {
                Add-Member -InputObject $Configuration -MemberType NoteProperty -Name URI -Value $URI
            } else {
                $Configuration.URI = $URI
            }
        }

        if ($ApiToken) {
            if (-not $Configuration.ApiToken) {
                Add-Member -InputObject $Configuration -MemberType NoteProperty -Name ApiToken -Value $ApiTokenSecure
            } else {
                $Configuration.ApiToken = $ApiTokenSecure
            }
        }
        
        Save-UrlscanModuleConfiguration -Path $Script:PSUrlScan.ConfPath -InputObject $Configuration
    }
}