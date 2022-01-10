> Forked from https://github.com/sysgoblin/PSURLScanio
> I chose to fork and rewrite the repo due to some issues with the current functions and wanted it to suit my needs a bit better. 
> I was inspired heavily by https://github.com/davidhowell-tx/PS-SentinelOne

## 🔎 PSURLScan
🔎 Use urlscan.io with PowerShell!


## Installation and Removal

Installation of this module currently consists of a pair of scripts that will copy the module to one of the PowerShell module paths, and check PowerShell module paths to remove it.

**Install**
```PowerShell
.\Install-Module.ps1
```
**Uninstall**
```PowerShell
.\Uninstall-Module.ps1
```

## Setup

Get an API key from: https://urlscan.io/user/apikey/new/

**Import the Module**
```powershell
Import-Module PSUrlScan
```
**Set your configuration with**
```powershell
Set-UrlscanModuleConfiguration -ApiToken db1b7c43-xxxxx-xxxxx -Persist 
```
(This will save a configuration file with your secured API key at %localappdata%\PS-Urlscan\config.json , use this function again to overwrite a bad config )

## Examples

### Submit a site to be scanned with other parameter examples
```powershell
Invoke-UrlScanSubmission -Url "https://krebsonsecurity.com" -Visibility public -Tags "PSUrlScan" -CustomAgent "PSUrlScan/1.0" -Referer "https://urlscan.io"


message    : Submission successful
uuid       : 0d6dbe0b-1eee-4e5d-8f88-b59a42d8988f
result     : https://urlscan.io/result/0d6dbe0b-1eee-4e5d-8f88-b59a42d8988f/
api        : https://urlscan.io/api/v1/result/0d6dbe0b-1eee-4e5d-8f88-b59a42d8988f/
visibility : public
options    : @{useragent=PSUrlScan/1.0; headers=}
url        : https://krebsonsecurity.com
```

### Displays timer and waits for scan result
```powershell
Watch-UrlScanSubmission -Url "https://urlscan.io" -Visibility public

data      : @{requests=System.Object[]; cookies=System.Object[]; console=System.Object[]; links=System.Object[]; timing=; globals=System.Object[]}
stats     : @{resourceStats=System.Object[]; protocolStats=System.Object[]; tlsStats=System.Object[]; serverStats=System.Object[]; domainStats=System.Object[];
            regDomainStats=System.Object[]; secureRequests=52; securePercentage=100; IPv6Percentage=80; uniqCountries=1; totalLinks=8; malicious=0; adBlocked=0; ipStats=System.Object[]}
meta      : @{processors=}
task      : @{uuid=bfbc6608-49e5-47cd-a6cd-e8fae81294ed; time=2021-04-25T18:50:43.438Z; url=https://urlscan.io; visibility=public; options=; method=api; source=5ef6d1f8;
            tags=System.Object[]; userAgent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.72 Safari/537.36;
            reportURL=https://urlscan.io/result/bfbc6608-49e5-47cd-a6cd-e8fae81294ed/; screenshotURL=https://urlscan.io/screenshots/bfbc6608-49e5-47cd-a6cd-e8fae81294ed.png;
            domURL=https://urlscan.io/dom/bfbc6608-49e5-47cd-a6cd-e8fae81294ed/}
page      : @{url=https://urlscan.io/; domain=urlscan.io; country=DE; city=; server=nginx; ip=148.251.45.170; ptr=urlscan.io; asn=AS24940; asnname=HETZNER-AS, DE}
lists     : @{ips=System.Object[]; countries=System.Object[]; asns=System.Object[]; domains=System.Object[]; servers=System.Object[]; urls=System.Object[]; linkDomains=System.Object[];
            certificates=System.Object[]; hashes=System.Object[]}
verdicts  : @{overall=; urlscan=; engines=; community=}
submitter : @{country=US}
```

### Does the same but outputs the result's screenshot to the C:\temp\ directory with the name uuid.png
```powershell
(Watch-UrlScanSubmission -Url "https://urlscan.io" -Visibility public).task.uuid | Get-UrlScanResult -Screenshot -Path "C:\temp\"
```

### Searches urlscan.io submisssions, Query parameter accepts elastic search parameters, read more at: https://urlscan.io/docs/search/
```powershell
Search-UrlScan -Query domain:urlscan.io -Size 1


indexedAt  : 2021-04-25T18:51:03.715Z
task       : @{visibility=public; method=api; domain=urlscan.io; time=2021-04-25T18:50:43.438Z; uuid=bfbc6608-49e5-47cd-a6cd-e8fae81294ed; url=https://urlscan.io}
stats      : @{uniqIPs=5; consoleMsgs=0; uniqCountries=1; dataLength=2089162; encodedDataLength=1541612; requests=52}
page       : @{country=DE; server=nginx; domain=urlscan.io; ip=148.251.45.170; mimeType=text/html; asnname=HETZNER-AS, DE; asn=AS24940; url=https://urlscan.io/;
             ptr=urlscan.io; status=200}
_id        : bfbc6608-49e5-47cd-a6cd-e8fae81294ed
sort       : {1619376643438, bfbc6608-49e5-47cd-a6cd-e8fae81294ed}
result     : https://urlscan.io/api/v1/result/bfbc6608-49e5-47cd-a6cd-e8fae81294ed/
screenshot : https://urlscan.io/screenshots/bfbc6608-49e5-47cd-a6cd-e8fae81294ed.png
```


### Get a result
```powershell
Get-UrlScanResult -Uuid bfbc6608-49e5-47cd-a6cd-e8fae81294ed

data      : @{requests=System.Object[]; cookies=System.Object[]; console=System.Object[]; links=System.Object[]; timing=; globals=System.Object[]}
stats     : @{resourceStats=System.Object[]; protocolStats=System.Object[]; tlsStats=System.Object[]; serverStats=System.Object[]; domainStats=System.Object[];
            regDomainStats=System.Object[]; secureRequests=52; securePercentage=100; IPv6Percentage=80; uniqCountries=1; totalLinks=8; malicious=0; adBlocked=0;
            ipStats=System.Object[]}
meta      : @{processors=}
task      : @{uuid=bfbc6608-49e5-47cd-a6cd-e8fae81294ed; time=2021-04-25T18:50:43.438Z; url=https://urlscan.io; visibility=public; options=; method=api;
            source=5ef6d1f8; tags=System.Object[]; userAgent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.72
            Safari/537.36; reportURL=https://urlscan.io/result/bfbc6608-49e5-47cd-a6cd-e8fae81294ed/;
            screenshotURL=https://urlscan.io/screenshots/bfbc6608-49e5-47cd-a6cd-e8fae81294ed.png;
            domURL=https://urlscan.io/dom/bfbc6608-49e5-47cd-a6cd-e8fae81294ed/}
page      : @{url=https://urlscan.io/; domain=urlscan.io; country=DE; city=; server=nginx; ip=148.251.45.170; ptr=urlscan.io; asn=AS24940; asnname=HETZNER-AS, DE}
lists     : @{ips=System.Object[]; countries=System.Object[]; asns=System.Object[]; domains=System.Object[]; servers=System.Object[]; urls=System.Object[];
            linkDomains=System.Object[]; certificates=System.Object[]; hashes=System.Object[]}
verdicts  : @{overall=; urlscan=; engines=; community=}
submitter : @{country=US}
```
### Get a result has a type parameter that will either return api meta data by default or the result page's dom or a screenshot to the local or specified directory.
```powershell
Get-UrlScanResult -Uuid bfbc6608-49e5-47cd-a6cd-e8fae81294ed -Type dom
Get-UrlScanResult -Uuid bfbc6608-49e5-47cd-a6cd-e8fae81294ed -Type screenshot
Get-UrlScanResult -Uuid bfbc6608-49e5-47cd-a6cd-e8fae81294ed -Type api # This is the default
```

## FAQ 

 - **Can I contribute?**
   - Please! Submit a pull request at your leisure.
 - **Something's broke.**
   - Please submit an issue for it!

## Support

Reach out on twitter <a href="https://twitter.com/MulhernIan" target="_blank">`@MulhernIan`</a>.

