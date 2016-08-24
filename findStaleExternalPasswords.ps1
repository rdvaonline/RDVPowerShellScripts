$logfile = "\\fsdc\Scripts\logs\findStaleExternalPasswords_$(get-date -format `"yyyyMMdd_hhmmsstt`").txt"

function main() {
	daysRemainingUntilPasswordMustBeChanged
}

function log ($string) {
	write-host "$string"
	$string | out-file -Filepath $logfile -append
}

function notifyByEmail ($sender, $recipient, $subject, $body, $attachmentPath) {
    # Set the PowerShell email server to our SMTP relay on app4. Set variables for use in the send-mailmessage command.
    $psemailserver = "app4"
    
    send-mailmessage -from $sender -to $recipient -subject $subject -body $body -Attachments $attachmentPath
}

function daysRemainingUntilPasswordMustBeChanged {
	$HomeOfficeUser=Get-ADUser -properties displayname,samaccountname,pwdlastset,mail,office -filter {(Enabled -eq "True") -and (Office -eq "Home Office")}
	
	foreach($SingleUser in $HomeOfficeUser) {
		$lastSetDate=[datetime]::FromFileTime($SingleUser.pwdlastset) 
		$currentDate= Get-Date 
		$daysRemaining= $lastSetDate -$currentDate

        $recipient = @("$($SingleUser.mail)")
        $sender = $recipient
        $attachmentPath = "\\fsdc\Scripts\How to Change Password for External Users.pdf"

        log "$(get-date)`t$($SingleUser.displayname)`t$($SingleUser.office)`t$daysRemaining"
        log $recipient

        if ($daysRemaining.Days -lt 7) {
            $recipient += "helpdesk@cellulardynamics.com"
            $subject = "Password Expires in $($daysRemaining.Days) Days for $($SingleUser.samaccountname)"
            $body = "Hello! Your password will expire in $($daysRemaining.days) days. The helpdesk has been CC'd which will create a case for us to follow up with you. Step by step instructions for updating your password are attached."

            notifyByEmail $sender $recipient $subject $body $attachmentPath
        } 
        
        if ($daysRemaining.Days -gt 7 -and $daysRemaining.Days -lt 14) {
            $subject = "Step by Step Instructions for Updating Your Password"
            $body = "Hello! Your password will expire in $($daysRemaining.Days) days. Attached are step by step instructions on how to connect to the VPN and update your password. Please contact us at helpdesk@cellulardynamics.com if you have questions or need assistance."

            notifyByEmail $sender $recipient $subject $body $attachmentPath
  
        }
	}
}

main