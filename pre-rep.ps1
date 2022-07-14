Install-Module ExchangeOnlineManagement -Scope CurrentUser
Import-Module ExchangeOnlineManagement

Connect-ExchangeOnline

Get-Mailbox | Format-List Name,AuditEnabled

$UserMailboxes = Get-mailbox -Filter "RecipientTypeDetails -eq 'UserMailbox'"
$UserMailboxes | ForEach-Object {
    Set-Mailbox $_.Identity -AuditEnabled $true
}