
<#
    .SYNOPSIS
    Check password for compromise from HaveIBeenPwned.com

    .DESCRIPTION
    Checks password for compromise against the https://haveibeenpwned.com (HIBP)
    database. Script keeps the password in a secure string on the local machine
    and only sends the first 5 characters of the password SHA1 hash to HIBP pulling data 
    onto the local machine for comparison via k-anonymity method
    (https://www.troyhunt.com/understanding-have-i-been-pwneds-use-of-sha-1-and-k-anonymity/).

#>

#User prompt
Write-Host "`nThis script will securely check if your password has been deteced in the HaveIBeenPwned.com (HIBP) database." -ForegroundColor Green
Write-Host "Sensative data is never sent to HIBP or leaves your local machine." -ForegroundColor Green
Write-Host "Okay to continue?"  -ForegroundColor Green
$prompt = Read-Host "Enter 'y' for YES or 'n' for NO"
if ($prompt -eq "y") {
    Write-Host "`nEnter your password to check for compromise" -ForegroundColor Green
}
Else {    
    Write-Host "`nUser cancelled. Press enter to close script" -ForegroundColor Red
    Read-Host " "
    exit
}

#Create password secure string
$passwordSecure = Read-Host  -Prompt "Enter Password" -AsSecureString

#Read secure string into memory and stream into SHA1 hash command
Write-Host "`nProcessing password hash"  -ForegroundColor Green
$passwordHash = Get-FileHash `
                    -InputStream $(
                        [IO.MemoryStream]::new([byte[]][char[]](
                            [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                                [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwordSecure))
                            )
                        )
                    ) `
                    -Algorithm SHA1

#Capture first 5 characters of the hash
$prefix = $passwordHash.hash.SubString(0,5)

#Send query to HIBP API
Write-Host "`nSearching HaveIBeenPwned.com database"  -ForegroundColor Green
$hashChecks = Invoke-WebRequest -Method Get -Uri "https://api.pwnedpasswords.com/range/$prefix" -UseBasicParsing

#Validate website reachable
If ($hashChecks.StatusCode -ne 200) {
    Write-Host " " 
    Write-Warning -Message "Cannot reach HIBP website api.pwnedpasswords.com. StatusCode: $($hashChecks.StatusCode), StatusDescription: $($hashChecks.StatusDescription)"
    Write-Host "Press enter to close script" -ForegroundColor Yellow
    Read-Host " "
    exit
}

#Scan returned HIBP records for a match
Write-Host "`nProcessing query results"  -ForegroundColor Green
$compromised = $false
foreach ($hashCheck in $($hashChecks.Content) -split "`r`n") {

    #Combine prefix and suffix of hash
    $hashFull = $prefix + $hashCheck
    $hash,$Occurrence = $hashFull -split ":"     
    
    #Test is password hash is in the HIBP database
    if ($passwordHash.hash -eq $hash) {        
        $compromised = $true        
        $compromisedOccurrence = $Occurrence        
    }    
}

#Clean-up
$passwordHash = $null
$hashChecks = $null
$hash = $null

#Display search results
If ($compromised -eq $true) { 
    Write-Host " "   
    Write-Warning "Password found in HIBP database and is compromised. Do NOT use this password."  
    Write-Host "Number of times this password has been seen by HIBP database: " -ForegroundColor Yellow -NoNewline
    Write-Host $compromisedOccurrence -ForegroundColor Magenta
    Write-Host " "
}
Elseif ($compromised -eq $false) {
    Write-Host "`nPassword was not found in HIBP database" -ForegroundColor Green
    Write-Host " "
}
