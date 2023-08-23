
<#
    .SYNOPSIS
    Stop Azure VMs based on tag value

    .DESCRIPTION
    This PowerShell script is meant to run inside Azure Automation Account Runbooks that will
    search for Azure VMs with a specific tag value and shut them down. The shutdown command 
    sent to Azure VMs does not wait for comfirmation before moving onto the next Azure VM. 
           
#>

#Add the specific tag name and value attacehed to VMs this script will search for
$tagname = "shutdown"
$tagValue = "yes"

#Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process | Out-Null

#Connect to Azure with system-assigned managed ID
Write-Output "INFO: Logging in with Automation Account System-Managed ID"
$context = (Connect-AzAccount -Identity).Context

#Set and store login context
If ($null -eq $($context.Subscription.name)) {
    throw (Write-Error -Message "Automation Account System-Managed ID could not log into Azure. Runbook stopped")
    exit
}
Else {
    Write-Output "INFO: Logged in successfully. Subscription=$($context.Subscription.name)"
}

#Get VMs with specific tag key and value
Write-Output "INFO: Query for VMs with tag=$tagname and value=$tagValue"
$vms = Get-AzVM -Status | Where-Object { $_.Tags[$tagname] -eq $tagValue }
If ($vms.count -lt 1) {
    Write-Output -Message "No VMs found with tag=$tagname and value=$tagValue. Runbook stopped"
    Write-Warning -Message "No VMs found with tag=$tagname and value=$tagValue. Runbook stopped"
    exit
}
Else {
    Write-Output "INFO: Found $($vms.count) VMs with tag=$tagname and value=$tagValue"
}

#Loop to process power action on select VMs
$jobFailures = @()
Write-Output "INFO: Processing VMs for power action"
Write-Output "------------------------------------------"
Foreach ($vm in $vms) {    
    If (($vm.PowerState -eq "VM running") -or ($vm.PowerState -eq "VM stopped")) {
        $powerActionRequest = Stop-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Force -NoWait #remove -NoWait to force powestate verification before moving to next VM
            Write-Output "INFO: VM=$($vm.Name) current state=$($vm.PowerState). Sending shutdown signal to VM now"
        }
    Elseif ($vm.PowerState -eq "VM deallocated") {            
            Write-Output "INFO: VM=$($vm.Name) current state=$($vm.PowerState). VM already shutdown. Skipping VM"
        }
    Else {
        Write-Output -Message "WARNING: VM=$($vm.Name) current state=$($vm.PowerState). Did NOT send shutdown request to VM. Power state incompatibility"      
        Write-Warning -Message "VM=$($vm.Name) current state=$($vm.PowerState). Did NOT send shutdown request to VM. Power state incompatibility"
        $jobFailures += $vm.Name
    } 
}

#Output VMs powerstate action was not run on
Write-Output "`nINFO: $($jobFailures.count) out of $($vms.count) VMs failed. Any failures saved to Runbook Warning and Error sections"
Write-Output "------------------------------------------"
Write-Output $jobFailures

#Runbook finished message
Write-Output "`nINFO: Runbook Complete"
