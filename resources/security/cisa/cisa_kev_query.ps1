
<#
    .SYNOPSIS
    CISA KEV Query

    .DESCRIPTION
    Simple, example PowerShell script that queries the Known Exploited Vulnerabilities (KEV) Catalog 
    from the federal Cybersecurity and Infrastructure Security Agency (CISA). It pulls the JSON data
    from the website and displays in the PowerShell console. https://www.cisa.gov/known-exploited-vulnerabilities-catalog

#>

#URL
$url = "https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json"

#Web Request
$result = Invoke-WebRequest -Uri $url -Method Get
$kevList = ConvertFrom-Json $result

#Information display examples

    # Latest records
    $latestRecords = 5
    $kevList.vulnerabilities `
        | Sort-Object -Property dateAdded -Descending `
        | Select-Object -First $latestRecords `
        | Format-Table cveID,dateadded,vendorProject,product,vulnerabilityName,shortDescription

    #Specific products
    $productSearch = "chrom"
    $kevList.vulnerabilities `
        | Sort-Object -Property dateAdded -Descending `
        | Where-Object {$_.product -like "*$productSearch*"} `
        | Format-Table cveID,dateadded,vendorProject,product,vulnerabilityName,shortDescription

