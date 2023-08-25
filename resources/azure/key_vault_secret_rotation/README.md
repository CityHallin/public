# Azure Key Vault Secret Rotation

1. [Overview](#overview)
2. [Requirements](#requirements)
3. [Project Instructions](projectinstructions)
4. [Other Topics](#othertopics)

## Overview <a name="overview"></a>
Azure Key Vaults are a great place to keep secrets that can be fetched by applications, scripts, VMs, etc. so they are not stored in code or on assets. Many organizations tend to not apply an expiration date on these secrets, so the same values are used for long periods of time. Rotating your secrets is a good security practice to help keep endpoints safe in case a secret is leaked. This project demonstrates how automation in Azure can be used to rotate the secrets in a Key Vault and then place that secret inside of needed resources if able to. This project will go through setting up the sections via PowerShell to show the process for your understanding. Other methods can be used to deploy these types of workflows in bulk like Terraform, ARM templates, or Bicep deployments. 

## Requirements <a name="requirements"></a>
The following resources will be required for this project:
- PowerShell and installed Az modules
- Azure Resources
    - Azure Tenant and Subscription   
    - Azure Key Vault   
    - Azure Function App
    - Azure Storage Account (required for the Azure Function App)

## Project Instructions <a name="projectinstructions"></a>
- Download and install the [Azure Functions Core Tool](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=windows%2Cportal%2Cv2%2Cbash&pivots=programming-language-powershell#install-the-azure-functions-core-tools). We will use this a little later to help create and push functions into the Azure Function App from your local machine.

- Open PowerShell and run the following command to make sure the Azure Functions Core Tool is running correctly. You should see a version number appear. You may have to re-start your PowerShell console for the changes to take effect. 
```powershell
func --version
```
<img src="./readme-files/func-version.png" width="300px">
<br />
<br />

- Install the PowerShell Az module set. Use the code below and select "A" when prompted. This will take several minutes. 

```powershell
Install-Module -Name Az
```

- Run the following to log into your Azure Subscription.
```powershell
$loginContext = Connect-AzAccount -SubscriptionName "ENTER YOUR SUBSCRIPTION NAME HERE"
```
- Choose an Azure region you'd like to deploy these project Azure resources into. In this example, I will be using **South Central US**. A list of US regions are below. Use your selected region for all of your deplopyments in this project to keep things simple. 

```powershell
displayName      name
-----------      ----
Central US       centralus
East US          eastus
East US 2        eastus2
North Central US northcentralus
South Central US southcentralus
West Central US  westcentralus
West US          westus
West US 2        westus2
West US 3        westus3
```
- First, we need to create some variables our PowerShell will use during the project. I have filled these out with the entries I will use as an example, but replace these with your own entries. The last command will create a new Azure Resource Group for this project. 

```powershell
#Replace variables below with your own entries. 
#Azure Resource Group name
$resourceGroupName = "kvtest"

#Azure Region selected from above
$region = "southcentralus"

#Azure Key Vault name. Needs to be a globally unique 
#name no one else has.
$keyVaultname = "cityhallinkey"

#Azure Storage Account name. Needs to be a globally unique 
#name no one else has. Only alphanumeric characters.
$stortageAccountName = "cityhallinkvsa"

#Azure Function App name. Needs to be a globally unique name no one else has. 
$functionAppName = "cityhallinkvfa"

#Creates Azure Resource Group
New-AzResourceGroup -Name $resourceGroupname -Location $region
```
- Run the following to create your Azure Key Vault. This Key Vault will use Azure RBAC to grant Key Vault rights instead of the Key Vault Access Policies. 
```powershell
#Create Azure Key Vault
New-AzKeyVault `
    -VaultName $keyVaultname `
    -ResourceGroupName $resourceGroupName `
    -Location $region `
    -Sku "Standard" `
    -EnableRbacAuthorization
```

- Run the following to create an Azure Storage Account and Function App. The Function App will have a System-Managed Identity that will be given access to the Key Vault to adjust secrets. Will also allow your user access to the Key Vault. 
```powershell
#Create Storage Account
New-AzStorageAccount `
    -Name $stortageAccountName `
    -ResourceGroupName $resourceGroupName `
    -Location $region `
    -SkuName Standard_LRS

#Create Azure Function App
New-AzFunctionApp `
    -Name $functionAppName `
    -ResourceGroupName $resourceGroupName `
    -Location $region `
    -StorageAccountName $stortageAccountName `
    -Runtime PowerShell

#Enable Managed ID on Function App
Update-AzFunctionApp `
    -Name $functionAppName `
    -ResourceGroupName $resourceGroupName `
    -IdentityType SystemAssigned `
    -Force

#Get Azure Function App Info
$functionAppResource = Get-AzResource `
                         -Name $functionAppName `
                         -ResourceGroupName $resourceGroupName `
                         -ResourceType "Microsoft.Web/sites"

#Add Azure Function App to Key Vault role assignment
New-AzRoleAssignment `
    -ObjectId $($functionAppResource.Identity.PrincipalId) `
    -RoleDefinitionName "Key Vault Secrets Officer" `
    -Scope $($keyVaultInfo.resourceid)

#Allow your user access to the Key Vault
New-AzRoleAssignment `
    -SignInName $($loginContext.Account.Id) `
    -RoleDefinitionName "Key Vault Secrets Officer" `
    -Scope $($keyVaultInfo.resourceid)
```
- Run the following to create a new secret called **securepassword** in the Key Vault that will expire in 60 days.

```powershell
#Create new secure string
$characterSet = "!@#%&0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
$newSecret = ($characterSet.tochararray() | Sort-Object {Get-Random})[0..20] -join ''
$newSecretSecure = ConvertTo-SecureString -String $newSecret -AsPlainText -Force
$Expires = (Get-Date).AddDays(60).ToUniversalTime()
$newSecret = $null

#Create new Key Vault secret with secure string
Set-AzKeyVaultSecret `
    -VaultName $keyVaultname `
    -Name 'securepassword' `
    -SecretValue $newSecretSecure `
    -Expires $Expires
```

- Run the following commands which will auto-create a new function project folder with supporting files, navigate inside that project folder, and create the needed PowerShell function files. 
```powershell
#Initializes Function App Folder on your local machine
func init function_project --powershell

#Navigate into that Function Folder
cd function_project

#Create A Function PowerShell inside the Function App Folder using the IoT template
func new --name kvfunction --template "Timer trigger"
```
- Inside the .\function_project\kvfunction folder, you'll see a **run.ps1** file. Update this run.ps1 file with the following and save it. This PowerShell script is the heart of your function and actually does the work of creating a new secure string and updating the key vault secret with the new secure string. You can add additional code as well to update other resources with this new secure string. This Azure Function App System-Managed Identity would just need access to that resource to replace its secret. 

    > Update the $keyVaultName and $keyVaultSecretName variables in this script below with your information for this project.

```powershell
#Parameters
param($Timer)
$keyVaultName = "ENTER KEY VAULT NAME HERE"
$keyVaultSecretName = "ENTER KEY VAULT SECRET NAME HERE"

#Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()

#The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

#Generate new secret secure string
$secretLength = 20
Write-Output "Generating new $secretLength character secret value for Key Vault=$($keyVaultName), Secret name=$($keyVaultSecretName)"
$characterSet = "!@#%&0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
$newSecretPlain = ($characterSet.tochararray() | Sort-Object {Get-Random})[0..20] -join ''
$newSecretSecure = ConvertTo-SecureString -String $newSecretPlain -AsPlainText -Force
$Expires = (Get-Date).AddDays(60).ToUniversalTime()
Start-Sleep 5

#Set new Key Vault Secret Version
Write-Output "Saving new secret value for Key Vault=$($keyVaultName), Secret name=$($keyVaultSecretName)"
$Expires = (Get-Date).AddDays(60).ToUniversalTime()
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $keyVaultSecretName -SecretValue $newSecretSecure -Expires $Expires

#Add additional code here to apply this new secret to other apps or resources
<#  Additional Code  #>
```
- Inside the .\function_project\kfunction folder, you'll see a **function.json** file. Update this function.json file with the following and save it. The schedule attribute is used to trigger this function at certain times (below is triggering this at 11:00pm on the 1st of every month). Review the Microsoft [Azure Trigger docs](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-timer?tabs=python-v2%2Cin-process&pivots=programming-language-powershell#ncrontab-expressions) for more information on how to set this. 
```json
{
  "bindings": [
    {
      "name": "Timer",
      "type": "timerTrigger",
      "direction": "in",
      "schedule": "0 0 23 1 * *"
    }
  ]
}
```

- Inside the .\function_project folder, you'll see a **requirements.ps1** file. Update this requirements.ps1 file with the following and save it. This tells your function it needs to download certain PowerShell modules that it will use.
```powershell
# This file enables modules to be automatically managed by the Functions service.
# See https://aka.ms/functionsmanageddependency for additional information.
#
@{
    # For latest supported version, go to 'https://www.powershellgallery.com/packages/Az'. 
    # To use the Az module in your function app, please uncomment the line below.
     'Az.Accounts' = '2.*'
     'Az.KeyVault' = '4.*'
}
```
- Make sure your PowerShell console is in the parent **function_project** directory holding all your function files. Run the following to push all of your function files to the Azure Function App. You should see the function in your Azure Function App after it completes. 
```powershell
#Navigate into that Function Folder
cd function_project

#Push code to the Azure Function App
func azure functionapp publish $functionAppName
```
- Now that the function is deployed, it will trigger on your schedule updating the Azure Key Vault secret on an interval. 


## Other Topics <a name="othertopics"></a>
### Event Grid
- Azure Key Vaults generate events when certain actions happen. For example, when a secret is about to expire or expires, events are generated. An Azure Event Grid System Topic can be created that will expose these Key Vault events. An Event Subscription can be created off the Event Grid System Topic to then trigger something like an Azure Function App that can perform actions once the event happens.

- Azure Event Grids can be used to create Azure Monitor Alerts. In the Azure Event Grid System Topic, navigate to its Diagnostic Settings menu option and set it to forward logs to an Azure Log Analytics Workspace. Create an Azure Monitor Alert to scan the Log Analytics Workspace for specific Key Vault events. You can trigger things like email alerts, Azure Function App triggers, etc. when the alerts fires. 
