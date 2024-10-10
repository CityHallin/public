<#
    .SYNOPSIS
    APIM API Query

    .DESCRIPTION
    Manual script for checking info about APIM APIs. 

#>

#Variables
$apimName = "<APIM_INSTANCE_NAME>"

#Script functions
function Check-AzureLogin {
    #Log into Azure
    Write-Host "`nCheck Azure Login" -ForegroundColor Yellow
    $azContext = Get-AzContext

    If ($null -eq $azContext) {
        Write-Host " - Logging into Azure" -ForegroundColor Yellow
        Disconnect-AzAccount
        Start-Sleep 2
        $azLogin = Connect-AzAccount
        Start-Sleep 1
        $azContext = Get-AzContext

        If ($null -eq $azContext) {
            Write-Host " - Azure login failed" -ForegroundColor Red
            Read-Host "Press any key to close script"
            exit
        } Else {
            Write-Host " - Logged into Azure" -ForegroundColor Green
        } 

    } Else {
        Write-Host " - Already logged into Azure" -ForegroundColor Green
    }    
}

function Check-PSModules {
    param(
    [Parameter()]
    [string[]]
    $modules
    )

    #Import modules
    Write-Host "`nImporting PowerShell Modules" -ForegroundColor Yellow
    $moduleList = $modules
    foreach ($module in $moduleList) {
        Import-Module $module
        $moduleCheck = Get-Module -Name $module -ErrorAction SilentlyContinue
        If ($null -eq $moduleCheck) {
            Write-Host " - PowerShell module $($module) install failed" -ForegroundColor Red
            Read-Host "Press any key to close script"
            exit
        } Else {
            Write-Host " - PowerShell module $($module) installed" -ForegroundColor Green
        }
    }   
}

#Log into Azure
Check-AzureLogin

#Import modules
Check-PSModules -modules ("Az.Accounts","Az.Resources","Az.ApiManagement")

#Get APIM auth content
$apimInfo = Get-AzResource -Name $apimName
$ctx = New-AzApiManagementContext -ResourceGroupName $($apimInfo.ResourceGroupName) -ServiceName $($apimInfo.Name)

#Get all APIM APIs and their revision data
Write-Host "`nGet Lists of APIs from APIM" -ForegroundColor Yellow
$apiList = Get-AzApiManagementApi -Context $ctx
$apiArray = @()
Foreach ($api in $apiList ) {
    #Get API revision info
    $apiRevision = Get-AzApiManagementApiRevision -Context $ctx -ApiId $($api.ApiId)

    #Make obnject with info
    $obj = New-Object System.Object
    $obj | Add-Member -Type NoteProperty -Name "apim_instance" -Value $($api.ServiceName)
    $obj | Add-Member -Type NoteProperty -Name "api_name" -Value $($api.Name)
    $obj | Add-Member -Type NoteProperty -Name "api_id" -Value $($api.ApiId)
    $obj | Add-Member -Type NoteProperty -Name "api_url" -Value $($api.ServiceUrl)
    $obj | Add-Member -Type NoteProperty -Name "api_path" -Value $($api.Path)
    $obj | Add-Member -Type NoteProperty -Name "api_version" -Value $($api.ApiVersion)
    $obj | Add-Member -Type NoteProperty -Name "api_revision_id" -Value $($apiRevision.ApiId)
    $obj | Add-Member -Type NoteProperty -Name "api_revision_creation" -Value $($apiRevision.CreatedDateTime)
    $obj | Add-Member -Type NoteProperty -Name "api_revision_updated" -Value $($apiRevision.UpdatedDateTime)
    $obj | Add-Member -Type NoteProperty -Name "api_revision_private_url" -Value $($apiRevision.PrivateUrl)
    $obj | Add-Member -Type NoteProperty -Name "api_revision_enabled" -Value $($apiRevision.IsOnline)

    #Add object to array
    $apiArray += $obj
}

Write-Host "`nShow API List" -ForegroundColor Yellow
Write-Output $apiArray | Sort-Object -Property "api_revision_private_url" | Format-Table