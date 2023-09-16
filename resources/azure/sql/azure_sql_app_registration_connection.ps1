
#On Azure SQL PaaS instances, use SSMS to log in as your Azure AD user and run the following which will
#create the App Registration SPN as a user in the Azure SQL database and grant your desired roles. 
#Use the SPN display name.
CREATE USER [SPN DISPLAY NAME HERE] FROM EXTERNAL PROVIDER
ALTER ROLE [db_datareader] ADD MEMBER [SPN DISPLAY NAME HERE];

#In PowerShell, you can use the following to log in as the SPN,
#get an Azure AD access token for the SPN, and connect to the DB 

#Get SPN Access Token
$tenantId = "<ENTER TENANT ID>"
$resourceUrl = "https://database.windows.net/"
$cred = Get-Credential #use client id and client secret from the App Registration
Connect-AzAccount -ServicePrincipal -Credential $cred -TenantId  $tenantId
$token = (Get-AzAccessToken -ResourceUrl $resourceUrl).Token

#Use Access Token to connect to Azure SQL PaaS Instance
$sqlServerUrl = "<ENTER AZURE SQL SERVER NAME>.database.windows.net"
$database = "<ENTER AZURE DB NAME>"
$connectionString = "Server=tcp:$sqlServerUrl,1433;Initial Catalog=$database;Connect Timeout=30"
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$connection.AccessToken = $token
$connection.Open()
$query="SELECT * FROM DBO.Users" #sample query
$command = New-Object -TypeName System.Data.SqlClient.SqlCommand($query, $connection)
$Result = $command.ExecuteScalar()
$Result
$connection.Close()