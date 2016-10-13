$logfile = "\\fsdc\Scripts\logs\attachPST_$($env:USERNAME)_$(get-date -format `"yyyyMMdd_hhmmsstt`").txt"

function main() {
    log "Starting script on $env:COMPUTERNAME"
    attachPST
}

function log ($string) {
	write-host "$string"
	$string | out-file -Filepath $logfile -append
}

function attachPST {
    $username = $env:USERNAME
    $source = "\\mail\exports\$($username).pst"
    $destination = "C:\users\$($username)\Documents\Outlook Files\"

    if (Test-Path $source) {
        log "PST exists at path $($source)"
        if (Test-Path $destination) {
            $destination + $username + ".pst"
            log "Destination found. Copying file to $($destination)."
            copy-item -path $source -Destination $destination
        } else {
            log "Destination not found."
        }
    } else {
        log "PST not found for $($username)"
    }

    try {
        if (Test-Path $destination) {
            Add-type -assembly "Microsoft.Office.Interop.Outlook" | out-null
            $outlook = New-Object -ComObject outlook.application
            $namespace = $outlook.GetNameSpace("MAPI")
            dir "C:\Users\rvanhoorne\Desktop\abrandl.pst" | % {$namespace.AddStore($_.FullName)}
        }
        log "Adding PST file to Outlook."
    } catch {
        log "Unable to add PST file to Outlook."
    }
    Add-type -assembly "Microsoft.Office.Interop.Outlook" | out-null
    $outlook = New-Object -ComObject outlook.application
    $namespace = $outlook.GetNameSpace("MAPI")
    dir $destination | % {$namespace.AddStore($_.FullName)}
}

main