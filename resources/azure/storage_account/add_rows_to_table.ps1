
<#
    .SYNOPSIS
    Add Rows to Azure Tables

    .DESCRIPTION
    Example PowerShell will generate test user
    records as JSON and save the data into Azure Table rows.

    Dependencies:
    - Azure Storage Account
    - Azure Table inside a Storage Account
    - PowerShell modules installed:
      - Az.Accounts
      - Az.Resources
      - Az.Storage
      - AzTable

#>

#Log into Azure
$context = Get-AzContext
If ($null -eq $context) {
    Write-Host "`nNo login context detected. Logging you into Azure" -ForegroundColor Blue
    $context = Connect-AzAccount
    $context = Get-AzContext
    If ($null -eq $context) {
        Write-Host "`nError Logging into Azure" -ForegroundColor Red
        Read-Host "Press enter to exit script"
        exit
    }
    Else {        
        Write-Host "`nLogged into Azure Subscription: $($context.Subscription.Name)" -ForegroundColor Yellow
    }
}
Else {
    Write-Host "`nAlready logged into Azure Subscription: $($context.Subscription.Name)" -ForegroundColor Yellow
}

#Check for installed Az PowerShell modules
Write-Host "`nChecking Installed PowerShell Modules" -ForegroundColor Yellow
$moduleList = ("Az.Accounts","Az.Resources","Az.Storage","AzTable")
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

#Create sample list of user data
Write-Host "`nGenerate List of Records" -ForegroundColor Yellow
$userArray = @()
    #Test user record 1
    $obj = New-Object System.Object
    $obj | Add-Member -NotePropertyName "employeeid" -NotePropertyValue "10060"
    $obj | Add-Member -NotePropertyName "firstname" -NotePropertyValue "Sarah"
    $obj | Add-Member -NotePropertyName "lastname" -NotePropertyValue "Rich"
    $obj | Add-Member -NotePropertyName "age" -NotePropertyValue "56"
    $userArray += $obj

    #Test user record 2
    $obj = New-Object System.Object
    $obj | Add-Member -NotePropertyName "employeeid" -NotePropertyValue "10070"
    $obj | Add-Member -NotePropertyName "firstname" -NotePropertyValue "Aziz"
    $obj | Add-Member -NotePropertyName "lastname" -NotePropertyValue "Raman"
    $obj | Add-Member -NotePropertyName "age" -NotePropertyValue "32"
    $userArray += $obj

#Get list of Storage Accounts to choose from
[array]$saList = (Get-AzResource -ResourceType "Microsoft.Storage/storageAccounts").Name
If ($null -eq $saList) {
    Write-Host "`nNo Azure Storage Accounts detected in this subscription" -ForegroundColor Red
    Read-Host "Press enter to end script"
    exit
}
Do {  
    Write-Host "`nSelect an Azure Storage Account" -ForegroundColor Yellow
    For ($i=0; $i -lt $saList.count; $i++) {
        Write-Host "  $i)`t$($saList[$i])"
    }

    [string]$saItem = Read-Host " "
    $saSelection = $saList[$saItem]
}
Until ($saSelection)

#Get Azure Storage Account access context
$saRGName = (Get-AzResource -Name $saSelection).ResourceGroupName
$saObject = Get-AzStorageAccount -Name $saSelection -ResourceGroupName $saRGName
If (($null -eq $saRGName) -or ($null -eq $saObject)) {
    Write-Host "`nError accessing Storage Account Context" -ForegroundColor Red
    Read-Host "Press enter to end script"
    exit
}
$saAccessContext = $saObject.Context

#Get list of tables in a Storage Acocunt to choose from
[array]$tableList = Get-AzStorageTable -Context $saAccessContext
If ($null -eq $tableList) {
    Write-Host "`nNo Azure Storage Account Tables detected in this Storage Acocunt $saSelection" -ForegroundColor Red
    Read-Host "Press enter to end script"
    exit
}
Do { 
    Write-Host "`nSelect an Azure Storage Account Table" -ForegroundColor Yellow   
    For ($i=0; $i -lt $tableList.count; $i++) {
        Write-Host "  $i)`t$($tableList[$i].Name)"
    }
    
    [string]$tableItem = Read-Host " "
    $tableSelection = ($tableList[$tableItem])
}
Until ($tableSelection)

#Set Partition Key as well as Row Key for new records. 
#If there are no rows in the table, the INT var $lastRowKey will auto-set to zero
$partition = "1"
[int]$lastRowKey = (Get-AzTableRow -table ($tableSelection.CloudTable) | Sort-Object -Property RowKey -Descending | Select-Object -First 1).RowKey

#Add records to Azure Table rows iterating rowkey
Write-Host "`nCreating Azure Table Rows" -ForegroundColor Yellow 
foreach ($row in $userArray) {
    $lastRowKey++
    Add-AzTableRow `
        -table ($tableSelection.CloudTable) `
        -partitionKey $partition `
        -rowKey ($lastRowKey) `
        -property @{
            "employeeid"="$($row.employeeid)"
            "firstname"="$($row.firstname)"
            "lastname"="$($row.lastname)"
            "age"="$($row.employeeid)"
        } | Out-Null
    $rowCheck = Get-AzTableRow -table ($tableSelection.CloudTable) -PartitionKey $partition -RowKey $lastRowKey
    Write-Host " - row created: Partition=$($rowCheck.PartitionKey), Rowkey=$($rowCheck.RowKey), EmployeeID=$($rowCheck.employeeid), FirstName=$($rowCheck.firstname), LastName=$($rowCheck.lastname) " -ForegroundColor Green
}

#Clean-up
Write-Host "`nComplete" -ForegroundColor Yellow 
$tableSelection = $null
$saSelection = $null
