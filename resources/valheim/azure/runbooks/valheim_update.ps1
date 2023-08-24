
<#
    .SYNOPSIS
    Valheim Update

    .DESCRIPTION
    This PowerShell script kicks off an update process for the 
    Valheim dedicated server install on an Azure VM.
        
#>

#Global Variables
$timestamp = Get-Date -Format "yyyy-MM-dd.HH.mm.ss"
$valheimServerName = "valheimserver"
$valheimServerFolder = "c:\$($valheimServerName)"
$valheimGameFilesFolder = "$($valheimServerFolder)\gamefiles"
$valheimUpdateLogFile = "$($valheimGameFilesFolder)\logs\$($valheimServerName)_update_log_$($timestamp).txt"
$scheduledTaskName = "Valheim_Start"

#Start log file
Start-Transcript -Path $valheimUpdateLogFile

#Set SteamCMD location
Set-Location -Path "$valheimServerName\steamcmd"

#Stop Valheim Scheduled Task
Write-Output "INFO: Stopping Valheim Schedules Task"
Stop-ScheduledTask -TaskName $scheduledTaskName

#Run SteamCMD update process
Write-Host "INFO: Install Valheim Dedicated Server"
cmd.exe /c steamcmd.exe +force_install_dir $valheimGameFilesFolder +login anonymous +app_update 896660 validate +quit
Start-Sleep 10

#Start Valheim Scheduled Task
Write-Output "INFO: Starting Valheim Schedules Task"
Start-ScheduledTask -TaskName $scheduledTaskName
Start-Sleep 5

#Stop log
Write-Output "INFO: Complete"
Stop-Transcript

