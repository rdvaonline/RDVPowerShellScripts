# Finds Active Directory users where the Office property is not set, writes results to a .CSV, and emails .CSV to an administrator.

function main() {
	officePropertyNotSet
}

function notifyByEmail ($attachmentPath) {
    # Set the PowerShell email server to our SMTP relay on app4. Set variables for use in the send-mailmessage command.
    $psemailserver = "app4"
    $sender = "helpdesk@cellulardynamics.com"
    $recipient = "swolfe@cellulardynamics.com"
    $subject = "List of Users Who Do Not Have the Office Property Set in ADUC"
    $body = "Attached is a list of users who do not have the Office property set. Please set the property in Active Directory Users and Computers."
    
    send-mailmessage -from $sender -to $recipient -subject $subject -body $body -Attachments $attachmentPath
}

function officePropertyNotSet {
    # Set variables for OUs to be excluded by the search. These OUs contain external users that are not employees of CDI, service accounts, and other administrative resources.
	$utilityOU = "*OU=Utility,OU=Users,OU=CDI-ScienceDr,DC=cdi,DC=local"
	$serviceAccountOU = "*OU=Service Accounts,OU=Users,OU=CDI-ScienceDr,DC=cdi,DC=local"
	$monitoringMailboxes = "*CN=Monitoring Mailboxes,CN=Microsoft Exchange System Objects,DC=cdi,DC=local"
	$vendorsOU = "*OU=Vendors,OU=Users,OU=CDI-ScienceDr,DC=cdi,DC=local"
	$mailContactsOU = "*OU=Mail Contacts,OU=Users,OU=CDI-ScienceDr,DC=cdi,DC=local"
	
  
	$OfficePropertyNotSetUser=Get-ADUser -properties displayname,distinguishedName,office -filter {(Enabled -eq "True") -and (office -notlike "*")} | where-object {($_.DistinguishedName -notlike $utilityOU) -and ($_.DistinguishedName -notlike $serviceAccountOU) -and ($_.DistinguishedName -notlike $monitoringMailboxes) -and ($_.DistinguishedName -notlike $vendorsOU) -and ($_.DistinguishedName -notlike $mailContactsOU)}
    $attachmentPath = "\\fsdc\Public\IT-Public\Scripts\logs\officePropertyNotSet_$(get-date -format `"yyyyMMdd_hhmmsstt`").csv"
    $OfficePropertyNotSetUser | select DisplayName,Office, DistinguishedName,Enabled | export-csv $attachmentPath

    notifyByEmail $attachmentPath
}

main