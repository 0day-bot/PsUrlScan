function Search-UrlScan {
   <#
    .SYNOPSIS
        Wraps search endpoint

    .DESCRIPTION
        Querys search endpoint with three parameters
		Query parameter can take elastic queries like:
			page.domain:(urlscan.io OR any.run)
		Max size is listed as 10,000 on documentation but I believe that's for premium functionality. 
    
    .EXAMPLE
        Search-UrlScan -Query domain:urlscan.io -Size 5 
    #>
	
    [CmdletBinding()]
	Param (
		[Parameter(Mandatory=$True)]
		[String]
        $Query,   
    
		[Parameter(Mandatory=$False)]
		[Int32]
		$Size,
		
		[Parameter(Mandatory=$False)]
		[String[]]
		$SearchAfter
	)
	Process {
		$InitializationLog = $MyInvocation.MyCommand.Name
		$MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { $InitializationLog = $InitializationLog + " -$($_.Key) $($_.Value)"}
		Write-Log -Message $InitializationLog -Level Verbose
	
		$URI = "/api/v1/search/"
		$Parameters = @{}
		$Parameters.Add("q", $Query)
	
		if ($Size) { $Parameters.Add("size", $Size) }
		if ($SearchAfter) { $Parameters.Add("search_after", ($SearchAfter -join ",") ) }
	
		$Response = Invoke-UrlScanQuery -endpoint $URI -Parameters $Parameters 
		Write-Output $Response.results
	}
	
}