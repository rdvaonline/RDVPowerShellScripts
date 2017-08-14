function initializeForm() {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Size = New-Object System.Drawing.Size(300,150)
    $form.Text = "Select a CSV file"
    $form.StartPosition = "CenterScreen"

    # File Path Label
    $filePathLabel = New-Object System.Windows.Forms.Label
    $filePathLabel.AutoSize = $true
    $filePathLabel.Location = New-Object System.Drawing.Point(10,20)
    $filePathLabel.Size = New-Object System.Drawing.Size(40,20)
    $filePathLabel.Text = "File Path:"
    $form.Controls.Add($filePathLabel)

    # File Path Text Box
    $filePathTextBox = New-Object System.Windows.Forms.TextBox
    $filePathTextBox.Name = "filePathTextBox"
    $filePathTextBox.Location = New-Object System.Drawing.Point(10,40)
    $filePathTextBox.Size = New-Object System.Drawing.Size(180,20)
    $form.Controls.Add($filePathTextBox)

    # Browse Button
    $browseButton = New-Object System.Windows.Forms.Button
    $browseButton.Location = New-Object System.Drawing.Point(200,38)
    $browseButton.Size = New-Object System.Drawing.Size(75,23)
    $browseButton.Text = "Browse"
    $browseButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($browseButton)
    $browseButton.Add_Click({browseClicked})

    $form.Topmost = $true

    $form.Add_Shown({$form.Activate()})
    $result = $form.ShowDialog()
}

function browseClicked() {
	$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "|*.csv"
	$openFileDialog.ShowHelp = $true
    $result = $openFileDialog.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $csvPath = $openFileDialog.FileName
    }
}

initializeForm