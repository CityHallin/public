
<#
    .SYNOPSIS
    AD User Query Commands

    .DESCRIPTION
    A list of heavily used query commands for AD users. 

    ----Requirements----
    - "activedirectory" PowerShell module installed from 
    RSAT tools

#>

#--------------------------Users--------------------------

#Get general properties for all users in Active Directory
Get-ADUser -Filter *

#Get all properties for all users in Active Directory
Get-ADUser -Filter * -Properties *

#Get select properties for all users in Active Directory
Get-ADUser -Filter * -Properties * | Select-Object -Property Name,Samaccountname,UserPrincipalName,telephoneNumber,Manager

#Get general properties on a single Active Directory user based on their SamAccountName
$userSamAccountName = "ENTER USER SAMACCOUNT NAME HERE"
Get-ADUser -Identity $userSamAccountName

#Get all properties of a single Active Directory user based on their SamAccountName
$userSamAccountName = "ENTER USER SAMACCOUNT NAME HERE"
Get-ADUser -Identity $userSamAccountName -Properties *

#Search for an Active Directory user with a specific SID
$sid = "ENTER USER SID HERE"
Get-ADUser -Filter "SID -eq '$sid'"

#Search for an Active Directory user with a specific UPN
$upn = "ENTER USER UPN HERE"
Get-ADUser -Filter "UserPrincipalName -eq '$upn'"

#Search for all Active Directory users that are not Enabled
Get-ADUser -Filter "Enabled -eq '$False'" | Format-Table

#Search for all Active Directory users with Passwords Expired
Get-ADUser -Filter * -Properties PasswordExpired | Where-Object {$_.PasswordExpired -eq $True} | Format-Table

#Search for all Active Directory users where their Password never Expires
Get-ADUser -Filter "PasswordNeverExpires -eq '$True'" -Properties PasswordNeverExpires | Format-Table

#Search for all Active Directory users where their Account Expiration field is populated
$date = Get-Date
Get-ADUser -Filter "AccountExpirationDate -le '$(($date))' -or AccountExpirationDate -ge '$(($date))'" -Properties AccountExpirationDate | Format-Table

#Search for all Active Directory users where their Account is Expired
$date = Get-Date
Get-ADUser -Filter "AccountExpirationDate -lt '$(($date).AddDays(1))'" -Properties AccountExpirationDate | Format-Table

#--------------------------Managers--------------------------

#Get the users that directly report to a manager
$userSamAccountName = "ENTER MANAGER'S USER SAMACCOUNT NAME HERE"
Get-ADUser -Identity $userSamAccountName -Properties directReports | Select-Object -ExpandProperty directReports

#Get the manager an Active Directory user reports to
$userSamAccountName = "ENTER USER SAMACCOUNT NAME HERE"
Get-ADUser -Identity $userSamAccountName -Properties Manager
