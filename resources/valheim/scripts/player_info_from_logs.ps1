
<#
    .SYNOPSIS
    Player Info from Valheim Logs

    .DESCRIPTION
    Simple PowerShell script used to parse the Valheim game log
    for player connection info. 

#>

#Variables
$valheimlog = "<ENTER VALHEIM GAME LOG LOCATION>"

#Parse log file
$content = Get-content $valheimlog
$content | Where-Object {$_ -match "Got character"}
Read-Host "Press Enter"