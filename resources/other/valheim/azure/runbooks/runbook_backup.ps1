
<#
    .SYNOPSIS
    Azure Automation Account Valheim Backup Job

    .DESCRIPTION
    This PowerShell script is meant to run inside Azure Function Apps or 
    Automation Accounts that will trigger a backup of the Valheim world
    from an Azure Windows VM as well as save a ZIP file of the local 
    backup to an Azure Storage Account Container.    
           
#>

#Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process | Out-Null

#Connect to Azure with system-assigned managed ID
Write-Output "INFO: Logging in with System-Managed ID"
$context = (Connect-AzAccount -Identity).Context

#Set and store login context
If ($null -eq $($context.Subscription.name)) {
    throw (Write-Error -Message "System-Managed ID could not log into Azure. Stopped")
    exit
}
Else {
    Write-Output "INFO: Logged in successfully. Subscription $($context.Subscription.name)"
}

#Import-Modules
Import-Module Az.Accounts
Import-Module Az.Resources
Import-Module Az.Compute

#Get VM Info
$vmInfo = Get-AzResource | Where-Object {($_.ResourceType -eq "Microsoft.Compute/virtualMachines")}

#Run command on Azure VM
$timeStamp = get-date -Format "yyyy.MM.dd.HH.mm.ss"
$url = "https://raw.githubusercontent.com/CityHallin/public/main/projects/valheim/azure/runbooks/backup.ps1"
Set-AzVMRunCommand -ResourceGroupName $($vmInfo.ResourceGroupName) -VMName $($vmInfo.Name) -Location $($vmInfo.Location) -RunCommandName "backup.$timeStamp" -SourceScriptUri $url
Write-Output "INFO: Kicked off backup called: backup.$timeStamp"
