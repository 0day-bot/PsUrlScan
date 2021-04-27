function Watch-UrlScanSubmission {
   <#
    .SYNOPSIS
        Waits for response with timer 

    .DESCRIPTION
          
    
    .EXAMPLE
        Watch-UrlScanSubmission -URI https://urlscan.io 
		
	.EXAMPLE
		Watch-UrlScanSubmission -URI "https://microsoft.com/" -Referer "https://google.com" -CustomAgent "PSUrlscan/1.0" -Visibility "public" -Tags @("Test1", "Test2") -uuid
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
		
		#Defaults to user's configured visibility
		[Parameter(Mandatory=$False)]
        [ValidateSet("public", "unlisted", "private")]
        [String]
        $Visibility,
		
		[Parameter(Mandatory=$False)]
		[String[]]
        $Tags,
    
		[Parameter(Mandatory=$False)]
		[Switch]
		$OverrideSafety
	)
	Process {
		$InitializationLog = $MyInvocation.MyCommand.Name
		$MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { $InitializationLog = $InitializationLog + " -$($_.Key) $($_.Value)"}
		Write-Log -Message $InitializationLog -Level Verbose
	
		
		$Parameters = @{}
		if($Referer) { $Parameters.Add("Referer", $Referer) }
		if ($CustomAgent) { $Parameters.Add( "CustomAgent", $CustomAgent) }
		if ($Visibility) { $Parameters.Add("Visibility", $Visibility) }
		if ($Tags) { $Parameters.Add("Tags", $Tags) }
		if ($OverrideSafety) { $Parameters.Add("OverrideSafety", $OverrideSafety) }
	
		$uid = Invoke-UrlScanSubmission @Parameters -Uuid -Url $Url 
		
		$Seconds = 10
		$finished = $False
		
		Write-Log -Message "Will Wait 10 seconds to try to grab report information then 1 in between attempts" -Level Informational
		Start-Sleep -Seconds 10 
		
		
		$Response
		while ($finished -eq $False){
				Write-Progress -Activity "Waiting for scan to finish..." -Status "$Seconds seconds elapsed..." 
				Start-Sleep -Seconds 1
				try{
					$Response = Get-UrlScanResult -Uuid $uid -WarningAction SilentlyContinue
					if ($Response.stats){
						$finished = $True
					}
				}catch{}
				$Seconds++
				if ($Seconds -eq 60) {Write-Log -Message "Something went wrong" -Level Error; return}
				
		}
		Write-Output $Response 
	}
	
}