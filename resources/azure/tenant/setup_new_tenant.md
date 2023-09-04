# New Azure Tenant Set Up

Simple outline going over some best practice steps when setting up an Azure Tenant for the first time. 

### First User Account
Before setting up your Azure Tenant, set up a Microsoft Account that will be used in the setup process of your Azure Tenant. 

 - Make sure to have a **Password Vault** that can be used to save information about your accounts, passwords, codes, etc.
 - Create a new [Microsoft Account](https://account.microsoft.com/account) with a strong password
 - Set up security on your new Microsoft Account
	- Set up multiple sign-in methods (example: Microsoft Authenticator App, alternative email, SMS codes, etc.). This will make sure you can recover your account in the event of an issue. 
	- Setup MFA on your Microsoft Account and save the recovery codes in your Password Vault. 

### Azure Tenant
With our Microsoft Account setup, we can use it to set up our brand new Azure Tenant. Head to the [Azure Free Account](https://azure.microsoft.com/en-in/free/) site, log in with your Microsoft Account, and click on the **Start Free** button. It will ask you for some address and billing information. Head to the [Azure Free Account FAQ](https://azure.microsoft.com/en-us/free/free-account-faq/?azure-portal=true#:~:text=Azure%20free%20account%20FAQ%201%20How%20do%20I,do%20I%20ensure%20that%20I%20won%E2%80%99t%20be%20charged%3F) if you have questions. 


### Management Groups and Subscriptions
Once your Azure Tenant has been created, your Microsoft Account you used to create it will be the main admin account for the entire Tenant. Make sure to keep this account safe and available. The Azure Tenant will start out with a single Subscription that will be used for your free account.Management Groups can be used to control access at this level, apply Azure Policys, etc. 

- Management Groups
	- Enable your Microsoft Account [Elevated Access](https://learn.microsoft.com/en-us/azure/role-based-access-control/elevate-access-global-admin) to configure the Management Groups.
	- Create as many Management Groups as you like under the Tenant Root Management Group. 	
- Subscriptions
	- Create other Subscriptions if needed.
	- Re-name Subscriptions to user-friendly names.
	- Place Subscriptions in desired Management Groups. 

### Microsoft Entra (Azure Active Directory)
Microsoft Entra (in the past known as Azure Active Directory) is the main identity management system in your Azure Tenant. Set up users and groups to manage access to the Subscriptions and Entra itself. 

- Entra Users
	- Set up your [Emergency Admin](https://learn.microsoft.com/en-us/azure/active-directory/roles/security-emergency-access) account as a backup. Make this a Global Administrator. Save its information in your Password Vault. 
	- Set up your Primary account in Entra that will be used for day-to-day tasks. You'll want to limit this account to only needed rights in required Subscriptions and Entra Roles. For this user, set up its MFA in its Microsoft Account with the Microsoft Authenticator App. Save its information in your Password Vault. 
- Entra Groups
	- Examples of Entra Groups that can be created to organize user access:
		- **mg-root-owner:** Entra Group to be placed on the Tenant Root Management Group in the Owner role. Recommended to only be the Microsoft Account used to create the Tenant, the Emergency Admin account, etc. This access should be limited. 
		- **sub-subName-Contributor:** Entra Group to be placed in the Contributor role on a specific Subscription. 
		- **rg-subName_rgName-Reader:** Entra Group to be placed in the Reader role on a specific Resource Group in a specific Subscription. 
- Licenses (optional)
	- Recommend looking into the purchase of a single Azure Active Directory Premium P1 license which is about $6 a month. This will grant more Entra abilities. The license can be assigned to your Primary user. 
- Custom Domain (optional)
	- Purchase a custom domain.
	- In Entra, add the custom domain
	- Create a TXT record in your domain's DNS so Entra can verify you own it. 
	- Set the custom domain name as the primary domain name in your Entra Tenant. 
- User Settings
	- Recommended settings in the Entra User Settings section to start off with. You can adjust these differently as you need them later on:
		- Users can register applications = No
		- Restrict non-admin users from creating tenants  = Yes
		- Users can create security groups = No
		- Guest user access restrictions = Guest user access is restricted to properties and memberships of their own directory objects
		- Restrict access to Microsoft Entra ID administration portal  = Yes
		- LinkedIn account connections = No
		- Show keep user signed in = set as desired
		- External users:
			- Guest invite restrictions = Only users assigned to specific admin roles can invite guest users
			- Enable guest self-service sign up via user flows = No
			- Allow external users to remove themselves from your organization (recommended) = Yes
			-  Collaboration restrictions: configure one of the two:
				- Deny invitations to the specified domains
				- Allow invitations only to the specified domains (most restrictive) and list the tenants
		- User features
			- Users can use preview features for My Apps = set as desired
			- Administrators can access My Staff = set as desired
- Authentication methods
	- Allow the authentication methods you desire for your Tenant. 
- Multifactor authentication
	- Set lockout limits, notifications, etc. for your MFA setup. 
- Conditional Access
	- Set up a Conditional Access policy to enforce MFA as you see fit for the users you see fit. For any MFA policies, make sure to exclude your Emergency Admin Account, temporarily exlucde you Primary user, and initially create it in **Report-Only** mode first. This will give you the opportunity to do testing so you do not lock out needed admin users. 
	- Once in Report-Only mode, do some test logins with users that are supposed to have MFA prompts and your excluded users (like your Emergency Admin). In the Entra Sign-in logs, make sure the report-only section shows that it would enforce the policy correctly when enabled. 
	- If the Report-Only tests look good, you can update your policy exclusion list to only **needed accounts** and change the Conditional Access policy from Report-Only to **On**. 
- Branding
	- Set up login branding as you see fit. 
- Tenant Name
	- Re-name your Entra Tenant as you see fit. 

### Cost and Billig

- Set up [Budget Alerts](https://github.com/CityHallin/public/blob/main/resources/azure/cost/setup_budget_alert.md) to email you when the actual and forecasted cost reaches thresholds. 

### Service health alerts

- Set up [Service Health Alerts](https://learn.microsoft.com/en-us/azure/service-health/alerts-activity-log-service-notifications-portal) for your Subscriptions. 
