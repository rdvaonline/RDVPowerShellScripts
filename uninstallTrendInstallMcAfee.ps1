$logfile = "\\fsdc\Scripts\logs\uninstallTrendInstallMcAfee_$($env:COMPUTERNAME)_$(get-date -format `"yyyyMMdd_hhmmsstt`").txt"

function main() {
    log "Starting script on $env:COMPUTERNAME"
	checkForTrendInstall
    checkForMcAfeeInstall
}

function log ($string) {
	write-host "$string"
	$string | out-file -Filepath $logfile -append
}

function checkForTrendInstall {
    try {
        log "Searching for Trend install registry keys."
        $trendRegKeys = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*Trend*"}
        if ($trendRegKeys -like "*Trend*") {
            log "Trend regestry keys found. Uninstalling."
            log $trendRegKeys
            trendUninstall
        } else {
            log "Trend registry keys not found. Skipping uninstall."
            log $trendRegKeys
        }
    } catch {
        log "An error occurred while searching for Trend registry keys."
    }
}

function checkForMcAfeeInstall {
    try {
        log "Searching for McAfee registry keys."
        $mcafeeRegKeys = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*McAfee*"}
        if ($mcafeeRegKeys -like "*McAfee*") {
            log "McAfee registry keys found. Skipping install."
            log $mcafeeRegKeys
        } else {
            log "McAfee registry keys not found. Installing agent."
            log $mcafeeRegKeys
            mcafeeInstall
        }
    } catch {
        log "An error occurred while searching for McAfee registry keys."
    }
}

function trendUninstall {
    try {
        log "Starting Trend uninstall."
        Start-Process \\app4\TM_Uninstall\AutoPcc.exe -wait
    } catch {
        log "An error occurred while uninstalling Trend."
    }
}

function mcafeeInstall {
    try {
        log "Starting McAfee install."
        Start-Process \\usfcdiavp01\Agent\FramePkg.exe -wait
    } catch {
        log "An error occurred while installing McAfee."
    }
}

main