$groups = Get-ADGroup -filter *
$groupsDictionary = @{}

foreach($group in $groups){
    $groupName = $group.DistinguishedName
    try {
        $countUser = (Get-ADGroupMember $group.DistinguishedName).count
    } catch {
        $countUser = "E"
    }

    try {
        $groupsDictionary.Add($groupName,$countUser)
    } catch {
    
    }
}

$groupsDictionary.GetEnumerator() | Sort-Object Value -Descending