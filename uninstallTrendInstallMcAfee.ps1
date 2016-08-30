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
        $displayNames = @()
        $displayNames += Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*Trend*"} | Select-Object DisplayName
        if ($displayNames.count -gt 0) {
            log "Trend detected. Attempting uninstall."
        } else {
            log "Trend not detected. Proceeding to McAfee install."
        }
    } catch {
        log "Halp!"
    }
}

main