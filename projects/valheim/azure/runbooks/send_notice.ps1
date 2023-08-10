
<#
    .SYNOPSIS
    Discord Webhook Notifications

    .DESCRIPTION
    This PowerShell script is meant to run inside Azure Automation Account Runbooks
    used to send HTTP trigger to a Discord server webhook endpoint in order to send
    messages to a Discord server channel. 
           
#>

#Get Discord URI from Automation Account variables
#Must create Discord server Webhook for URI endpoint first
$discordWebhook = Get-AutomationVariable -Name "DiscordAutoMessenger"

#Create Message Payload
Write-output "Create Message Payload"
$content = @"
Valheim Server will shutdown for maintenance from 8:00am - 8:30am CST. This will start in a few minutes. 
"@

$payload = [PSCustomObject]@{
    content = $content
}

$body = $payload | ConvertTo-Json

#Send Message Payload
Write-output "Send Message"
$result = Invoke-WebRequest -uri $discordWebhook -Method POST -Body $body -Headers @{'Content-Type' = 'application/json'}

#Send Status
Write-output "Send Status Code: $($result.StatusCode)"