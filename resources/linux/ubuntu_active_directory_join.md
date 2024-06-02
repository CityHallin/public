# Ubuntu Active Directory Joining

## Overview
Linux machines have the ability to join Microsoft Active Directory domains via the sssd service, as well as some other supporting services. 

## Instructions

- You'll first need a home lab Active Directory Domain created. You can use the following instructions for setting up a Domain Controller (DC) for your lab domain: [https://www.ittsystems.com/active-directory-setup-guide](https://www.ittsystems.com/active-directory-setup-guide). The domain controller needs the following requirements:
    - The DC must have DNS services installed along with the Active Directory Domain Service (ADDS). 
    - The DC's DNS service needs a DNS Reverse Lookup Zone for the IP range the DC is in. For example, if your DC's IP address is 10.10.1.4, a DNS Reverse Lookup Zone will need to be created called **1.10.10.in-addr.arpa**.
    - If using an Azure environment for this lab, make sure the Azure Virtual Network's DNS settings have the DC's IP. This way the DHCP address information given to the Linux machine from the Azure Virtual Network will give it the DC's IP for DNS lookups. This is required so the Linux machine can see the domain's DNS for domain the joining processes. 
    - In your lab domain, create two user accounts:
        - An user account that has the ability to join machines to the domain.
        - A standard user account that will be for testing logins to the Linux machine. 

- Build your Linux machine for this lab. In this example, I will be building an Ubuntu 22.04 VM in Azure.

- Once the Linux machine is built, run an upgrade and update process.

```bash
sudo apt upgrade && sudo apt update -y
```

- Install the following packages that will be used to interact with Active Directory.

```bash
sudo apt install realmd sssd-ad sssd-tools smbclient adcli libkrb5-dev krb5-user -y
```

> Note: during this package install if it asks for a Default Kerberos Version 5 Realm, add the domain name of your lab. In this example, I'll be adding my lab domain called **Test.com**. If you're asked to restart any services, accept the defaults and select **OK**.

- Once packages are installed, run the following **realm** command to discover and test your connection to the DC for your lab domain. In this example, my lab domain is called **test.com**. It should come back with an output similar to below showing it can resolve the FQDN of the domain and see the IP of your DC.

```bash
sudo realm -v discover <DOMAIN_FQDN> 
```

```bash
#Example
sudo realm -v discover test.com

* Resolving: _ldap._tcp.test.com
 * Performing LDAP DSE lookup on: 10.10.1.4
 * Successfully discovered: test.com
test.com
  type: kerberos
  realm-name: TEST.COM
  domain-name: test.com
  configured: no
  server-software: active-directory
  client-software: sssd
  required-package: sssd-tools
  required-package: sssd
  required-package: libnss-sss
  required-package: libpam-sss
  required-package: adcli
  required-package: samba-common-bin
```

- Run the **realm** join command below to join your Linux machine to your lab domain. 

```bash
sudo realm join -U <AD_JOINING_ACCOUNT> <DOMAIN_FQDN> -v
```

```bash
#Example
sudo realm join -U domainjoin test.com -v

 * Resolving: _ldap._tcp.test.com
 * Performing LDAP DSE lookup on: 10.10.1.4
 * Successfully discovered: test.com
Password for domainjoin:

 * Unconditionally checking packages
 * Resolving required packages
 * LANG=C /usr/sbin/adcli join --verbose --domain test.com --domain-realm TEST.COM --domain-controller 10.10.1.4 --login-type user --login-user domainjoin --stdin-password
 * Using domain name: test.com
 * Calculated computer account name from fqdn: LAB
 * Using domain realm: test.com
 * Sending NetLogon ping to domain controller: 10.10.1.4
 * Received NetLogon info from: dc-dev.test.com
 * Wrote out krb5.conf snippet to /var/cache/realmd/adcli-krb5-WmuCff/krb5.d/adcli-krb5-conf-KLHN1S
 * Authenticated as user: domainjoin@TEST.COM
 * Using GSS-SPNEGO for SASL bind
 * Looked up short domain name: TEST
 * Looked up domain SID: S-1-5-21-91113698-241282218-2439001757
 * Using fully qualified name: lab
 * Using domain name: test.com
 * Using computer account name: LAB
 * Using domain realm: test.com
 * Calculated computer account name from fqdn: LAB
 * Generated 120 character computer password
 * Using keytab: FILE:/etc/krb5.keytab
 * A computer account for LAB$ does not exist
 * Found well known computer container at: CN=Computers,DC=test,DC=com
 * Calculated computer account: CN=LAB,CN=Computers,DC=test,DC=com
 * Encryption type [3] not permitted.
 * Encryption type [1] not permitted.
 * Created computer account: CN=LAB,CN=Computers,DC=test,DC=com
 * Sending NetLogon ping to domain controller: 10.10.1.4
 * Received NetLogon info from: dc-dev.test.com
 * Set computer password
 * Retrieved kvno '2' for computer account in directory: CN=LAB,CN=Computers,DC=test,DC=com
 * Checking RestrictedKrbHost/LAB
 *    Added RestrictedKrbHost/LAB
 * Checking host/LAB
 *    Added host/LAB
 * Discovered which keytab salt to use
 * Added the entries to the keytab: LAB$@TEST.COM: FILE:/etc/krb5.keytab
 * Added the entries to the keytab: host/LAB@TEST.COM: FILE:/etc/krb5.keytab
 * Added the entries to the keytab: RestrictedKrbHost/LAB@TEST.COM: FILE:/etc/krb5.keytab
 ! Failed to update Kerberos configuration, not fatal, please check manually: Setting attribute standard::type not supported
 * /usr/sbin/update-rc.d sssd enable
 * /usr/sbin/service sssd restart
 * Successfully enrolled machine in realm
```

- Check your Active Directory OU called **Computers** and you should see a new Computer Object named after your Linux Machine. In this example, I see my Ubuntu VM called **Lab**.

```powershell
PS C:\> Get-ADComputer -Identity "lab"


DistinguishedName : CN=LAB,CN=Computers,DC=test,DC=com
DNSHostName       : lab
Enabled           : True
Name              : LAB
ObjectClass       : computer
ObjectGUID        : 86b40ba6-86d2-46c8-bce0-d5f4206d76d5
SamAccountName    : LAB$
SID               : S-1-5-21-91113698-241282218-2439001757-1110
```

- The last step is to enable the auto-home directory feature for AD accounts used to log into this Linux machine. Just run the command below.

```bash
sudo pam-auth-update --enable mkhomedir
```

- To test your access, run the following command to lookup your standard user in AD you created earlier. In the example below, I create a standard user in my AD called **test@test.com**.

```bash
getent passwd <user_name>@<domain>
```

```bash
#Example
getent passwd test@test.com

test@test.com:*:137401106:137400513:test:/home/test@test.com:/bin/bash
```

- Use the standard AD user you created and log in with it in your Linux machine with the **login** command below. 

```bash
sudo login
```

```bash
#Example
sudo login

lab login: test@test.com
Password:

Welcome to Ubuntu 22.04.4 LTS (GNU/Linux 6.5.0-1021-azure x86_64)

Creating directory '/home/test@test.com'.

test@test.com@lab:~$
```

- Your AD user is now logged into this Linux machine. Use the **klist** command to view the Kerberos ticket from the lab domain's DCs for this user on your Linux machine. 

```bash
klist
```

```bash
#Example
klist

Ticket cache: FILE:/tmp/krb5cc_137401106_1GuMKZ
Default principal: test@TEST.COM
Valid starting     Expires            Service principal
06/02/24 04:41:15  06/02/24 14:41:15  krbtgt/TEST.COM@TEST.COM
Renew until 06/03/24 04:41:15
```


