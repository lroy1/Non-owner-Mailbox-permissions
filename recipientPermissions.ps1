
# Quick and simple script to generate a report of non-standard permissions applied to Exchange Online user and shared mailboxes
# Needs to be connected to Exchange Online PowerShell with an administrative account to run
Connect-ExchangeOnline
Clear-Host
Write-Host "Fetching mailboxes"
[array]$Mbx = Get-Mailbox -RecipientTypeDetails UserMailbox, SharedMailbox -ResultSize Unlimited | Select-Object DisplayName, UserPrincipalName, RecipientTypeDetails
If ($Mbx.Count -eq 0) { Write-Error "No mailboxes found. Script exiting..." -ErrorAction Stop } 
# We have some mailboxes, so we can process them...
Clear-Host
$Report = [System.Collections.Generic.List[Object]]::new() # Create output file 
$ProgressDelta = 100/($Mbx.count); $PercentComplete = 0; $MbxNumber = 0
ForEach ($M in $Mbx) {
    $MbxNumber++
    $MbxStatus = $M.DisplayName + " ["+ $MbxNumber +"/" + $Mbx.Count + "]"
    Write-Progress -Activity "Processing mailbox" -Status $MbxStatus -PercentComplete $PercentComplete
    $PercentComplete += $ProgressDelta
    $Permissions = Get-RecipientPermission -Identity $M.UserPrincipalName # | ? {$_.User -Like "*@*" }
   # $otherthanfullacess = Get-RecipientPermission -Identity $M.UserPrincipalName    
    If ($Null -ne $Permissions) {
       # Grab each permission and output it into the report
       ForEach ($Permission in $Permissions) {
        if($Permission.Trustee -ne "NT AUTHORITY\SELF"){
             $ReportLine  = [PSCustomObject] @{
               Mailbox    = $M.DisplayName
               UPN        = $M.UserPrincipalName
               Permission = $Permission.AccessRights # | Select -ExpandProperty AccessRights
               AssignedTo = $Permission.Trustee
               MailboxType = $M.RecipientTypeDetails } 
             $Report.Add($ReportLine) }
        }
     } 
}     

$dteshort = (get-date).ToString("yyyy-MM-dd")
$file = "Desktop\RecipientPermissions-" + $dteshort + ".csv"
$Report | Sort-Object -Property @{Expression = {$_.MailboxType}; Ascending= $False}, Mailbox | Export-CSV $file -NoTypeInformation
Write-Host "All done." $Mbx.Count "mailboxes scanned. Report of non-standard permissions available in Desktop\RecipientPermissions.csv"
Disconnect-ExchangeOnline