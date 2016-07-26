[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$objForm = New-Object System.Windows.Forms.Form
$objForm.Text = "Data Entry Form"
$objForm.Size = New-Object System.Drawing.Size(300,220)
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $true
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") {$username=$objTextBoxUsername.Text;$email=$objTextBoxEmail;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") {$objForm.Close()}})

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,140)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$username=$objTextBoxUsername.Text;$email=$objTextBoxEmail;$objForm.Close()})
$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,140)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

$objLabelUsername = New-Object System.Windows.Forms.Label
$objLabelUsername.Location = New-Object System.Drawing.Size(10,20)
$objLabelUsername.Size = New-Object System.Drawing.Size(280,20)
$objLabelUsername.Text = "Please enter the employee's username:"
$objForm.Controls.Add($objLabelUsername)

$objTextBoxUsername = New-Object System.Windows.Forms.TextBox
$objTextBoxUsername.Location = New-Object System.Drawing.Size(10,40)
$objTextBoxUsername.Size = New-Object System.Drawing.Size(260,20)
$objForm.Controls.Add($objTextBoxUsername)

$objLabelEmail = New-Object System.Windows.Forms.Label
$objLabelEmail.Location = New-Object System.Drawing.Size(10,80)
$objLabelEmail.Size = New-Object System.Drawing.Size(280,20)
$objLabelEmail.Text = "Please enter your email address:"
$objForm.Controls.Add($objLabelEmail)

$objTextBoxEmail = New-Object System.Windows.Forms.TextBox
$objTextBoxEmail.Location = New-Object System.Drawing.Size(10,100)
$objTextBoxEmail.Size = New-Object System.Drawing.Size(260,20)
$objForm.Controls.Add($objTextBoxEmail)

$objForm.Topmost = $true

$objForm.Add_Shown({$objForm.Activate(); $objTextBoxUsername.focus()})
[void] $objForm.ShowDialog()

$username = $objTextBoxUsername.Text
$email = $objTextBoxEmail.Text

$username
$email