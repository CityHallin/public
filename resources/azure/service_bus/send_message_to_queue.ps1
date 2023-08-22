
<#
    .SYNOPSIS
    Send Message to an Azure Service Bus Queue

    .DESCRIPTION
    Example PowerShell that sends JSON messages to an Azure Service Bus Queue.

#>

[Reflection.Assembly]::LoadWithPartialName("System.Web") | out-null

#Prompt user for Azure Service Bus data
Write-Host "Enter Azure Service Bus Queue URL (example: https://testsb.servicebus.windows.net/queuename)" -ForegroundColor Yellow
Write-Host "'/messages' will be automatically appended to the end" -ForegroundColor Yellow
$urlPrompt = Read-Host " "
$url = "$urlPrompt/messages"

Write-Host "`nEnter Azure Service Bus Shared Access Policy Name" -ForegroundColor Yellow
$accessPolicyName = Read-Host " "

Write-Host "`nEnter Azure Service Bus Shared Access Key" -ForegroundColor Yellow
$accessPolicyKeySecure = Read-Host " " -AsSecureString
$accessPolicyKey = ConvertFrom-SecureString $accessPolicyKeySecure -AsPlainText

#Set Token expiration
$timeExpiration = ([DateTimeOffset]::Now.ToUnixTimeSeconds())+300

#Build access token
Write-Host "`nBuilding SAS Access Token" -ForegroundColor Yellow
$urlEncode = [System.Web.HttpUtility]::UrlEncode($url)+ "`n" + [string]$timeExpiration
$HMAC = New-Object System.Security.Cryptography.HMACSHA256
$HMAC.key = [Text.Encoding]::ASCII.GetBytes($accessPolicyKey)
$signature = $HMAC.ComputeHash([Text.Encoding]::ASCII.GetBytes($urlEncode))
$signature = [Convert]::ToBase64String($signature)
$sasAccessToken = "SharedAccessSignature sr=" + [System.Web.HttpUtility]::UrlEncode($url) + "&sig=" + [System.Web.HttpUtility]::UrlEncode($signature) + "&se=" + $timeExpiration + "&skn=" + $accessPolicyName

#Setup header
Write-Host "`nBuilding Request Header and Body" -ForegroundColor Yellow
$header = @{    
    'Authorization'="$($sasAccessToken)"    
}

#Sample JSON for body
$body = @{
    employeeid = "10060"
    firstname = "Sarah"
    lastname = "Rich"
    account = "srich"
} | ConvertTo-Json

#Send REST POST to queue
Write-Host "`nSending Message to Queue" -ForegroundColor Yellow
Try {
    Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json" -Headers $header
    Write-Host "`nMessage sent to queue: $url" -ForegroundColor Green
    Read-Host "Press enter to end script"
}
Catch {
    Write-Host $_
    Write-Host "`nError sending to queue: $url" -ForegroundColor Red
    Read-Host "Press enter to end script"
}

