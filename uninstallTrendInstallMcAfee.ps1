$logfile = "\\fsdc\Scripts\logs\uninstallTrendInstallMcAfee_$(get-date -format `"yyyyMMdd_hhmmsstt`").txt"

function main() {
	checkForTrendInstall
}

function log ($string) {
	write-host "$string"
	$string | out-file -Filepath $logfile -append
}

function checkForTrendInstall {
    try {
        $isTrendInstalled = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*Trend*"} | Select-Object DisplayName
    } catch {
        log "Trend Install Not Found"
    }
}

main