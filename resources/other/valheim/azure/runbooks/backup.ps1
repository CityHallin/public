
<#
    .SYNOPSIS
    Valheim Backup

    .DESCRIPTION
    This PowerShell script kicks off a world backup on a Windows
    Valheim dedicated server to a zip file. Zip file then uploaded
    to an Azure Storage Account Container based on the Azure VMs
    system-managed identity for authentication.
        
#>

#Global Variables
$timestamp = Get-Date -Format "yyyy-MM-dd.HH.mm.ss"
$valheimServerName = "valheimserver"
$valheimServerFolder = "c:\$($valheimServerName)"
$valheimGameFilesFolder = "$($valheimServerFolder)\gamefiles"
$valheimWorldFolder = "$($valheimGameFilesFolder)\world\worlds_local"
$valheimBackupLogFile = "$($valheimGameFilesFolder)\logs\$($valheimServerName)_backup_log_$($timestamp).txt"
$valheimBackupFolder = "C:\valheimbackups"
$valheimWorldBackupTempFolder = "$($valheimBackupFolder)\world_backup_$($timestamp)"

#Start log file
Start-Transcript -Path $valheimBackupLogFile

#Check if backup folder is created
$backFolderCheck = Test-Path -Path $valheimBackupFolder
If ($backFolderCheck -eq $false) {
    Write-Output "INFO: Create backup folder"
    New-Item -ItemType Directory $valheimBackupFolder
}

#Build temp backup folder
Write-Output "INFO: Creating temp backup folder"
New-Item -ItemType Directory $valheimWorldBackupTempFolder | Out-Null

#Copy world content to temp backup folder
Write-Output "INFO: Copying world to temp backup folder"
Copy-Item -Path "$valheimWorldFolder\*" -Destination $valheimWorldBackupTempFolder -Recurse

#Zip temp backup folder
Write-Output "INFO: Zipping temp backup folder"
Compress-Archive -Path "$($valheimWorldBackupTempFolder)\*.*" -DestinationPath "$($valheimWorldBackupTempFolder).zip"
Start-Sleep 5

#Check backup ZIP folder created
$ZipCheck = Test-path -Path "$($valheimWorldBackupTempFolder).zip"
If ($ZipCheck -eq $true) {
    Write-Output "INFO: Clean-up temp backup folder"
    Remove-Item -Path $valheimWorldBackupTempFolder -Recurse -Confirm:$false
}
Else {        
    throw (Write-Error -Message "ZIP of backup failed")
    exit
}

#Pause
Start-sleep 5

#Get VM Identity Context and Storage Account info
Write-Output "INFO: Get Azure Context and Storage Info"
$azureContext = (Connect-AzAccount -Identity).Context
$saInfo = Get-AzResource | Where-Object {$_.ResourceType -like "*Microsoft.Storage/storageAccounts*"}
$ctx = New-AzStorageContext -StorageAccountName $saInfo.name -UseConnectedAccount

#Save Backup to Azure Blob
Write-Output "INFO: Save backup to Azure Storage Account"
$containerCheck = Get-AzStorageContainer -Context $ctx | where-object {$_.Name -like "*backup*"}
If ($containerCheck.Name -like "*backup*") {    
    $blobInfo = @{
        File             = "$($valheimWorldBackupTempFolder).zip"
        Container        = $containerCheck.Name
         Blob             = "world_backup_$($timestamp)"
        Context          = $ctx
        StandardBlobTier = 'Hot'
    }
    Set-AzStorageBlobContent @blobInfo
}
Else {
    throw (Write-Error -Message "Could not connect to Azure Storage Account container")
}

#Backup check
$blobCheck = Get-AzStorageBlob -Context $ctx -Container "valheim-backup" -Blob "world_backup_$($timestamp)" -ErrorAction SilentlyContinue
If ($blobCheck.name -eq "world_backup_$($timestamp)") {
    Write-Output "INFO: Azure backup successful"
}
Else {        
        throw (Write-Error -Message "Azure blob save filed")
        exit
}
