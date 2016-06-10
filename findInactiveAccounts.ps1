# Finds accounts that have been inactive for 90 days, logs results to a .csv file, and then emails the .csv to helpdesk for review.

function main() {
	findInactiveAccounts
}

function notifyByEmail ($attachmentPath) {
    # Set the PowerShell email server to our SMTP relay on app4. Set variables for use in the send-mailmessage command.
    $psemailserver = "app4"
    $sender = "helpdesk@cellulardynamics.com"
    $recipient = "helpdesk@cellulardynamics.com"
    $subject = "List of Users Who Have Not Logged in For 30 Days"
    $body = "Attached is a list of users who have not logged in for 30 days. Please review the list and disable accounts as needed."
    
    send-mailmessage -from $sender -to $recipient -subject $subject -body $body -Attachments $attachmentPath
}

function findInactiveAccounts {
    $inactiveDays = 30
    $DN = "dc=cdi,dc=local"
    $attachmentPath = "\\fsdc\Scripts\logs\findInactiveAccounts_$(get-date -format `"yyyyMMdd_hhmmsstt`").csv"

    Search-ADAccount -UsersOnly -SearchBase "$DN" -AccountInactive -TimeSpan $inactiveDays`.00:00:00 | 
    Where-Object { ($_.Enabled -eq $true) } | 
    Get-ADUser -Properties samaccountname,lastlogontimestamp,enabled,whencreated,distinguishedname |
    Where-Object {$_.WhenCreated -lt (Get-Date).AddDays(-$($inactiveDays)) } |
    Select samaccountname,@{n="LastLogonTimeStamp";e={[DateTime]::FromFileTime($_.LastLogonTimestamp)}},enabled,whencreated,distinguishedname |
    Sort-Object LastLogofnTimeStamp |
    export-csv $attachmentPath

    notifyByEmail $attachmentPath
}

main