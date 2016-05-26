# Finds Active Directory users where the Office property is not set, logs the result to a text file, and notifies administrators via email.

$logfile = "C:\officePropertyNotSet_$(get-date -format `"yyyyMMdd_hhmmsstt`").txt"

function main() {
	officePropertyNotSet
}

function log ($string) {
	write-host "$(get-date) $string"
	$string | out-file -Filepath $logfile -append
}

function notifyByEmail ($attachmentPath) {
    # Set the PowerShell email server to our SMTP relay on app4. Set variables for use in the send-mailmessage command.
    $psemailserver = "app4"
    $sender = "helpdesk@cellulardynamics.com"
    $recipient = "rob.vanhoorne.contractor@cellulardynamics.com"
    $subject = "Office Property Not Set Report"
    $body = "Please set the Office property for the following users in Active Directory Users and Computers."
    
    send-mailmessage -from $sender -to $recipient -subject $subject -body $body -Attachments $attachmentPath
}

function officePropertyNotSet {
	$utilityOU = "*OU=Utility,OU=Users,OU=CDI-ScienceDr,DC=cdi,DC=local"
	$serviceAccountOU = "*OU=Service Accounts,OU=Users,OU=CDI-ScienceDr,DC=cdi,DC=local"
	$monitoringMailboxes = "*CN=Monitoring Mailboxes,CN=Microsoft Exchange System Objects,DC=cdi,DC=local"
	$vendorsOU = "*OU=Vendors,OU=Users,OU=CDI-ScienceDr,DC=cdi,DC=local"
	$mailContactsOU = "*OU=Mail Contacts,OU=Users,OU=CDI-ScienceDr,DC=cdi,DC=local"
	

	$OfficePropertyNotSetUser=Get-ADUser -properties displayname,distinguishedName,office -filter {(Enabled -eq "True") -and (office -notlike "*")} | where-object {($_.DistinguishedName -notlike $utilityOU) -and ($_.DistinguishedName -notlike $serviceAccountOU) -and ($_.DistinguishedName -notlike $monitoringMailboxes) -and ($_.DistinguishedName -notlike $vendorsOU) -and ($_.DistinguishedName -notlike $mailContactsOU)}
    $attachmentPath = "c:\officePropertyNotSet_$(get-date -format `"yyyyMMdd_hhmmsstt`").csv"
    
    $OfficePropertyNotSetUser | export-csv $attachmentPath

	foreach ($SingleUser in $OfficePropertyNotSetUser) {
		log "$($SingleUser.displayname)`t $($SingleUser.distinguishedName)"
	}

    notifyByEmail $attachmentPath
}

main