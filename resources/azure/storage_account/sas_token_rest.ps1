
<#
    .SYNOPSIS
    Storage Account SAS Token

    .DESCRIPTION
    Example PowerShell that demonstrates accessing a Storage Account
    blob container using a SAS URL via a REST call. 

#>

#Log into Azure with account that has access
#to a Storage Account we will test with
Write-Host "`nLog into Azure" -ForegroundColor Yellow
Connect-AzAccount

#User prompts for Storage Acocunt Information
Write-Host "`nEnter Azure Storage Account Resource Group Name" -ForegroundColor Yellow
$saRGName = Read-Host " "

Write-Host "`nEnter Azure Storage Account Name" -ForegroundColor Yellow
$saName = Read-Host " "

Write-Host "`nEnter Azure Storage Account Container name" -ForegroundColor Yellow
$saContainerName = Read-Host " "

Write-Host "`nEnter Azure Storage Account Access Key" -ForegroundColor Yellow
$saAccessKeySecure = Read-Host " " -AsSecureString

#Build SAS query parameters and signature

    #Declare the query parameters attributes that will be used
    #https://learn.microsoft.com/en-us/rest/api/storageservices/create-account-sas#specify-the-account-sas-parameters
    $signedVersion = "2022-11-02" #API Version
    $signedServices = "b" #Type of service like blob, queue, etc. This example is only using "b" for blob
    $signedResourceTypes = "c" #Resource Type like Service, container, or objects. This example is using "c" for container only. 
    $signedPermissions = "rwl" #Permissions like Read, Wreite, etc. Thisd is using "r" Read, "w" Write, and "l" for list. 
    $signedExpiry = "$(((Get-Date).AddDays(1)).ToString("s"))" #Set exp[iration date in ISO 8601 UTC format
    $signedProtocol = "https" #Set protocol. This example only using HTTPS.

    #Build query paramter string for the SAS URL
    $query = "sv=$($signedVersion)&ss=$($signedServices)&srt=$($signedResourceTypes)&sp=$($signedPermissions)&se=$($signedExpiry)&spr=$($signedProtocol)"
    $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
    $hmacsha.key = [Convert]::FromBase64String($(ConvertFrom-SecureString $saAccessKeySecure -AsPlainText))
    $signature = $hmacsha.ComputeHash([Text.Encoding]::UTF8.GetBytes($query))
    $signature = [Convert]::ToBase64String($signature)
    $urlFormattedSignature = $([System.Web.HttpUtility]::UrlEncode($signature))
    $sasURL = "$($query)&sig=$($urlFormattedSignature)"

#Build full SAS URL
$url = "https://$($saName).blob.core.windows.net/$($saContainerName)/?restype=container&comp=list&$($sasURL)"


#Sent HTTP request
$time = (Get-Date).ToUniversalTime().toString('R') #This format of timestamp required when sending HTTP requests to Storage Account sin the HTTP header
$header = @{
    'x-ms-date'  = $time  
}
$request = Invoke-RestMethod -Method GET -Uri $url -Headers $header -ContentType "application/json"
