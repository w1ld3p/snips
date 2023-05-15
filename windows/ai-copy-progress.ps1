function Copy-Files {
    Write-Host "Enter source directory:"
    $source = Read-Host
    Write-Host "Enter destination directory:"
    $destination = Read-Host

    if (!(Test-Path $source) -or !(Test-Path $destination)) {
        Write-Host "Source or destination path does not exist."
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
    }

    Write-Progress -Activity "Copying Files" -Completed
    Write-Host "Files copied successfully."
}


