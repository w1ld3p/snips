function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("INFO","WARN","ERROR","DEBUG")]
        [string]$Level,
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [string]$LogFile = "C:\log.txt"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $username = [Environment]::UserName
    $logEntry = "$timestamp,$username,$Level,$Message"
    Add-Content -Path $LogFile -Value $logEntry
}

function Copy-Files {
    Write-Host "Enter source directory:"
    $source = Read-Host
    Write-Host "Enter destination directory:"
    $destination = Read-Host

    if (!(Test-Path $source) -or !(Test-Path $destination)) {
        Write-Host "Source or destination path does not exist."
        Write-Log -Level "ERROR" -Message "Copy-Files,Source or destination path does not exist."
        return
    }

    $files = Get-ChildItem -Path $source -Recurse
    $fileCount = $files.Count
    $currentCount = 0

    foreach ($file in $files) {
        $currentCount++
        $percentage = ($currentCount / $fileCount) * 100
        Write-Progress -Activity "Copying Files" -Status "$currentCount of $fileCount copied" -PercentComplete $percentage
        Copy-Item -Path $file.FullName -Destination $destination -Force
        Write-Log -Level "INFO" -Message "Copy-Files, Copied file $file to $destination"
    }

    Write-Progress -Activity "Copying Files" -Completed
    Write-Host "Files copied successfully."
    Write-Log -Level "INFO" -Message "Copy-Files, Files copied successfully."
}

function Calculate-MD5 {
    Write-Host "Enter directory to calculate MD5 hashes:"
    $directory = Read-Host

    if (!(Test-Path $directory)) {
        Write-Host "Directory does not exist."
        Write-Log -Level "ERROR" -Message "Calculate-MD5, Directory does not exist."
        return
    }

    Get-ChildItem $directory -Recurse | Get-FileHash -Algorithm MD5 | Format-Table
    Write-Log -Level "INFO" -Message "Calculate-MD5, Calculated MD5 hashes for $directory"
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
            Write-Log -Level "INFO" -Message "User selected Exit"
            break
        }
        default {
            Write-Host "Invalid option. Please try again."
            Write-Log -Level "WARN" -Message "Invalid option selected"
        }
    }
    Read-Host "Press enter to continue"
} while ($action -ne 3)

