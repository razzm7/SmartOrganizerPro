# Smart Organizer Pro - Windows PowerShell 5.1+
# Moves files only; does not delete or execute them.

$ErrorActionPreference = 'Stop'
$script:LogPath = Join-Path $PSScriptRoot 'SmartOrganizerPro-log.jsonl'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Show-FolderPicker {
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = 'Choose the folder whose files you want to organize'
    $dialog.ShowNewFolderButton = $false
    $owner = New-Object System.Windows.Forms.Form
    $owner.TopMost = $true
    $owner.ShowInTaskbar = $false
    $owner.StartPosition = 'CenterScreen'
    $owner.Size = New-Object System.Drawing.Size(1, 1)
    $owner.Opacity = 0
    try {
        $owner.Show()
        $owner.Activate()
        if ($dialog.ShowDialog($owner) -eq [System.Windows.Forms.DialogResult]::OK) {
            return $dialog.SelectedPath
        }
        return $null
    } finally {
        $dialog.Dispose()
        $owner.Dispose()
    }
}

function Get-Category([string]$Extension) {
    $ext = $Extension.TrimStart('.').ToLowerInvariant()
    $map = @{
        Videos = @('mp4','mkv','avi','mov','wmv','flv','webm','3gp','m4v','mpg','mpeg','ts','vob','ogv','m2ts','mts','divx','asf','f4v','rmvb')
        Photos = @('jpg','jpeg','png','gif','bmp','webp','heic','heif','svg','tif','tiff','ico','raw','cr2','nef','arw','dng','psd','avif','jfif','jpe','indd')
        Documents = @('pdf','doc','docx','odt','rtf','tex','epub','mobi','azw','azw3','djvu','xps','pages')
        'Text Files' = @('txt','md','markdown','log','ini','cfg','conf','xml','json','yaml','yml','toml','nfo','srt','vtt','sub')
        Spreadsheets = @('xls','xlsx','xlsm','xlsb','ods','csv','tsv','numbers')
        Presentations = @('ppt','pptx','pptm','pps','ppsx','odp','key')
        Music = @('mp3','wav','aac','flac','m4a','ogg','wma','opus','mid','midi','amr','aiff','aif','ape','ac3','mka')
        Archives = @('zip','rar','7z','tar','gz','bz2','xz','tgz','zst','cab','iso','img')
        Apps = @('exe','msi','msix','appx','apk','aab','deb','rpm','dmg','pkg')
        Code = @('js','jsx','ts','tsx','html','htm','css','scss','sass','less','php','py','ipynb','java','c','cpp','h','hpp','cs','go','rs','rb','swift','kt','dart','vue','svelte','sql','sh','bat','cmd','ps1','psm1','psd1','jsonc','jsxinc')
        Design = @('fig','sketch','xd','afdesign','afphoto','blend','fbx','obj','stl','glb','gltf','dae','3ds','dwg','dxf','step','stp','eps','ai','xcf')
        Fonts = @('ttf','otf','woff','woff2','eot')
        'Other Downloads' = @('torrent','lnk','url','webloc')
    }
    foreach ($category in $map.Keys) {
        if ($map[$category] -contains $ext) { return $category }
    }
    return 'Others'
}

function Get-UniqueDestination([string]$Directory, [string]$FileName) {
    $candidate = Join-Path $Directory $FileName
    if (-not (Test-Path -LiteralPath $candidate)) { return $candidate }
    $base = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
    $ext = [System.IO.Path]::GetExtension($FileName)
    $i = 1
    do {
        $candidate = Join-Path $Directory ("{0} ({1}){2}" -f $base, $i, $ext)
        $i++
    } while (Test-Path -LiteralPath $candidate)
    return $candidate
}

function Write-LogRecord($Record) {
    $json = $Record | ConvertTo-Json -Compress
    Add-Content -LiteralPath $script:LogPath -Value $json -Encoding UTF8
}

function Read-LogRecords {
    if (-not (Test-Path -LiteralPath $script:LogPath)) { return @() }
    $records = @()
    foreach ($line in Get-Content -LiteralPath $script:LogPath -ErrorAction SilentlyContinue) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try { $records += ($line | ConvertFrom-Json) } catch { Write-Host 'Warning: An unreadable log line was skipped.' -ForegroundColor Yellow }
    }
    return $records
}

function Invoke-Organize {
    $target = Show-FolderPicker
    if ([string]::IsNullOrWhiteSpace($target)) { Write-Host 'Folder selection cancelled.' -ForegroundColor Yellow; return }

    $fullTarget = [System.IO.Path]::GetFullPath($target).TrimEnd('\')
    $root = [System.IO.Path]::GetPathRoot($fullTarget).TrimEnd('\')
    if ($fullTarget -eq $root -or $fullTarget -match '^[A-Za-z]:\\Windows(?:\\|$)' -or $fullTarget -match '^[A-Za-z]:\\Program Files(?: \(x86\))?(?:\\|$)' -or $fullTarget -match '^[A-Za-z]:\\ProgramData(?:\\|$)') {
        Write-Host 'For safety, choose an ordinary data folder, not a drive root or Windows/program folder.' -ForegroundColor Red
        return
    }

    Write-Host "`nOrganizing: $fullTarget" -ForegroundColor Cyan
    $batchId = [guid]::NewGuid().ToString()
    $moved = 0; $skipped = 0; $failed = 0
    $files = @(Get-ChildItem -LiteralPath $fullTarget -File -Force -ErrorAction SilentlyContinue)
    foreach ($file in $files) {
        # Skip hidden/system items, incomplete downloads, and this tool's own files.
        if (($file.Attributes -band [IO.FileAttributes]::Hidden) -or ($file.Attributes -band [IO.FileAttributes]::System)) { $skipped++; continue }
        if ($file.Name -in @('SmartOrganizerPro.ps1','SmartOrganizerPro.bat','SmartOrganizerPro-log.jsonl')) { $skipped++; continue }
        if ($file.Extension.ToLowerInvariant() -in @('.crdownload','.part','.tmp','.download','.partial')) { $skipped++; continue }

        $category = Get-Category $file.Extension
        $destDir = Join-Path $fullTarget $category
        try {
            if (-not (Test-Path -LiteralPath $destDir -PathType Container)) {
                New-Item -ItemType Directory -Path $destDir -ErrorAction Stop | Out-Null
            }
            $dest = Get-UniqueDestination -Directory $destDir -FileName $file.Name
            Move-Item -LiteralPath $file.FullName -Destination $dest -ErrorAction Stop
            Write-LogRecord ([pscustomobject]@{
                timestamp = (Get-Date).ToString('o')
                batchId = $batchId
                action = 'Move'
                source = $file.FullName
                destination = $dest
                category = $category
                status = 'Success'
            })
            Write-Host ("Moved: {0} -> {1}" -f $file.Name, $category) -ForegroundColor Green
            $moved++
        } catch {
            Write-Host ("Could not move {0}: {1}" -f $file.Name, $_.Exception.Message) -ForegroundColor Red
            $failed++
        }
    }
    Write-Host "`nFinished. Moved: $moved | Skipped: $skipped | Failed: $failed" -ForegroundColor Cyan
    if ($moved -gt 0) { Write-Host "Undo information saved in: $script:LogPath" -ForegroundColor Gray }
}

function Invoke-UndoLastBatch {
    $records = @(Read-LogRecords | Where-Object { $_.action -eq 'Move' -and $_.status -eq 'Success' })
    if ($records.Count -eq 0) { Write-Host 'No recorded moves are available to undo.' -ForegroundColor Yellow; return }
    $lastBatch = $records[-1].batchId
    $batchRecords = @($records | Where-Object { $_.batchId -eq $lastBatch })
    Write-Host "Found $($batchRecords.Count) file move(s) in the latest recorded organization." -ForegroundColor Cyan
    $confirm = Read-Host 'Restore these files to their original locations? Type YES to continue'
    if ($confirm -cne 'YES') { Write-Host 'Undo cancelled.' -ForegroundColor Yellow; return }

    $restored = 0; $skipped = 0; $failed = 0
    # Reverse the order in case later moves depend on earlier paths.
    [array]::Reverse($batchRecords)
    foreach ($record in $batchRecords) {
        $src = [string]$record.destination
        $original = [string]$record.source
        try {
            if (-not (Test-Path -LiteralPath $src -PathType Leaf)) { $skipped++; Write-Host "Skipped (moved file not found): $src" -ForegroundColor Yellow; continue }
            if (Test-Path -LiteralPath $original) { $skipped++; Write-Host "Skipped (original path occupied): $original" -ForegroundColor Yellow; continue }
            $parent = Split-Path -Parent $original
            if (-not (Test-Path -LiteralPath $parent -PathType Container)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
            Move-Item -LiteralPath $src -Destination $original -ErrorAction Stop
            Write-LogRecord ([pscustomobject]@{
                timestamp = (Get-Date).ToString('o')
                batchId = $lastBatch
                action = 'Undo'
                source = $src
                destination = $original
                category = $record.category
                status = 'Success'
            })
            Write-Host "Restored: $(Split-Path -Leaf $original)" -ForegroundColor Green
            $restored++
        } catch { Write-Host "Could not restore $src : $($_.Exception.Message)" -ForegroundColor Red; $failed++ }
    }
    Write-Host "`nUndo finished. Restored: $restored | Skipped: $skipped | Failed: $failed" -ForegroundColor Cyan
}

function Show-ActivityLog {
    $records = @(Read-LogRecords)
    if ($records.Count -eq 0) { Write-Host 'The activity log is empty.' -ForegroundColor Yellow; return }
    Write-Host "`nRecent activity (up to 30 entries):" -ForegroundColor Cyan
    $records | Select-Object -Last 30 | ForEach-Object {
        $name = Split-Path -Leaf ([string]$_.source)
        Write-Host ("{0} | {1} | {2} | {3}" -f $_.timestamp, $_.action, $name, $_.status)
    }
    Write-Host "`nFull log: $script:LogPath" -ForegroundColor Gray
}

while ($true) {
    Clear-Host
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host '       SMART ORGANIZER PRO' -ForegroundColor Cyan
    Write-Host '========================================' -ForegroundColor Cyan
    Write-Host '1. Organize a folder'
    Write-Host '2. Undo last organization'
    Write-Host '3. View activity log'
    Write-Host '4. Exit'
    $choice = Read-Host "`nChoose an option (1-4)"
    switch ($choice) {
        '1' { Invoke-Organize; [void](Read-Host "`nPress Enter to return to menu") }
        '2' { Invoke-UndoLastBatch; [void](Read-Host "`nPress Enter to return to menu") }
        '3' { Show-ActivityLog; [void](Read-Host "`nPress Enter to return to menu") }
        '4' { break }
        default { Write-Host 'Please enter 1, 2, 3, or 4.' -ForegroundColor Yellow; Start-Sleep -Seconds 1 }
    }
}
