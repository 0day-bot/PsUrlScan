function Invoke-UrlScanQuery {
    <#
    .SYNOPSIS
        Handles the request/response aspect of interacting with the UrlScan API.

    .DESCRIPTION
        Handles the request/response aspect of interacting with the UrlScan API, including pagination and error handling
    
    .EXAMPLE
        Invoke-UrlScanQuery -endpoint "/search/" -Parameters @{q = "domain:urlscan.io"} -Method GET
    #>
    [CmdletBinding(DefaultParameterSetName="Default")]
    Param(
        # The API endpoint from the UrlScan API Documentation
        [Parameter(Mandatory=$True)]
        [String]
        $endpoint,   
    
        # Hashtable containing the query string parameters used for filtering the results
        [Parameter(Mandatory=$False)]
        [Hashtable]
        $Parameters,

        # Content type of the body, if necessary, i.e. "application/json"
        [Parameter(Mandatory=$False)]
        [String]
        $ContentType,

        # Rest method for the query.
        [Parameter(Mandatory=$False)]
        [ValidateSet("Get", "Post", "Put", "Delete")]
        [String]
        $Method = "Get",

        # Used to limit the number of results in the response, if supported by the specific API
        [Parameter(Mandatory=$False,ParameterSetName="Count")]
        [Uint32]
        $Count,

        # Specify the maximum number of results allowed by the API. 
        [Parameter(Mandatory=$False)]
        [Uint32]
        $MaxCount=100,

        # Used to follow the cursor in paginated requests to retrieve all possible results
        [Parameter(Mandatory=$False,ParameterSetName="Recurse")]
        [Switch]
        $Recurse,

        # The body value for a POST or PUT request
        [Parameter(Mandatory=$False)]
        $Body
    )
     # Log the function and parameters being executed
    $InitializationLog = $MyInvocation.MyCommand.Name
    $MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { $InitializationLog = $InitializationLog + " -$($_.Key) $($_.Value)"}
    Write-Log -Message $InitializationLog -Level Verbose

     # Attempt to retrieve cached configuration
    if (-not $Script:PSUrlscan.ApiToken -or -not $Script:PSUrlScan.URL) {
        Write-Log -Message "PSUrlScan Module Configuration not cached. Loading information from disk." -Level Verbose
        Get-UrlscanModuleConfiguration -Persisted -Cache
        }
    

    # If no URL is known, notify the user and exit
    if (-not $Script:PSUrlScan.URL ) {
        Write-Log -Message "Please use Set-UrlscanModuleConfiguration to save your URL (it is the default parameter " -Level Error
        return
    }

    # If no token is present and not authenticating, notify the user and exit
    if (-not $Script:PSUrlScan.ApiToken ) {
        Write-Log -Message "Please use Set-UrlscanModuleConfiguration to save your APIToken" -Level Error
        return
    }

    # Start building request
    $Request = @{}
    $Request.Add("Method", $Method)
    $Request.Add("ErrorVariable", "RestError")
    if ($ContentType) {
        $Request.Add("ContentType", $ContentType)
    }
    if ($Body) {
        $Request.Add("Body", $Body)
    }

    # Build request headers and add to request
    $Headers = @{}
    $ApiToken = Unprotect-UrlscanToken -String $Script:PSUrlScan.ApiToken
    $Headers.Add("API-Key", "$ApiToken")
    $Request.Add("Headers", $Headers)

    # Start building request URI
    $URIBuilder = [System.UriBuilder]"$($Script:PSUrlScan.URL.Trim("/"), $endpoint.Trim("/") -join "/")"
    $QueryString = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    # Add any parameters supplied with -Parameters switch to Query String
    if ($Parameters.Count -gt 0) {
        $Parameters.GetEnumerator() | ForEach-Object {
            $QueryString.Add($_.Name, $_.Value)       
        }
    }

    # Process result limit
    if ($Count) {
        if ($Count -lt $MaxCount) {
            $QueryString.Add("limit", $Count)
            $Count = $Count - $Count
        } else {
            $QueryString.Add("limit", $MaxCount)
            $Count = $Count - $MaxCount
        }
    }
    if ($Recurse -and $QueryString -notcontains "limit") {
        $QueryString.Add("limit", $MaxCount)
    }

    # Add querystring to URI
    if ($QueryString.Count -gt 0) {
        $URIBuilder.Query = $QueryString.ToString()
    }

    # Add URI to request
    $Request.Add("URI", $URIBuilder.Uri.OriginalString)

    # Send request
    Try {
        Write-Log -Message "[$Method] $($URIBuilder.Uri.OriginalString)" -Level Verbose
        $Response = Invoke-RestMethod @Request
    } Catch {
        Write-Log -Message $RestError.InnerException.Message -Level Warning
        Write-Log -Message $RestError.Message -Level Warning
        Throw
    }

    if ($Parameters.countOnly) {
        return $Response.pagination.totalItems
    } else {
        Write-Output $Response
    }
    
    # Recurse through all results using the pagination cursor
    if ($Recurse) {
        while ($Response.pagination.nextCursor) {
            $URIBuilder = [System.UriBuilder]"$($Script:PSUrlScan.URL.Trim("/"), $endpoint.Trim("/") -join "/")"
            $QueryString.Add("cursor", $Response.pagination.nextCursor)
            $URIBuilder.Query = $QueryString.ToString()
            $Request.URI = $URIBuilder.Uri.OriginalString
            Write-Log -Message "[$Method] $($URIBuilder.Uri.OriginalString)" -Level Verbose
            $Response = Invoke-RestMethod @Request
            Write-Output $Response
    
            $QueryString.Remove("cursor")
        }
    }

    # Recurse through results until requested count is met. This could result in too many results, the commandlets should deal with returning exact numbers
    if ($Count) {
        while ($Count -gt 0 -and $Response.pagination.nextCursor) {
            $URIBuilder = [System.UriBuilder]"$($Script:PSUrlScan.URL.Trim("/"), $endpoint.Trim("/") -join "/")"
            $QueryString.Add("cursor", $Response.pagination.nextCursor)
            $URIBuilder.Query = $QueryString.ToString()
            $Request.URI = $URIBuilder.Uri.OriginalString
            Write-Log -Message "[$Method] $($URIBuilder.Uri.OriginalString)" -Level Verbose
            $Response = Invoke-RestMethod @Request
            Write-Output $Response
            if ($Count -lt $MaxCount) {
                $Count = $Count - $Count
            } else {
                $Count = $Count - $MaxCount
            }
            $QueryString.Remove("cursor")
        }
	}
}