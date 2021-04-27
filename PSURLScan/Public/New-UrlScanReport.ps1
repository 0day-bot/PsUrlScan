function New-UrlScanReport {
   <#
    .SYNOPSIS
        Grabs urlscan(s) and displays them with a screenshot in html format. 

    .DESCRIPTION
        
    
    .EXAMPLE
        
		
	.EXAMPLE
		New-UrlScanReport -URI "https://microsoft.com/" -Referer "https://google.com" -CustomAgent "PSUrlscan/1.0" -Visibility "public" -Tags @("Test1", "Test2")
    #>
	
    [CmdletBinding()]
	Param (
		[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
		[String[]]
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
		[String]
        $Path = ".",
    
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
	
		$id = @()
		ForEach ($u in $Url){
			$id += Invoke-UrlScanSubmission @Parameters -Uuid -Url $u
			
		}
		Write-Log -Message "Will Wait 10 seconds to try to grab report information then 1 in between attempts" -Level Informational
	 
		$Seconds = 10
		$finished = $False
		
		Start-Sleep -Seconds 10 
		foreach ($uuid in $id) {
			while ($finished -eq $False){
				Write-Progress -Activity "Waiting for scans to finish..." -Status "$Seconds seconds elapsed..." 
				Start-Sleep -Seconds 1
				$Seconds++
				if ($Seconds -eq 60) {Write-Log -Message "Something went wrong" -Level Error; return}
				try{
					$r = Get-UrlScanResult -Uuid $uuid -WarningAction SilentlyContinue
					if ($r.stats){
						$finished = $True
					}
				}catch{}
			}
			$finished = $False
		}
		if (-not (Test-Path "$Path\PSUrlScanReport\")){
			New-Item -ItemType "directory" -Path $("$Path\PSUrlScanReport\") 
		}
		#$Responses = @()
		#$Responses += 
		foreach ($uuid in $id) {
			Get-UrlScanResult -Type screenshot -Uuid $uuid -Path $("$Path\PSUrlScanReport\")
		}
		#Write-Output $Responses
	}
	
}