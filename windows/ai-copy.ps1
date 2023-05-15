function Copy-Files {
    Write-Host "Enter source directory:"
    $source = Read-Host
    Write-Host "Enter destination directory:"
    $destination = Read-Host

    if (!(Test-Path $source) -or !(Test-Path $destination)) {
        Write-Host "Source or destination path does not exist."
        return
    }
    
    Copy-Item -Path $source\* -Destination $destination -Recurse -Force
    Write-Host "Files copied successfully."
}

function Calculate-MD5 {
    Write-Host "Enter directory to calculate MD5 hashes:"
    $directory = Read-Host

    if (!(Test-Path $directory)) {
        Write-Host "Directory does not exist."
        return
    }
    
    Get-ChildItem $directory -Recurse | Get-FileHash -Algorithm MD5 | Format-Table
}

do {
    Clear-Host
    Write-Host "1. Copy files"
    Write-Host "2. Calculate MD5 hashes"
    Write-Host "3. Exit"
    $action = Read-Host "Please select an action"

    switch ($action) {
        1 {
            Copy-Files
        }
        2 {
            Calculate-MD5
        }
        3 {
            Write-Host "Exiting..."
            break
        }
        default {
            Write-Host "Invalid option. Please try again."
        }
    }
    Read-Host "Press enter to continue"
} while ($action -ne 3)

