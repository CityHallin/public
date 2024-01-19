
<#
    .SYNOPSIS
    Create Document Item in Azure CosmosDB

    .DESCRIPTION
    Powershell to create an document item in CosmosDB container via HTTP POST. CosmosDB uses
    Partition Key = "id" for this example. CosmosDB account must already be created with a database 
    and container.

#>

#User prompts
Write-Host "`nEnter CosmosDB Account Name (not URL, just resource name)" -ForegroundColor Yellow 
$cosmosDBAccountName = Read-Host " "
Write-Host "`nEnter CosmosDB Database Name" -ForegroundColor Yellow 
$databaseId = Read-Host " "
Write-Host "`nEnter CosmosDB Container Name" -ForegroundColor Yellow 
$collectionId = Read-Host " "
Write-Host "`nEnter CosmosDB Read-Write Key" -ForegroundColor Yellow 
$key = Read-Host " " -AsSecureString

#Build HTTP request link and other parameters
#id property in this example will be a random GUID
$partitionKey = New-Guid 
$verb = "POST"
$keyType = "master"
$tokenVersion = "1.0"
$dateTime = [DateTime]::UtcNow.ToString("r")
$cosmosDBEndPoint = "https://$($cosmosDBAccountName).documents.azure.com"
$resourceType = "docs"
$resourceLink = "dbs/$($databaseId)/colls/$($collectionId)"
$queryUri = "$($cosmosDBEndPoint)/$($resourceLink)/docs"

#Build Authentication for HTTP header
$hmacSha256 = New-Object System.Security.Cryptography.HMACSHA256
$hmacSha256.Key = [System.Convert]::FromBase64String($(ConvertFrom-SecureString $key -AsPlainText)) 
$payLoad = "$($verb.ToLowerInvariant())`n$($resourceType.ToLowerInvariant())`n$resourceLink`n$($dateTime.ToLowerInvariant())`n`n"
$hashPayLoad = $hmacSha256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($payLoad))
$signature = [System.Convert]::ToBase64String($hashPayLoad) 
$authHeader = [System.Web.HttpUtility]::UrlEncode("type=$($keyType)&ver=$($tokenVersion)&sig=$($signature)")

#Build HTTP header
$header = @{
    "Accept"                                       = "application/json";
    "Content-Type"                                 = 'application/json';
    "authorization"                                = $authHeader;
    "x-ms-version"                                 = "2018-12-31";
    "x-ms-date"                                    = $dateTime;
    "x-ms-query-enable-crosspartition"             = $true;    
    "x-ms-documentdb-query-enablecrosspartition"   = $true;
    "x-ms-documentdb-partitionkey"                 = "[`"$partitionKey`"]"
}

#Example JSON body to save as a database item
$body = @"
{
    "id": "$partitionKey",
    "profile": {
      "name": "FIRST_LAST_NAME",
      "label": "LABEL_NAME",
      "image": "IMAGE_URL",
      "url": "PERSONAL_WEBSITE_URL"
    }
}
"@

#HTTP request and output from request
$result = Invoke-RestMethod -Method $Verb -Uri $queryUri -Headers $header -Body $body
Write-Host "`nOutput" -ForegroundColor Yellow 
$result | Format-List
