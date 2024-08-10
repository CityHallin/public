<#
    .SYNOPSIS
    PowerShell Date Time Formats

    .DESCRIPTION
    List of ways to display date and time with PowerShell.
    Get-Date cmdlet instructions here: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-date

#>

#UTC
Get-Date -Format "U" #Default as UTC
"Saturday, August 10, 2024 10:35:53 AM"

(Get-Date).ToUniversalTime() #Default as UTC
"Saturday, August 10, 2024 10:35:53 AM"

Get-Date -AsUTC #Default as UTC
"Saturday, August 10, 2024 10:35:53 AM"

[DateTime]::UtcNow #.Net call for default UTC
"Saturday, August 10, 2024 10:35:53 AM"

#Other Formats
Get-Date #Full date time
"Saturday, August 10, 2024 10:35:53 AM"

Get-Date -Format "f" #Full date time (no seconds)
"Saturday, August 10, 2024 10:55 AM"

Get-Date -Format "m" #Simple month day
"August 10"

Get-Date -Format "y"  #Simple month year
"August 2024"

Get-Date -Format "t" #Short time
"11:02 AM"

Get-Date -Format "T" #Long time
"11:15:11 AM"

Get-Date -Format "d" #Simple date
"8/10/2024"

Get-Date -Format "g" #Simple date time
"8/10/2024 10:58 AM" 

Get-Date -Format "u" #Universal sortable
"2024-08-10 11:02:44Z"

Get-Date -Format "r" #RFC1123
"Sat, 10 Aug 2024 10:44:33 GMT"

Get-Date -Format "s" #Sortable
"2024-08-10T10:46:00"

Get-Date -Format "o" #ISO 8601
"2024-08-10T10:44:00.3473565-06:00"

#Manually set date time scheme via .Net format. 
#Syntax instructions here: https://learn.microsoft.com/en-us/dotnet/standard/base-types/custom-date-and-time-format-strings
Get-Date -Format "MM/dd/yyyy HH:mm:ss"
"08/10/2024 11:05:54"

#Update time to UTC with specific format
(Get-Date).ToUniversalTime().toString("o")
"2024-08-10T16:52:25.4888273Z"

(Get-Date).ToUniversalTime().ToString("MM/dd/yyyy HH:mm:ss")
"08/10/2024 16:53:24"

#Date time in unix seconds
[DateTimeOffset]::Now.ToUnixTimeSeconds()

#Convert unix seconds to human readable
$unix = [DateTimeOffset]::Now.ToUnixTimeSeconds()
Get-date -UnixTimeSeconds $unix

#Add or subtract time to unix seconds (example 300 seconds)
([DateTimeOffset]::Now.ToUnixTimeSeconds())+300
([DateTimeOffset]::Now.ToUnixTimeSeconds())-300

#Add time to current output with specific format
#AddYears, AddMonths, AddDays, AddHours, AddMinutes, AddSeconds, AddMilliseconds, AddMicroseconds
((Get-Date).AddDays(1)).ToString("s")
"2024-08-11T11:28:06"

(((Get-Date).ToUniversalTime()).AddMinutes(30)).toString("o")
"2024-08-10T18:03:33.9388213Z"

#Subtract time from current output with specific format
#AddYears, AddMonths, AddDays, AddHours, AddMinutes, AddSeconds, AddMilliseconds, AddMicroseconds
((Get-Date).AddDays(-1)).ToString("s")
"2024-08-11T11:28:06"

(((Get-Date).ToUniversalTime()).AddMinutes(-30)).toString("o")
"2024-08-10T17:03:40.2093354Z"
