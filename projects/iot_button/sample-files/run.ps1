#Parameters
param($IoTHubMessages, $TriggerMetadata)

#Check JSON request from IoT device. If this does 
#not match "12345" this script will exit immediately.
$claim = $IoTHubMessages.claim
if ($claim -ne "12345") {
    Write-Output "Claim code incorrect or not present. Script exiting"
    exit
}
Else {
    Write-Output "Claim code from IoT device matches: $claim"
}

#Create User Managed Identity
Write-Output "Creating User-Managed Identity"
$random = Get-Random -Minimum 100 -Maximum 999
$umi = New-AzUserAssignedIdentity `
    -ResourceGroupName "iot" `
    -Name "umi-$random" `
    -Location "southcentralus"

#Complete
Write-Output "User-Managed Identity created: $($umi.name)"