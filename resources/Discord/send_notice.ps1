
<#
    .SYNOPSIS
    Discord Webhook Notifications

    .DESCRIPTION
    This PowerShell script is meant to run inside an Azure Automation Account Runbook
    used to send message posts to a Discord server channel webhook. 
           
#>

#Get Discord URI from Automation Account variables
#Must create Discord server webhook first
$discordWebhook = Get-AutomationVariable -Name "DiscordAutoMessenger"

#Create message payload
Write-output "Create Message Payload"
$content = @"
Text that will be sent as a Discord message post. 
"@

$payload = [PSCustomObject]@{
    content = $content
}

$body = $payload | ConvertTo-Json

#Send message payload
Write-output "Send Message"
$result = Invoke-WebRequest -uri $discordWebhook -Method POST -Body $body -Headers @{'Content-Type' = 'application/json'}

#Send status
Write-output "Send Status Code: $($result.StatusCode)"
