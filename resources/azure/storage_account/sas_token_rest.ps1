
<#
    .SYNOPSIS
    Storage Account SAS Token

    .DESCRIPTION
    Example PowerShell that demonstrates querrying an Azure Storage Account containers
    using a Shared Access Signature. 

#>

#User prompts for Storage Account Information
Write-Host "`nEnter Azure Storage Account Name" -ForegroundColor Yellow
$saName = Read-Host " "

Write-Host "`nEnter Azure Storage Account Access Key" -ForegroundColor Yellow
$saAccessKeySecure = Read-Host " " -AsSecureString

#Declare the Shared Access Signature parameters
#https://learn.microsoft.com/en-us/rest/api/storageservices/create-account-sas
$signedVersion = "2022-11-02" #API Version
$signedServices = "b" #Type of service like blob, queue, etc. This example is only using "b" for blob
$signedResourceTypes = "sco" #Resource Type like Service, container, or objects. 
$signedPermissions = "l" #Permissions like List, Read, Write, etc.
$signedExpiry = "$((((Get-Date).AddMinutes(5)).ToUniversalTime()).ToString("s"))" #Set expiration date in ISO 8601 UTC format
$signedProtocol = "https" #Set protocol. This example only using HTTPS.

#Build Shared Access Signature attributes that will be signed
$sasRaw = `
    $saName + "`n" + `
    $signedVersion + "`n" + `
    $signedServices + "`n" + `
    $signedResourceTypes + "`n" + `
    $signedPermissions + "`n" + `
    $signedExpiry + "`n" + `
    $signedProtocol + "`n"

#Build Shared Access Signature information that will be included in the URL
$query = "sv=$($signedVersion)&ss=$($signedServices)&srt=$($signedResourceTypes)&sp=$($signedPermissions)&se=$($signedExpiry)Z&spr=$($signedProtocol)"

#Create the signature of the Shared Access Signature attributes
$hmacsha = New-Object System.Security.Cryptography.HMACSHA256
$hmacsha.key = [Convert]::FromBase64String($(ConvertFrom-SecureString $saAccessKeySecure -AsPlainText))
$signature = $hmacsha.ComputeHash([Text.Encoding]::UTF8.GetBytes($sasRaw))
$signature = [Convert]::ToBase64String($signature)
$urlFormattedSignature = $([System.Web.HttpUtility]::UrlEncode($signature))
$sasURL = "$($query)&sig=$($urlFormattedSignature)"

#Build full SAS URL
$url = "https://$($saName).blob.core.windows.net/?restype=container&comp=list&$($sasURL)"

#Sent HTTP request
$time = (Get-Date).ToUniversalTime().toString('R') #This format of timestamp required when sending HTTP requests to Storage Account sin the HTTP header
$header = @{
    'x-ms-date'  = $time
    'x-ms-version' = $signedVersion
}
$request = Invoke-RestMethod -Method GET -Uri $url -Headers $header -ContentType "application/xml"

