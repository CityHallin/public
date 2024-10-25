
<#
    .SYNOPSIS
    Function App Query

    .DESCRIPTION
    script for checking info about Function Apps and their functions.

#>

#region prep

#Log into Azure
Write-Host "`nCheck Azure Login" -ForegroundColor Yellow
$azContext = (az account show 2> $null | ConvertFrom-Json)
If ($null -eq $azContext) {
    Write-Host " - Logging into Azure" -ForegroundColor Yellow
    $azlogout = az logout 2> $null | ConvertFrom-Json
    Start-Sleep 1
    $azLogin = az Login 2> $null | ConvertFrom-Json
    Start-Sleep 1
    $azContext = az account show 2> $null | ConvertFrom-Json

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

#User prompts
Write-Host "`nEnter Resource Group Name holding Function Apps" -ForegroundColor Yellow
$rgName = Read-Host " "

#endregion prep

#region functionGet

#Get list of functions apps
Write-Host "`nGet Function App Info" -ForegroundColor Yellow
$functionArray = @()
$functionApps = az functionapp list --resource-group $rgName 2> $null | ConvertFrom-Json
If ($null -eq $functionApps) {
    Write-Host "`nError: No Function App info found" -ForegroundColor Red
    Read-Host "Press any key to close script"
    exit
}

#Get list of functions and pull data into array
Write-Host "`nGet Info for Functions" -ForegroundColor Yellow
foreach ($functionApp in $functionApps) {

    Write-Host " - query Function App: $($functionApp.name)" -ForegroundColor Yellow
    $functionAppConfig = az functionapp config show --name $($functionApp.name) --resource-group $rgName 2> $null | ConvertFrom-Json  
    $functionAppSettings = az functionapp config appsettings list --name $($functionApp.name) --resource-group $rgName 2> $null | ConvertFrom-Json
    $functionAppConnectionStrings =  az webapp config connection-string list --name $($functionApp.name) --resource-group $rgName 2> $null | ConvertFrom-Json
    $functions = az functionapp function list -g $rgName -n $($functionApp.name) 2> $null | ConvertFrom-Json   

    foreach ($function in $functions) {
        Write-Host "     - query function: $($function.name)" -ForegroundColor Yellow
        #Function Info
        $obj = New-Object System.Object
        $obj | Add-Member -Type NoteProperty -Name "function_Name" -Value $($function.name)
        $obj | Add-Member -Type NoteProperty -Name "function_Disabled" -Value $($function.isDisabled)
        $obj | Add-Member -Type NoteProperty -Name "function_Lang" -Value $($function.language)
        $obj | Add-Member -Type NoteProperty -Name "function_HREF" -Value $($function.href)
        $obj | Add-Member -Type NoteProperty -Name "function_ScriptHREF" -Value $($function.scriptHref)
        $obj | Add-Member -Type NoteProperty -Name "function_InvokeUrlTemplate" -Value $($function.invokeUrlTemplate)

        #Function App Info        
        $obj | Add-Member -Type NoteProperty -Name "functionApp_Name" -Value $($functionApp.name)
        $obj | Add-Member -Type NoteProperty -Name "functionApp_Location" -Value $($functionApp.location)
        $obj | Add-Member -Type NoteProperty -Name "functionApp_State" -Value $($functionApp.state)
        $obj | Add-Member -Type NoteProperty -Name "functionApp_RG" -Value $($functionApp.resourceGroup)
        $obj | Add-Member -Type NoteProperty -Name "functionApp_ServicePlan" -Value $(($functionApp.appServicePlanId).Split("/")[8])
        $obj | Add-Member -Type NoteProperty -Name "functionApp_Hostname" -Value $($functionApp.defaultHostName)
        $obj | Add-Member -Type NoteProperty -Name "functionApp_enabled" -Value $($functionApp.enabled)
        $obj | Add-Member -Type NoteProperty -Name "functionApp_alwaysOn" -Value $($functionAppConfig.alwaysOn)
        $obj | Add-Member -Type NoteProperty -Name "functionApp_scaleLimit" -Value $($functionAppConfig.functionAppScaleLimit)
        $obj | Add-Member -Type NoteProperty -Name "functionApp_minTLSVersion" -Value $($functionAppConfig.minTlsVersion)
        $obj | Add-Member -Type NoteProperty -Name "functionApp_Vnet" -Value $($functionAppConfig.vnetName)
        $obj | Add-Member -Type NoteProperty -Name "functionApp_netFrameworkVersion" -Value $($functionAppConfig.netFrameworkVersion)
        $obj | Add-Member -Type NoteProperty -Name "functionApp_HttpsOnly" -Value $($functionApp.httpsOnly)
        $obj | Add-Member -Type NoteProperty -Name "functionApp_ResourceID" -Value $($functionApp.id)
        $obj | Add-Member -Type NoteProperty -Name "functionApp_LastModified" -Value $($functionApp.lastModifiedTimeUtc)
        $obj | Add-Member -Type NoteProperty -Name "functionApp_ManagedEnvId" -Value $($functionApp.managedEnvironmentId)
        $obj | Add-Member -Type NoteProperty -Name "functionApp_CORS" -Value $(($functionAppConfig.cors | % {"$($_.allowedOrigins)"} | Out-String).Trim())
        $obj | Add-Member -Type NoteProperty -Name "functionApp_AppSettings" -Value $(($functionAppSettings | % {"$($_.name):$($_.value)"} | Out-String).Trim())
        $obj | Add-Member -Type NoteProperty -Name "functionApp_ConnectionStrings" -Value $(($functionAppConnectionStrings | % {"$($_.name):$($_.value)"} | Out-String).Trim())

        #Add object to array
        $functionArray += $obj
    }
}

#CSV Export
Write-Host "`nExport to CSV" -ForegroundColor Yellow
$date = Get-Date -Format "yyyy-MM-dd.HH.mm.ss"
$functionArray | Export-Csv -Path "./function_app_query_$($date).csv" -Force -NoTypeInformation -Verbose

#endregion functionGet