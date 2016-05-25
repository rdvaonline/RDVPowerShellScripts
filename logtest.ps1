$logfile = "C:\ChangePasswordScriptLog_$(get-date -format `"yyyyMMdd_hhmmsstt`").txt"
$madisonOfficeArray = "100|200|205|210|215|Suite 100|Suite 200|Suite 205|Suite 210|Suite 215"

function main() {
	daysSincePasswordLastSet
}

function log ($string) {
	write-host "$(get-date) $string"
	$string | out-file -Filepath $logfile -append
}

function daysSincePasswordLastSet {
	$NeverUser=Get-ADUser -Properties displayname,sAmAccountName,pwdlastset,mail,office -filter {(Enabled -eq "True")} | where {($_.Office -notmatch $madisonOfficeArray)}
 
	Foreach($SingleUser in $NeverUser){ 
		$FirstDate=[datetime]::FromFileTime($SingleUser.pwdlastset) 
		$SecondDate= Get-Date 
		$Result= $SecondDate -$FirstDate 

		if ($Result.Days -gt 90) {
			log "$(get-date) $($SingleUser.displayname) in  Office $($SingleUser.office) has not been reset in $Result days."
		}
		
	} 
}

main

