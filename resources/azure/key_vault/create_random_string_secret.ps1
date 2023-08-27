
<#
    .SYNOPSIS
    Create Azure Key Vault Secret

    .DESCRIPTION
    Example PowerShell script to create an Azure Key Vault, create
    a random password string, and save that string as a secret in
    the Key Vault. 

    ----Requirements----
    - Az PowerShell modules
           
#>

#Log into Azure
Connect-AzAccount

#Variables
$resourceGroupName = "testkeyvault"
$region = "southcentralus"
$keyVaultName = "cityhallinkvtest"

#Create Azure Resource Group
New-AzResourceGroup `
    -Name $resourceGroupname `
    -Location $region

#Create Azure Key Vault with Azure RBAC instead
#of access policies
New-AzKeyVault `
    -VaultName $keyVaultName `
    -ResourceGroupName $resourceGroupName `
    -Location $region `
    -Sku "Standard" `
    -EnableRbacAuthorization

#Get resource info for role assignment
$loginContext = Get-AzContext
$keyVaultInfo = Get-AzKeyVault `
    -VaultName $keyVaultName `
    -ResourceGroupName $resourceGroupName

#Add your user to Key Vault role assignment
New-AzRoleAssignment `
    -SignInName $($loginContext.Account.Id) `
    -RoleDefinitionName "Key Vault Secrets Officer" `
    -Scope $($keyVaultInfo.resourceid)

#Create new secure string function
function New-KeyVaultSecret {
    $stringSize = 20 #adjust to change password length
    $characterSet = "!@#%&0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    $newSecretPlain = ($characterSet.tochararray() | Sort-Object {Get-Random})[0..$stringSize] -join ''
    $newSecretSecure = ConvertTo-SecureString -String $newSecretPlain -AsPlainText -Force
    return $newSecretSecure   
}

#Set secret expiration date
$secretExpiration = (Get-Date).AddDays(60).ToUniversalTime()

#Create new Key Vault secret with secure string
$secretString = New-KeyVaultSecret
Set-AzKeyVaultSecret `
    -VaultName $keyVaultName `
    -Name 'secretPassword' `
    -SecretValue $secretString `
    -Expires $secretExpiration