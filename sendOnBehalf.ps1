Connect-ExchangeOnline
Clear-Host
Write-Host "Fetching mailboxes"

$dteshort = (get-date).ToString("yyyy-MM-dd")
$file = "Desktop\SendOnBehalfPermissions-" + $dteshort + ".csv"

Get-Mailbox | Where-Object {$_.GrantSendOnBehalfTo -ne $null} | Select-Object Name,Alias,PrimarySmtpAddress,GrantSendOnBehalfTo | Export-CSV $file -NoTypeInformation
Disconnect-ExchangeOnline