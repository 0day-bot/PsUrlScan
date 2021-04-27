function Get-UrlScanQuota {
   <#
    .SYNOPSIS
        Returns local user's API quota

    .DESCRIPTION
        X-Rate-Limit-Scope: ip-address
		X-Rate-Limit-Action: search
		X-Rate-Limit-Window: minute
		X-Rate-Limit-Limit: 30
		X-Rate-Limit-Remaining: 24
		X-Rate-Limit-Reset: 2020-05-18T20:19:00.000Z
		X-Rate-Limit-Reset-After: 17
    
    .EXAMPLE
        Get-UrlScanQuota
    #>
	
	Process {
		$InitializationLog = $MyInvocation.MyCommand.Name
		$MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { $InitializationLog = $InitializationLog + " -$($_.Key) $($_.Value)"}
		Write-Log -Message $InitializationLog -Level Verbose
	
		$URI = "/user/quotas/"
	
		if ($Size) { $Parameters.Add("size", $Size) }
		if ($SearchAfter) { $Parameters.Add("search_after", ($SearchAfter -join ",") ) }
	
		$Response = Invoke-UrlScanQuery -endpoint $URI -ContentType "application/json"
		Write-Output $Response
	}
	
}