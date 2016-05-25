$logfile = "C:\homeofficeover90_$(get-date -format `"yyyyMMdd_hhmmsstt`").txt"

function main() {
	daysSincePasswordLastSet
}

function log ($string) {
	write-host "$string"
	$string | out-file -Filepath $logfile -append
}

function daysSincePasswordLastSet {
	$HomeOfficeUser=Get-ADUser -properties displayname,pwdlastset,mail,office -filter {(Enabled -eq "True") -and (Office -eq "Home Office")}
	
	foreach($SingleUser in $HomeOfficeUser) {
		$FirstDate=[datetime]::FromFileTime($SingleUser.pwdlastset) 
		$SecondDate= Get-Date 
		$Result= $SecondDate -$FirstDate 

		if ($Result.Days -gt 90) {
			log "$(get-date)`t$($SingleUser.displayname)`t$($SingleUser.office)`t$Result"
		} 
	}
}

main