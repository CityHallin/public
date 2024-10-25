
<#
    .SYNOPSIS
    Upload Azure B2C Custom Policies

    .DESCRIPTION
    Example script used by Azure DevOPs pipelines to upload XML
    custom policies in an Azure B2C tenant. Works with ADO Azure CLI
    task using ADO service connection based on manually made App Registration 
    federated credentials. Modified from Microsoft Learn Article:
    https://learn.microsoft.com/en-us/azure/active-directory-b2c/deploy-custom-policies-devops

#>

[Cmdletbinding()]
Param(
    [Parameter(Mandatory = $true)][string]$Folder,
    [Parameter(Mandatory = $true)][string]$Files
)

try {
    #Get correct JWT token format from App Registration 
    #federated credential from ADO pipeline service connection
    $accessToken = Get-AzAccessToken -ResourceTypeName MSGraph

    #Make headers
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", 'application/xml')
    $headers.Add("Authorization", 'Bearer ' + $($accessToken.Token))

    #Get the list of files to upload
    $filesArray = $Files.Split(",")
    Foreach ($file in $filesArray) {

        #Create File Path
        $filePath = $Folder + $file.Trim()

        #Check if file exists
        #Optional: Change the content of the policy. For example, replace the tenant-name with your tenant name.
        #$policycontent = $policycontent.Replace("your-tenant.onmicrosoft.com", "contoso.onmicrosoft.com")  
        $FileExists = Test-Path -Path $filePath -PathType Leaf
        if ($FileExists) {

            #Get file content
            $policycontent = Get-Content $filePath -Encoding UTF8              
    
            #Get policy name
            $match = Select-String -InputObject $policycontent  -Pattern '(?<=\bPolicyId=")[^"]*'
    
            If ($match.matches.groups.count -ge 1) {
                $PolicyId = $match.matches.groups[0].value
    
                Write-Host "Uploading the" $PolicyId "policy..."
    
                $graphuri = 'https://graph.microsoft.com/beta/trustframework/policies/' + $PolicyId + '/$value'
                $content = [System.Text.Encoding]::UTF8.GetBytes($policycontent)
                $response = Invoke-RestMethod -Uri $graphuri -Method Put -Body $content -Headers $headers -ContentType "application/xml; charset=utf-8"
    
                Write-Host "Policy" $PolicyId "uploaded successfully."
            }
        }
        else {
            $warning = "File " + $filePath + " couldn't be not found."
            Write-Warning -Message $warning
        }
    }
}
catch {
    Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__

    $_

    $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
    $streamReader.BaseStream.Position = 0
    $streamReader.DiscardBufferedData()
    $errResp = $streamReader.ReadToEnd()
    $streamReader.Close()

    $ErrResp

    exit 1
}

exit 0
