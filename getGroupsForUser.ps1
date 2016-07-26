Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Email CSV of Employee Groups Form"
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
$labelUsername.Text = "Please enter the employee's username:"
$form.Controls.Add($labelUsername)

$textBoxUsername = New-Object System.Windows.Forms.TextBox
$textBoxUsername.Location = New-Object System.Drawing.Size(10,40)
$textBoxUsername.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBoxUsername)

$labelEmail = New-Object System.Windows.Forms.Label
$labelEmail.Location = New-Object System.Drawing.Size(10,80)
$labelEmail.Size = New-Object System.Drawing.Size(280,20)
$labelEmail.Text = "Please enter your email address:"
$form.Controls.Add($labelEmail)

$textBoxEmail = New-Object System.Windows.Forms.TextBox
$textBoxEmail.Location = New-Object System.Drawing.Size(10,100)
$textBoxEmail.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($textBoxEmail)

$form.Topmost = $true

$form.Add_Shown({$form.Activate(); $textBoxUsername.focus()})
$result = $form.ShowDialog()

function notifyByEmail ($emailAddress) {
    # Set the PowerShell email server to our SMTP relay on app4. Set variables for use in the send-mailmessage command.
    $psemailserver = "app4"
    $sender = "helpdesk@cellulardynamics.com"
    $recipient = $emailAddress
    $subject = "Test!"
    $body = "Test!"
    
    send-mailmessage -from $sender -to $recipient -subject $subject -body $body
}

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $username = $textBoxUsername.Text
    $email = $textBoxEmail.Text
    $username
    $email

    notifyByEmail $email
}