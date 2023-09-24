
#Bindings are passed via param block.
using namespace System.Net
param($Request, $TriggerMetadata, $dbCheck)

#Information
$userAnswer = (($Request.body).Replace("`"","") | out-string).TrimEnd() #remove quote characters forced from Twitch 
$dbAnswer = ($dbCheck.answer | out-string).TrimEnd() #remove trailing spaces
$dbQuestion = ($dbCheck.question | out-string).TrimEnd() #remove trailing spaces
Write-Output "Currently on question #$($dbCheck.id), `"$($dbQuestion)`""
Write-Output "User submission was `"$($userAnswer)`". Correct Answer is `"$($dbAnswer)`""

#Validate answer
If ($userAnswer -eq $dbAnswer) {
    Write-Output "Question #$($dbCheck.id) with user subsmittion `"$($userAnswer)`" is CORRECT"
    $answerStatus = "correct"
}
Else {    
    Write-Output "Question #$($dbCheck.id) with user subsmittion `"$($userAnswer)`" is INCORRECT"
    $answerStatus = "incorrect"
}

#Build Reply Body
$body = "Your answer of `"$($userAnswer)`" for question #$($dbCheck.id) was $($answerStatus)! "

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})





