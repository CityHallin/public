
<#
    .SYNOPSIS
    WinRM Setup

    .DESCRIPTION
    This PowerShell script sets up WinRM over HTTPS
    on the Windows VM so it is Ansible ready.
        
#>

#Variables
#Set $winrmAllowedIPs variable to IPs allowed to send WinRM HTTPS traffic to this VM.
#Setting to "*" will allow all IPs. If this is used, make sure to restrict WinRM HTTPS connections 
#to approved networks via a firewall. 
$winrmAllowedIPs = "*"

#Remove old WinRM listeners
Remove-Item -Path WSMan:\localhost\Listener\* -Recurse -Force

#Create Local SSL cert to use with WinRM via HTTPS
$cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "cert"
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address $winrmAllowedIPs -CertificateThumbPrint $cert.Thumbprint -Force

winrm quickconfig -q
winrm set "winrm/config/service/auth" '@{Basic="false"}'
winrm set "winrm/config/client/auth" '@{Basic="false"}'
winrm set "winrm/config/listener?Address=*+Transport=HTTPS" "@{Port=`"5986`";Hostname=`"ansible`";CertificateThumbprint=`"$($Cert.Thumbprint)`"}"

#Add registry entry for Ansible fix https://github.com/ansible/ansible/issues/42978
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LocalAccountTokenFilterPolicy" -Value 1

#Add local server FW rules on VM
Remove-NetFirewallRule -DisplayName "HTTPS WinRM" -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "HTTPS WinRM" -Group "Remote Management" -Direction Inbound -LocalPort 5986 -Protocol TCP -Action Allow
