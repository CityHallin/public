
# option 1 - Wscript style pop-up
$shellObject = New-Object -ComObject Wscript.Shell
$notification = $shellObject.Popup("Computer will reboot in 30 minutes",0,"Reboot Notification")

# option 2 - Balloon style message
Add-Type -AssemblyName System.Windows.Forms
$global:balloonmsg = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balloonmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balloonmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
$balloonmsg.BalloonTipText = "Computer will reboot in 30 minutes"
$balloonmsg.BalloonTipTitle = "Reboot Notification"
$balloonmsg.Visible = $true
$balloonmsg.ShowBalloonTip(20000)