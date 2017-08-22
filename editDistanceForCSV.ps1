$source = @"
using System;
using System.Linq;

public class Levenshtein {
	public static int EditDistance (string original, string modified)
	{
		if (original == modified)
			return 0;

		int len_orig = original.Length;
		int len_diff = modified.Length;

		if (len_orig == 0)
			return len_diff;

		if (len_diff == 0)
			return len_orig;

		var matrix = new int[len_orig + 1, len_diff + 1];

		for (int i = 1; i <= len_orig; i++) {
			matrix[i, 0] = i;
			for (int j = 1; j <= len_diff; j++) {
				int cost = modified[j - 1] == original[i - 1] ? 0 : 1;
				if (i == 1)
					matrix[0, j] = j;

				var vals = new int[] {
					matrix[i - 1, j] + 1,
					matrix[i, j - 1] + 1,
					matrix[i - 1, j - 1] + cost
				};
				matrix[i,j] = vals.Min ();
				if (i > 1 && j > 1 && original[i - 1] == modified[j - 2] && original[i - 2] == modified[j - 1])
					matrix[i,j] = Math.Min (matrix[i,j], matrix[i - 2, j - 2] + cost);
			}
		}
		return matrix[len_orig, len_diff];
	}
}
"@

Add-Type -TypeDefinition $source

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
	$openFileDialog.ShowHelp = $true1
    $result = $openFileDialog.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        handleCSV($openFileDialog.FileName)
    }
}

function handleCSV($csvPath) {
    $sourceCSV = Import-Csv $csvPath
    $result = [Levenshtein]::EditDistance("kitten", "sitting")

    Write-Host $result    
    Write-Host "Doing the thing!"
}

initializeForm