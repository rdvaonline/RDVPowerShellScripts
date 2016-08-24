$logfile = "\\fsdc\Scripts\logs\propertyNotSet_$(get-date -format `"yyyyMMdd_hhmmsstt`").txt"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Get Employee Group Memberships"
$form.Size = New-Object System.Drawing.Size(300,220)
$form.StartPosition = "CenterScreen"

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,140)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,140)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$labelUsername = New-Object System.Windows.Forms.Label
$labelUsername.Location = New-Object System.Drawing.Size(10,20)
$labelUsername.Size = New-Object System.Drawing.Size(280,20)
$labelUsername.Text = "Enter the employee's username seperated by a comma:"
$form.Controls.Add($labelUsername)

$textBoxUsername = New-Object System.Windows.Forms.TextBox
$textBoxUsername.Location = New-Object System.Drawing.Size(10,40)
$textBoxUsername.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBoxUsername)

$labelEmail = New-Object System.Windows.Forms.Label
$labelEmail.Location = New-Object System.Drawing.Size(10,80)
$labelEmail.Size = New-Object System.Drawing.Size(280,20)
$labelEmail.Text = "Enter your email address:"
$form.Controls.Add($labelEmail)

$textBoxEmail = New-Object System.Windows.Forms.TextBox
$textBoxEmail.Location = New-Object System.Drawing.Size(10,100)
$textBoxEmail.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBoxEmail)

$form.Topmost = $true

$form.Add_Shown({$form.Activate(); $textBoxUsername.focus()})
$result = $form.ShowDialog()

function log ($string) {
	write-host "$string"
	$string | out-file -Filepath $logfile -append
}

function notifyByEmail ($emailAddress, $username, $attachmentPath) {
    # Set the PowerShell email server to our SMTP relay on app4. Set variables for use in the send-mailmessage command.
    $psemailserver = "app4"
    $sender = "helpdesk@cellulardynamics.com"
    $recipient = $emailAddress
    $subject = "Group Memberships for $($username)"
    $body = "Attached are the group memberships for $($username). Please review in accordance with policy IT24-A."
    $attachment = $attachmentPath
    
    send-mailmessage -from $sender -to $recipient -subject $subject -body $body -Attachments $attachment
}

function exportGroupMembershipsToCSV ($username) {
    $attachmentPath = "\\fsdc\Scripts\logs\exportGroupMembershipsToCSV_$($username)_$(get-date -format `"yyyyMMdd_hhmmsstt`").csv"
    Get-ADPrincipalGroupMembership $username | Get-ADGroup -Properties name, description | select @{Name="Group Name"; Expression={$_.name}}, @{Name="Group Description"; Expression={$_.description}} | export-csv $attachmentPath -NoTypeInformation

    return $attachmentPath
}

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {

    $attachments = @()
    $usernames = $textBoxUsername.text.Split(',',[System.StringSplitOptions]::RemoveEmptyEntries)

    foreach ($username in $usernames) {
        try {
            $ADUser = Get-ADUser -Identity $username
        } catch {
            log "SAM Account Name lookup was not successful. Attempting Display Name lookup."
        }

        if (!$ADUser) {
            try {
                Get-ADUser -Filter { displayName -like "*$username*" }
            } catch {
                log "Display Name lookup was not successful."
            }
        }

        if ($ADUser) {
            log "User lookup was successful!"
        }

        $attachmentPath = exportGroupMembershipsToCSV $ADUser.samaccountname
        $attachments += $attachmentPath

        Remove-Variable -name ADUser,username,attachmentPath
    }

    notifyByEmail $textBoxEmail.Text $textBoxUsername.Text $attachments
}