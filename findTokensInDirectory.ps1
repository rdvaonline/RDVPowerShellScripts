function main {
    $head = "
        <Title>Authentication Token Report</Title>
        <style>
            td, th {
                border: 1px solid black;
                border-collapse: collapse;
            }

            th {
                color:white;
                background-color: #a33039;
            }

            table, tr, td, th {
                padding: 2px; 
                margin: 0px;
            }

            tr:nth-child(odd) {
                background-color: lightgray;
            }

            table {
                width: 95%;
                margin-left: 5px;
                margin-bottom: 20px;
            }
        </style>
        <br />
        <h1>Authentication Token Report</h1>
    " 
    $body
    $saveChooser

    [string[]] $authorizationEnumValues = @()
    $authorizationEnumValues = getAuthorizationEnumValues
    initializeForm
}

function getAuthorizationEnumValues() {
    $enumPath = "C:\Users\robert.vanhoorne\Downloads\wwp-ng2-final\wwp-ng2-final\src\app\shared\models\authorization.ts"
    $content = [System.IO.File]::ReadAllText($enumPath)
    $openBrace = "{"
    $closeBrace = "}"
    $startIndex = $content.IndexOf($openBrace) + $openBrace.Length
    $endIndex = $content.IndexOf($closeBrace, $startIndex)
    $content = $content.Substring($startIndex, $endIndex - $startIndex)
    $content = $content -replace "`t|`n|`r| ",""
    $content = [System.Text.RegularExpressions.RegEx]::Split($content, ",") 
    
    ##ForEach-Object {
    ##    "Authorization.$_"
    ##}
    
    return $content
}

function initializeForm() {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Size = New-Object System.Drawing.Size(300,150)
    $form.Text = "Select a folder to parse"
    $form.StartPosition = "CenterScreen"

    # Folder Path Label
    $folderPathLabel = New-Object System.Windows.Forms.Label
    $folderPathLabel.AutoSize = $true
    $folderPathLabel.Location = New-Object System.Drawing.Point(10,20)
    $folderPathLabel.Size = New-Object System.Drawing.Size(40,20)
    $folderPathLabel.Text = "Folder Path:"
    $form.Controls.Add($folderPathLabel)

    # Folder Path Text Box
    $folderPathTextBox = New-Object System.Windows.Forms.TextBox
    $folderPathTextBox.Name = "folderPathTextBox"
    $folderPathTextBox.Location = New-Object System.Drawing.Point(10,40)
    $folderPathTextBox.Size = New-Object System.Drawing.Size(180,20)
    $form.Controls.Add($folderPathTextBox)

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
	$folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowserDialog.Description = "Select a folder to parse for tokens"
    $folderBrowserDialog.ShowNewFolderButton = $false
    $folderBrowserDialog.RootFolder = "MyComputer"

    if ($folderBrowserDialog.ShowDialog() -eq "OK") {
        $saveChooser = New-Object -TypeName System.Windows.Forms.SaveFileDialog
        $saveChooser.Filter = "HTML Files|*.html"
        $saveChooser.FilterIndex = 2
        $saveChooser.RestoreDirectory = $true
        $saveChooser.ShowDialog()
        listAllFilesInFolder($folderBrowserDialog.SelectedPath)
    }
}

function listAllFilesInFolder($folderPath) {
    Write-Host $folderPath
    $fileArray = Get-ChildItem -Path $folderPath -Recurse | Where { !($_.PSIsContainer ) } | Select FullName
    $output = New-Object -TypeName System.Collections.ArrayList
    foreach ($file in $fileArray) {
        $pathHashTable = parsePath($file)
        $reader = [System.IO.File]::OpenText($file.FullName)
        $lineNumber = 0
        while ($null -ne ($line = $reader.ReadLine())) {
            $lineNumber++
            $token = $line | Select-String -SimpleMatch $authorizationEnumValues
            if ($token -ne $null) {
                $properties = @{'FilePath'="<a href=" + $pathHashTable.Get_Item("URL") + ">" + $pathHashTable.get_Item("RelativePath") + "</a>";'Line'="<code>" + $line + "</code>";'LineNumber'=$lineNumber;'Token'=$token.Pattern}
                $outputRow = New-Object -TypeName PSObject -Prop $properties
                $output.Add($outputRow)
            }
        }
    }
    
    $output = $output | Group-Object -Property Token
    
    foreach ($row in $output) {
        $body += "<h2>$($row.name)</h2>"
        $body += $row.Group | Select FilePath,LineNumber,Line | ConvertTo-HTML -Fragment -As Table
    }
    
    $report = ConvertTo-HTML -Head $head -Body $body
    
    Add-Type -AssemblyName System.Web
    [System.Web.HttpUtility]::HtmlDecode($report) | Set-Content $saveChooser.FileName
}

function parsePath($file) {
    $pathHashTable = @{}
    
    $relativePath = $file.FullName.SubString($folderPath.length)
    $pathHashTable.Add("RelativePath", $relativePath)
    
    $fileURL = "file:\\\" + $file.FullName
    $pathHashTable.Add("URL", $fileURL)
    
    
    return $pathHashTable
}

main