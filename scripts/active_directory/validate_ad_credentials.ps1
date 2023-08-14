
<#
    .SYNOPSIS
    Validate AD Credentials

    .DESCRIPTION
    Simple script to validate if AD credentials are correct. 
    Machine needs to be attached to an AD domain. 

#>

#Gather AD username and password from user prompt
Write-Host "Enter Active Directory Credentials" -ForegroundColor Yellow
Start-Sleep 1
$cred = Get-Credential 
$username = $cred.username
$password = $cred.GetNetworkCredential().password

 #Use base domain CN query to validate provided credentials
 $domainQuery = "LDAP://" + ([ADSI]"").distinguishedName
 $domainObject = New-Object System.DirectoryServices.DirectoryEntry($domainQuery,$username,$password)
if ($null -eq $domainObject.name)
{
    Write-Host "Authentication failed: Please verify your username or password is correct" -ForegroundColor Red
    Read-Host "Press any key to close script"
    exit
}
else
{
    Write-Host "Authentication successful" -ForegroundColor Green
    Read-Host "Press any key to close script"
    exit
}

#Clean-up
$cred = $null
$username = $null
$password = $null