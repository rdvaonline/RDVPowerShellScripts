# Finds accounts that have been inactive for 90 days, logs results to a .txt file, and then disables the accounts

$logfile = "C:\findInactiveAccounts_$(get-date -format `"yyyyMMdd_hhmmsstt`").txt"

function main() {
	findInactiveAccounts
}

function log ($string) {
	write-host "$string"
	$string | out-file -Filepath $logfile -append
}

function findInactiveAccounts {
	
}