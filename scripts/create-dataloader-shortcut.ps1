Param(
    [string]$ShortcutName = 'Data Loader Upload',
    [string]$ConfigRelPath = '..\config\job.properties'
)

# Resolve paths
$Desktop = [Environment]::GetFolderPath('Desktop')
$ProjectRoot = 'c:\Users\Abbyl\OneDrive\Desktop\Salesforce Training\Assistant\Assistant'
$ShortcutPath = Join-Path $Desktop ($ShortcutName + '.lnk')

# Find Git Bash (bash.exe)
$GitBash = 'C:\Program Files\Git\bin\bash.exe'
if (-not (Test-Path $GitBash)) {
    $gc = Get-Command bash.exe -ErrorAction SilentlyContinue
    if ($gc) {
        $GitBash = $gc.Source
    } else {
        Write-Error 'Could not find bash.exe. Install Git for Windows (which includes Git Bash) or adjust the path in this script.'
        exit 1
    }
}

# Arguments to run inside Git Bash
# -lc runs the following command, then exits the shell.
# We cd to util dir relative to project root and run util.sh with the requested config.
$InnerCmd = "cd ..\util; ./util.sh --config $ConfigRelPath; echo; echo Press any key to close...; read -n 1 -s"
$BashArgs = "-lc `"$InnerCmd`""

# Create the shortcut
$Wsh = New-Object -ComObject WScript.Shell
$Sc = $Wsh.CreateShortcut($ShortcutPath)
$Sc.TargetPath = $GitBash
$Sc.Arguments = $BashArgs
$Sc.WorkingDirectory = $ProjectRoot
$Sc.IconLocation = $GitBash
$Sc.Save()

Write-Host "Created shortcut: $ShortcutPath"
Write-Host "Target: $GitBash $BashArgs"
Write-Host "WorkingDirectory: $ProjectRoot"
