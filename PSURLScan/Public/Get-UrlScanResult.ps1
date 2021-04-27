function Get-UrlScanResult {
   <#
    .SYNOPSIS
        Wraps result/dom/screenshot endpoints.

    .DESCRIPTION
        gets api result info or saves a screenshot to local folder location. 
    
    .EXAMPLE
        Get-UrlScanResult -Uuid <uuid> -Type dom
		
	.EXAMPLE
		Invoke-UrlScanSubmission -URI https://urlscan.io -uuid | Get-UrlScanResult 
    #>
	
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
		[String]
        $Uuid, 
		
		[Parameter(Mandatory=$False)]
        [Switch]
        $Dom,
		
		[Parameter(Mandatory=$False,ParameterSetName="Screenshot")]
        [Switch]
        $Screenshot,
		
		[Parameter(Mandatory=$False,ParameterSetName="Screenshot")]
		[String]
		$Path
		
	)
	Process {
		$InitializationLog = $MyInvocation.MyCommand.Name
		$MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { $InitializationLog = $InitializationLog + " -$($_.Key) $($_.Value)"}
		Write-Log -Message $InitializationLog -Level Verbose
	
		$URI; $Response;
		if ($Screenshot -and (-not ($Path))){
			Write-Log -Message "You must specify a path with screenshot parameter" -Level Error
			return
		}
		ElseIf ($Screenshot -and ($Path)){
			$Response = Invoke-WebRequest "https://urlscan.io/screenshots/$Uuid.png" -OutFile "$($Path)\$Uuid.png" -UseBasicParsing
		}
		ElseIf($Dom){
			$URI = "/dom/$uuid/"
			if($Path){
				$Response = Invoke-WebRequest "https://urlscan.io$URI" -OutFile "$($Path)\$Uuid.txt" -UseBasicParsing
			}Else{
				$Response = Invoke-UrlScanQuery -endpoint $URI
			}
		}
		Else{
			$URI = "/api/v1/result/$uuid/"
			$Response = Invoke-UrlScanQuery -endpoint $URI
		}
		
		
		Write-Output $Response
	}
}
