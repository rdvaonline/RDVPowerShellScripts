# Set-ExecutionPolicy RemoteSigned

function not-exist { -not (Test-Path $args) }
Set-Alias !exist not-exist -Option "Constant, AllScope"
Set-Alias exist Test-Path -Option "Constant, AllScope"

$sourceCSV = Import-Csv "C:\Users\Trident Intern 2\Desktop\New folder\movetest.csv"
$destinationPath = "C:\Users\Trident Intern 2\Desktop\movetest\"

foreach ($sourcePath in $sourceCSV) {
    if (exist $sourcePath.Title) {
         try {
            Move-Item $sourcePath.Title $destinationPath -ErrorAction Continue
         } catch {
            Write-Host "Error copying " $sourcePath.Title
         }
    } else {
        Write-Host "File " $sourcePath.Title "not found"
    }
}