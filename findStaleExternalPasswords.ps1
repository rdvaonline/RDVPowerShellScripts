$logfile = "C:\homeofficeover90_$(get-date -format `"yyyyMMdd_hhmmsstt`").txt"

function main() {
	daysRemainingUntilPasswordMustBeChanged
}

function log ($string) {
	write-host "$string"
	$string | out-file -Filepath $logfile -append
}

function notifyByEmail ($recipient, $subject, $body) {
    # Set the PowerShell email server to our SMTP relay on app4. Set variables for use in the send-mailmessage command.
    $psemailserver = "app4"
    $sender = "helpdesk@cellulardynamics.com"
    
    send-mailmessage -from $sender -to $recipient -subject $subject -body $body
}

function daysRemainingUntilPasswordMustBeChanged {
	$HomeOfficeUser=Get-ADUser -properties displayname,samaccountname,pwdlastset,mail,office -filter {(Enabled -eq "True") -and (Office -eq "Home Office")}
	
	foreach($SingleUser in $HomeOfficeUser) {
		$lastSetDate=[datetime]::FromFileTime($SingleUser.pwdlastset) 
		$currentDate= Get-Date 
		$daysRemaining= $lastSetDate -$currentDate

        $recipient = "$($SingleUser.samaccountname)@cellulardynamics.com"
        $recipient += ",helpdesk@cellulardynamics.com"

        log $recipient

        log "$(get-date)`t$($SingleUser.displayname)`t$($SingleUser.office)`t$daysRemaining"

		if ($daysRemaining.Days -lt 0) {
        
		} 

        if ($daysRemaining.Days -gt 0 -and $daysRemaining.Days -lt 7) {
  
        } 
        
        if ($daysRemaining.Days -gt 7 -and $daysRemaining.Days -lt 14) {

        }
	}
}

main