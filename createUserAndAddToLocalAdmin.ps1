$logfile = "\\fsdc\Scripts\logs\uninstallTrendInstallMcAfee_$($env:COMPUTERNAME)_$(get-date -format `"yyyyMMdd_hhmmsstt`").txt"

$localAccountName = "atsadmin"
$localAccountPassword = "1derW0man"
$localAccountGroup = "Administrators"
$localAccountDescription = "ATSADMIN Support Account"

function main() {
    log "Starting script on $env:COMPUTERNAME"
    createUser $localAccountName $localAccountPassword $localAccountDescription
    addToGroup $localAccountName $localAccountGroup
}

function log ($string) {
	write-host "$string"
	$string | out-file -Filepath $logfile -append
}

function createUser ($localAccountName, $localAccountPassword, $localAccountDescription) {
    try {
        $envComputerName = $env:COMPUTERNAME
        $adsiComputerName = [ADSI]"WinNT://$envComputerName"
        $newUser = $adsiComputerName.Create('User',$localAccountName)
        $newUser.SetPassword($localAccountPassword)
        $newUser.SetInfo()
        $newUser.description = $localAccountDescription
        $newUser.SetInfo()
        log "Creating user."    
    } catch {
        log "Creating user $($localAccountName) was not successful."
    }
}

function addToGroup ($localAccountName, $localAccountGroup) {
    try {
        $group = [ADSI]"WinNT://$env:COMPUTERNAME/$localAccountGroup,group"
        $group.Add("WinNT://$env:COMPUTERNAME/$localAccountName,user")
        log "Adding user to group."
    } catch {
        log "Adding user $($localAccountName) to group $($localAccountGroup) was not successful."
    }
}

main