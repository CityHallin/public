
<#
    .SYNOPSIS
    Storage Account SAS Token

    .DESCRIPTION
    Example PowerShell that demonstrates accessing a Storage Account
    blob container using a SAS URL created with PowerShell Modules

    Dependencies:
    - Azure Storage Account
    - PowerShell modules installed:
      - Az.Accounts
      - Az.Resources
      - Az.Storage

#>

#Check for installed Az PowerShell modules
Write-Host "`nChecking Installed PowerShell Modules" -ForegroundColor Yellow
$moduleList = ("Az.Accounts","Az.Storage")
$moduleInstalled = $true
foreach ($module in $moduleList) {
    $moduleCheck = Get-InstalledModule -Name $module -ErrorAction SilentlyContinue
    If ($null -eq $moduleCheck) {
        $moduleInstalled = $false
        Write-Host " - module not installed: $module" -ForegroundColor Red
    }
    Else {
        Write-Host " - module installed: $module" -ForegroundColor Green
    }
}
If ($moduleInstalled -eq $false) {
    Write-Host "`nCheck PowerShell modules that need to be installed" -ForegroundColor Red
    Read-Host "Press enter to end script"
    exit
}

#Log into Azure with account that has access
#to a Storage Account we will test with
Write-Host "`nLog into Azure" -ForegroundColor Yellow
$azureLogin = Connect-AzAccount

#User prompts for Storage Acocunt Information
Write-Host "`nEnter Azure Storage Account Resource Group Name" -ForegroundColor Yellow
$saRGName = Read-Host " "

Write-Host "`nEnter Azure Storage Account Name" -ForegroundColor Yellow
$saName = Read-Host " "

Write-Host "`nEnter Azure Storage Account Access Key" -ForegroundColor Yellow
$saAccessKeySecure = Read-Host " " -AsSecureString

#Get Storrage Account access allowing your user 
#to interact with the Storage Account via PowerShell
Write-Host "`nGenerate Storage Acocunt Context" -ForegroundColor Yellow
$saContext = New-AzStorageContext -StorageAccountName $saName -StorageAccountKey $(ConvertFrom-SecureString $saAccessKeySecure -AsPlainText)

#Build SAS URL
#List of Permissions available (https://learn.microsoft.com/en-us/rest/api/storageservices/create-account-sas?redirectedfrom=MSDN#blob-service)
Write-Host "`nCreate Example SAS Token" -ForegroundColor Yellow
$sasURL = New-AzStorageAccountSASToken `
    -Service Blob `
    -ResourceType Service,Container,Object `
    -Permission "rlw" `
    -ExpiryTime (Get-Date).AddDays(1) `
    -Context $saContext

#Get Storage Account FQDN
Write-Host "`nTreat the SAS Token like a senstive password!" -ForegroundColor Yellow
Write-Host "`nSAS Token: " -ForegroundColor Yellow -NoNewline
Write-Host "$($sasURL)" -ForegroundColor Magenta
Read-Host "Press any key to close script"

