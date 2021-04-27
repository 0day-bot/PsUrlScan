function Invoke-UrlScanSubmission {
   <#
    .SYNOPSIS
        Wraps scan endpoint

    .DESCRIPTION
        builds json body with url, tags and other relevant info and POSTS to API endpoint  
    
    .EXAMPLE
        Invoke-UrlScanSubmission -Url https://urlscan.io 
		
	.EXAMPLE
		Invoke-UrlScanSubmission -Url "https://microsoft.com/" -Referer "https://google.com" -CustomAgent "PSUrlscan/1.0" -Visibility "public" -Tags @("Test1", "Test2") -uuid
    #>
	
    [CmdletBinding()]
	Param (
		[Parameter(Mandatory=$True)]
		[String]
        $Url, 
		
		[Parameter(Mandatory=$False)]
		[String]
        $Referer,  
		
		[Parameter(Mandatory=$False)]
		[String]
        $CustomAgent,
		
		#Defaults to user's configured visibility but i'm setting to public for rate limit speeds in other functions 
		[Parameter(Mandatory=$False)]
        [ValidateSet("public", "unlisted", "private")]
        [String]
        $Visibility = "public",
		
		[Parameter(Mandatory=$False)]
		[String[]]
        $Tags,
    
		[Parameter(Mandatory=$False)]
		[Switch]
		$OverrideSafety,
		
		[Parameter(Mandatory=$False)]
		[Switch]
		$uuid
	)
	Process {
		$InitializationLog = $MyInvocation.MyCommand.Name
		$MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { $InitializationLog = $InitializationLog + " -$($_.Key) $($_.Value)"}
		Write-Log -Message $InitializationLog -Level Verbose
	
		$U = "/api/v1/scan/"
	
		$Body = @{
			"url" = $Url
		}
	
		if ($Referer) { $Body.Add("referer", $Referer) }
		if ($Visibility) { $Body.Add("visibility", $Visibility) }
		if ($CustomAgent) { $Body.Add("customagent", $CustomAgent) } 
		if ($Tags) { $Body.Add("tags", ($tags -join ',')) }
		if ($OverrideSafety) { $Body.Add("overrideSafety", "1") }
	
		$Response = Invoke-UrlScanQuery -endpoint $U -Method Post -ContentType "application/json" -Body ($Body | ConvertTo-Json)
		
		if (-not $uuid){
			Write-Output $Response
		}ElseIf($uuid){
			write-output $Response.uuid
		}
	}
	
}