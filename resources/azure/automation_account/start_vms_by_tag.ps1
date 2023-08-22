
<#
    .SYNOPSIS
    Start Azure VMs based on tag value

    .DESCRIPTION
    This PowerShell script is meant to run inside an Azure Automation Account Runbook that will
    search for Azure VMs with a specific tag value and start them. 
    Automation Accounts are automatically created with Az PowerShell modules pre-installed. 

    ----Requirements----
    - Run inside Azure Automation Account Runbook
    - The Azure Automation Account must have a System-Managed ID attached
    - The System-Managed ID must have a proper Azure role assignment to impact needed Azure VMs
           
#>

#Tag name and value script will search for on VMs
$tagName = "startup"
$tagValue = "4pm"

#Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process | Out-Null

#Connect to Azure with system-assigned managed ID
Write-Output "Logging in with Managed ID"
$context = (Connect-AzAccount -Identity).Context
If ($null -eq $($context.Subscription.name)) {
    throw (Write-Error "Automation Account Managed ID could not log into Azure. Runbook stopped")
    exit
}
Else {
    Write-Output "Logged in successfully. Subscription: $($context.Subscription.name)"
}

#Get VMs with specific tag name and value
Write-Output "Query VMs with tag=$tagName and value=$tagValue"
$vms = Get-AzVM -Status | Where-Object { $_.Tags[$tagName] -eq $tagValue }
If ($vms.count -lt 1) {
    Write-Output "No VMs found with tag=$tagName and value=$tagValue. Runbook stopped"   
    exit
}
Else {
    Write-Output "Found $($vms.count) VM(s) with tag=$tagName and value=$tagValue"
}

#Loop to process power action on select VMs
$jobFailures = @()
Write-Output "Processing VMs for power action"
Foreach ($vm in $vms) {    
    If (($vm.PowerState -eq "VM deallocated") -or ($vm.PowerState -eq "VM stopped")) {
            $powerActionRequest = Start-AzVM -Name $($vm.Name) -ResourceGroupName $($vm.ResourceGroupName) -NoWait #remove -NoWait to force powestate verification before moving to next VM
            Write-Output "VM=$($vm.Name) Current state=$($vm.PowerState). Sending startup signal to VM now"
        }
    Elseif ($vm.PowerState -eq "VM running") {            
            Write-Output "VM=$($vm.Name) Current state=$($vm.PowerState). VM already running. Skipping VM"
        }
    Else {        
        Write-Warning "VM=$($vm.Name) Current state=$($vm.PowerState). Did NOT send startup request to VM. Power state incompatibility"        
        $jobFailures += $vm.Name
    }  
}

#Output power state action failures
Write-Output "Failed VM power actions: $($jobFailures.count). Any failures saved to Runbook Warning and Error sections"
Write-Output $jobFailures

#Runbook finished message
Write-Output "Runbook Complete"
