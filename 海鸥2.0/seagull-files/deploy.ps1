# Seagull Deploy v20.2
# Compatible: Windows 7/8/10/11, PowerShell 2.0-7.x, Core/Desktop

param([switch]$Uninstall, [switch]$Verify, [switch]$Restore)

# ========== FIX 1: Per-call error handling (not global) ==========
$ProgressPreference = 'SilentlyContinue'

# ========== FIX 2: UTF-8 encoding ==========
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
try { [Console]::InputEncoding = [System.Text.Encoding]::UTF8 } catch {}
try { $OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
try { chcp 65001 | Out-Null } catch {}

# ========== FIX 3: Detect PowerShell variant ==========
$PS_FLAVOR = 'Desktop'
$PS_VER = '2.0'
try {
    if ($PSVersionTable.PSEdition -eq 'Core') { $PS_FLAVOR = 'Core' }
    $PS_VER = "$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)"
} catch {}

# ========== FIX 4: Detect OS ==========
$OS_VER = 'Unknown'
$OS_BUILD = 0
try {
    $os = [System.Environment]::OSVersion.Version
    $OS_VER = "$($os.Major).$($os.Minor)"
    $OS_BUILD = $os.Build
} catch {}

# ========== FIX 5: Admin detection ==========
$IS_ADMIN = $false
try {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    $IS_ADMIN = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
} catch {}

# ========== FIX 6: User profile path ==========
$USER_HOME = $env:USERPROFILE
if (!$USER_HOME) {
    try { $USER_HOME = [Environment]::GetFolderPath('UserProfile') } catch {}
    if (!$USER_HOME) {
        # Fallback: try common locations
        foreach ($drive in @('C', 'D', 'E')) {
            $testPath = "${drive}:\Users\$env:USERNAME"
            if (Test-Path $testPath) { $USER_HOME = $testPath; break }
        }
        if (!$USER_HOME) { $USER_HOME = "C:\Users\$env:USERNAME" }
    }
}

# ========== FIX 7: Target directory ==========
$CLAUDE_DIR = Join-Path $USER_HOME '.claude'

# ========== FIX 7b: Auto-detect ALL possible config directories ==========
$ALL_DIRS = @($CLAUDE_DIR)

# Check common desktop version locations
$desktopCandidates = @(
    (Join-Path $env:APPDATA 'claude'),
    (Join-Path $env:APPDATA 'Claude'),
    (Join-Path $env:APPDATA 'Claude-3p'),
    (Join-Path $env:LOCALAPPDATA 'claude-code'),
    (Join-Path $env:LOCALAPPDATA 'claude'),
    (Join-Path $env:LOCALAPPDATA 'Claude'),
    (Join-Path $env:LOCALAPPDATA 'Claude-3p'),
    (Join-Path $USER_HOME 'AppData\Roaming\claude'),
    (Join-Path $USER_HOME 'AppData\Roaming\Claude'),
    (Join-Path $USER_HOME 'AppData\Roaming\Claude-3p'),
    (Join-Path $USER_HOME 'AppData\Local\claude-code'),
    (Join-Path $USER_HOME 'AppData\Local\claude'),
    (Join-Path $USER_HOME 'AppData\Local\Claude'),
    (Join-Path $USER_HOME 'AppData\Local\Claude-3p')
)
foreach ($candidate in $desktopCandidates) {
    if ($candidate -ne $CLAUDE_DIR -and (Test-Path $candidate)) {
        $ALL_DIRS += $candidate
    }
}

Write-Host "[*] Config directories found: $($ALL_DIRS.Count)" -ForegroundColor DarkGray
foreach ($d in $ALL_DIRS) {
    Write-Host "    $d" -ForegroundColor DarkGray
}

# ========== FIX 8: Source directory ==========
$SCRIPT_DIR = $PSScriptRoot
if (!$SCRIPT_DIR) {
    try { $SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path } catch {}
    if (!$SCRIPT_DIR) { $SCRIPT_DIR = (Get-Location).Path }
}
$BUNDLE_DIR = Join-Path $SCRIPT_DIR 'claude-config-bundle'

# ========== FIX 9: UTF-8 write without BOM (PS 2.0 compatible) ==========
function Write-FileUtf8($Path, $Content) {
    $Path = [System.Environment]::ExpandEnvironmentVariables($Path)

    # Method 1: .NET (works on all versions including PS 2.0)
    try {
        $utf8 = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($Path, $Content, $utf8)
        return $true
    } catch {}

    # Method 2: Out-File fallback (adds BOM but works everywhere)
    try {
        $Content | Out-File -FilePath $Path -Encoding UTF8 -Force -ErrorAction Stop
        return $true
    } catch {}

    # Method 3: StreamWriter (PS 2.0 compatible, no BOM)
    try {
        $utf8 = New-Object System.Text.UTF8Encoding $false
        $sw = New-Object System.IO.StreamWriter($Path, $false, $utf8)
        $sw.Write($Content)
        $sw.Close()
        return $true
    } catch {}

    return $false
}

# ========== FIX 10: Safe file copy with retry ==========
function Copy-FileSafe($src, $dst, $retries = 3) {
    for ($i = 0; $i -lt $retries; $i++) {
        try {
            Copy-Item $src $dst -Force -ErrorAction Stop
            return $true
        } catch {
            if ($i -lt ($retries - 1)) {
                Start-Sleep -Milliseconds (500 * ($i + 1))
            }
        }
    }
    return $false
}

# ========== FIX 11: Lock file (PS 2.0 compatible) ==========
function New-LockFile($dir) {
    $lockFile = Join-Path $dir '.seagull-deploy.lock'
    try {
        $utf8 = New-Object System.Text.UTF8Encoding $false
        $sw = New-Object System.IO.StreamWriter($lockFile, $false, $utf8)
        $sw.WriteLine("$env:USERNAME - $(Get-Date)")
        $sw.Close()
        return $true
    } catch {
        return $false
    }
}

function Remove-LockFile($dir) {
    $lockFile = Join-Path $dir '.seagull-deploy.lock'
    Remove-FileSafe $lockFile | Out-Null
}

# ========== FIX 12: Safe directory creation ==========
function New-DirSafe($path) {
    if (Test-Path $path) { return $true }
    try {
        New-Item -ItemType Directory -Path $path -Force -ErrorAction Stop | Out-Null
        return $true
    } catch {}
    try {
        & cmd /c "mkdir `"$path`"" 2>nul
        return (Test-Path $path)
    } catch {}
    return $false
}

# ========== FIX 13: Safe file removal ==========
function Remove-FileSafe($path) {
    if (!(Test-Path $path)) { return $true }
    try {
        Remove-Item $path -Force -ErrorAction Stop
        return $true
    } catch {}
    try {
        & cmd /c "del /f `"$path`"" 2>nul
        return !(Test-Path $path)
    } catch {}
    return $false
}

# ========== FIX 14: Check disk space ==========
function Test-DiskSpace($path, $minMB = 10) {
    try {
        $drive = Split-Path -Qualifier $path -ErrorAction Stop
        if ($drive) {
            $disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='$drive'" -ErrorAction Stop
            if ($disk.FreeSpace -gt ($minMB * 1MB)) { return $true }
            return $false
        }
    } catch {}
    return $true
}

# ========== FIX 15: Check path length ==========
function Test-PathLength($path, $maxLen = 240) {
    $expanded = [System.Environment]::ExpandEnvironmentVariables($path)
    return $expanded.Length -lt $maxLen
}

# ========== FIX 16: Check file not read-only ==========
function Test-FileWritable($path) {
    if (!(Test-Path $path)) { return $true }
    try {
        $item = Get-Item $path -ErrorAction Stop
        if ($item.IsReadOnly) {
            $item.IsReadOnly = $false
        }
        return $true
    } catch {}
    return $false
}

# ========== FIX 17: Check if file is locked ==========
function Test-FileLocked($path) {
    if (!(Test-Path $path)) { return $false }
    try {
        $stream = [System.IO.File]::Open($path, 'Open', 'ReadWrite', 'None')
        $stream.Close()
        return $false
    } catch {
        return $true
    }
}

# ========== FIX 18: Backup with date ==========
function Backup-Config($claudeDir) {
    $date = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupDir = Join-Path $claudeDir "backups\seagull-$date"
    $files = @('CLAUDE.md', 'system-prompt.md', 'config.toml', 'settings.json')
    $count = 0

    foreach ($f in $files) {
        $srcPath = Join-Path $claudeDir $f
        if (Test-Path $srcPath) {
            New-DirSafe $backupDir | Out-Null
            if (Copy-FileSafe $srcPath (Join-Path $backupDir $f)) {
                $count++
            }
        }
    }
    return $count
}

# ========== FIX 19: Restore from latest backup ==========
function Restore-Config($claudeDir) {
    $backupBase = Join-Path $claudeDir "backups"
    if (!(Test-Path $backupBase)) {
        Write-Host "  No backups found" -ForegroundColor DarkGray
        return $false
    }

    $backups = @()
    try { $backups = Get-ChildItem $backupBase -Directory -ErrorAction Stop | Sort-Object Name -Descending } catch {}

    if ($backups.Count -eq 0) {
        Write-Host "  No backups found" -ForegroundColor DarkGray
        return $false
    }

    $latest = $backups[0].FullName
    Write-Host "  Restoring from: $($backups[0].Name)" -ForegroundColor Yellow

    $files = @('CLAUDE.md', 'system-prompt.md', 'config.toml', 'settings.json')
    $restored = 0

    foreach ($f in $files) {
        $srcPath = Join-Path $latest $f
        if (Test-Path $srcPath) {
            if (Copy-FileSafe $srcPath (Join-Path $claudeDir $f)) {
                Write-Host "    Restored $f" -ForegroundColor Green
                $restored++
            }
        }
    }

    return $restored -gt 0
}

# ========== FIX 20: Deploy files ==========
function Deploy-Config($dst, $src) {
    $ok = 0; $fail = 0

    # 1. CLAUDE.md
    Write-Host '[1/4] CLAUDE.md...' -ForegroundColor Yellow
    $file = Join-Path $src 'CLAUDE.md'
    if (Test-Path $file) {
        $dstFile = Join-Path $dst 'CLAUDE.md'
        Test-FileWritable $dstFile | Out-Null
        if (Copy-FileSafe $file $dstFile) {
            $size = (Get-Item $dstFile).Length
            Write-Host "    OK ($size bytes)" -ForegroundColor Green
            $ok++
        } else {
            Write-Host "    FAIL (file locked or permission denied)" -ForegroundColor Red
            $fail++
        }
    } else {
        Write-Host "    NOT FOUND: $file" -ForegroundColor Red
        $fail++
    }

    # 2. system-prompt.md
    Write-Host '[2/4] system-prompt.md...' -ForegroundColor Yellow
    $file = Join-Path $src 'system-prompt.md'
    if (Test-Path $file) {
        $dstFile = Join-Path $dst 'system-prompt.md'
        Test-FileWritable $dstFile | Out-Null
        if (Copy-FileSafe $file $dstFile) {
            $size = (Get-Item $dstFile).Length
            Write-Host "    OK ($size bytes)" -ForegroundColor Green
            $ok++
        } else {
            Write-Host "    FAIL" -ForegroundColor Red
            $fail++
        }
    } else {
        Write-Host "    NOT FOUND: $file" -ForegroundColor Red
        $fail++
    }

    # 3. settings.json (only if not exists, formatted)
    Write-Host '[3/4] settings.json...' -ForegroundColor Yellow
    $settingsPath = Join-Path $dst 'settings.json'
    if (!(Test-Path $settingsPath)) {
        $json = @"
{
  "effortLevel": "xhigh",
  "env": {
    "CLAUDE_CODE_EFFORT_LEVEL": "max",
    "DISABLE_AUTOUPDATER": "1"
  },
  "permissions": {
    "defaultMode": "bypassPermissions"
  },
  "skipDangerousModePermissionPrompt": true
}
"@
        if (Write-FileUtf8 $settingsPath $json) {
            Write-Host "    OK (bypassPermissions)" -ForegroundColor Green
            $ok++
        } else {
            Write-Host "    FAIL" -ForegroundColor Red
            $fail++
        }
    } else {
        Write-Host "    SKIPPED (exists)" -ForegroundColor DarkGray
        $ok++
    }

    # 4. config.toml
    Write-Host '[4/4] config.toml...' -ForegroundColor Yellow
    $configPath = Join-Path $dst 'config.toml'
    Test-FileWritable $configPath | Out-Null
    if (Write-FileUtf8 $configPath 'model_instructions_file = "system-prompt.md"') {
        Write-Host "    OK" -ForegroundColor Green
        $ok++
    } else {
        Write-Host "    FAIL" -ForegroundColor Red
        $fail++
    }

    return @{ Ok = $ok; Fail = $fail }
}

# ========== FIX 21: Uninstall ==========
function Uninstall-Config($dst) {
    $files = @('CLAUDE.md', 'system-prompt.md', 'config.toml')
    $removed = 0

    foreach ($f in $files) {
        $path = Join-Path $dst $f
        if (Test-Path $path) {
            if (Remove-FileSafe $path) {
                Write-Host "    Removed $f" -ForegroundColor Green
                $removed++
            } else {
                Write-Host "    Failed to remove $f" -ForegroundColor Red
            }
        } else {
            Write-Host "    $f not found" -ForegroundColor DarkGray
        }
    }

    return $removed
}

# ========== FIX 22: Verify deployment ==========
function Verify-Config($dst) {
    $checks = @(
        @{ File = 'CLAUDE.md'; Check = 'Greeting'; Pattern = '海鸥在线' },
        @{ File = 'system-prompt.md'; Check = 'Content'; Pattern = '海鸥' },
        @{ File = 'settings.json'; Check = 'Permissions'; Pattern = 'bypassPermissions' },
        @{ File = 'config.toml'; Check = 'Pointer'; Pattern = 'system-prompt.md' }
    )

    $allOk = $true

    foreach ($c in $checks) {
        $path = Join-Path $dst $c.File
        if (Test-Path $path) {
            $size = (Get-Item $path).Length
            $content = ''
            try { $content = Get-Content $path -Raw -ErrorAction Stop } catch {}
            if ($content -match $c.Pattern) {
                Write-Host "    $($c.File) - OK ($size bytes)" -ForegroundColor Green
            } else {
                Write-Host "    $($c.File) - WARNING ($size bytes)" -ForegroundColor Yellow
                $allOk = $false
            }
        } else {
            Write-Host "    $($c.File) - MISSING" -ForegroundColor Red
            $allOk = $false
        }
    }

    return $allOk
}

# ========== FIX 23: Pre-flight checks ==========
function Test-Preflight($dst, $src) {
    $issues = @()

    if (!(Test-DiskSpace $dst)) {
        $issues += 'Low disk space'
    }

    if (!(Test-PathLength $dst)) {
        $issues += 'Path too long (>240 chars)'
    }

    if (!(Test-Path $src)) {
        $issues += "Source directory not found: $src"
    }

    $required = @('CLAUDE.md', 'system-prompt.md')
    foreach ($f in $required) {
        if (!(Test-Path (Join-Path $src $f))) {
            $issues += "Missing source file: $f"
        }
    }

    return $issues
}

# ========== FIX 24: Display environment info ==========
function Show-Environment {
    Write-Host "[*] User: $env:USERNAME" -ForegroundColor DarkGray
    Write-Host "[*] PS: $PS_VER ($PS_FLAVOR)" -ForegroundColor DarkGray
    Write-Host "[*] OS: $OS_VER (Build $OS_BUILD)" -ForegroundColor DarkGray
    Write-Host "[*] Admin: $IS_ADMIN" -ForegroundColor DarkGray
    Write-Host "[*] Home: $USER_HOME" -ForegroundColor DarkGray
    Write-Host "[*] Target: $CLAUDE_DIR" -ForegroundColor DarkGray
}

# ========== FIX 25: Show warnings ==========
function Show-Warnings {
    $warnings = @()

    if ($USER_HOME -match '[^\x00-\x7F]') {
        $warnings += 'User profile contains non-ASCII characters'
    }

    if ($USER_HOME -match '\s') {
        $warnings += 'User profile path contains spaces'
    }

    if ($CLAUDE_DIR.Length -gt 200) {
        $warnings += 'Target path is very long'
    }

    try {
        if ($PSVersionTable.PSVersion.Major -lt 3) {
            $warnings += 'PowerShell version is very old, some features may not work'
        }
    } catch {}

    foreach ($w in $warnings) {
        Write-Host "[!] $w" -ForegroundColor Yellow
    }

    return $warnings.Count
}

# ========== MAIN ==========

Write-Host ''
Write-Host '============================================' -ForegroundColor Cyan
Write-Host '  Seagull Deploy v22.5' -ForegroundColor Green
Write-Host '============================================' -ForegroundColor Cyan
Write-Host ''

Show-Environment
$warnCount = Show-Warnings
if ($warnCount -gt 0) { Write-Host '' }

# ---- Uninstall ----
if ($Uninstall) {
    Write-Host 'Uninstalling...' -ForegroundColor Yellow
    $removed = Uninstall-Config $CLAUDE_DIR
    Write-Host ''
    Write-Host "Removed $removed files" -ForegroundColor Cyan
    Write-Host ''
    Read-Host 'Press Enter to exit'
    exit
}

# ---- Verify ----
if ($Verify) {
    Write-Host 'Verifying deployment...' -ForegroundColor Yellow
    $ok = Verify-Config $CLAUDE_DIR
    Write-Host ''
    if ($ok) {
        Write-Host 'All checks passed!' -ForegroundColor Green
    } else {
        Write-Host 'Some checks failed. Run deploy first.' -ForegroundColor Yellow
    }
    Write-Host ''
    Read-Host 'Press Enter to exit'
    exit
}

# ---- Restore ----
if ($Restore) {
    Write-Host 'Restoring from backup...' -ForegroundColor Yellow
    $restored = Restore-Config $CLAUDE_DIR
    Write-Host ''
    if ($restored) {
        Write-Host 'Restore complete!' -ForegroundColor Green
    } else {
        Write-Host 'No backup to restore.' -ForegroundColor Yellow
    }
    Write-Host ''
    Read-Host 'Press Enter to exit'
    exit
}

# ---- Deploy ----

# Pre-flight checks
$preflight = Test-Preflight $CLAUDE_DIR $BUNDLE_DIR
if ($preflight.Count -gt 0) {
    Write-Host '[!] Pre-flight issues:' -ForegroundColor Red
    foreach ($p in $preflight) {
        Write-Host "    - $p" -ForegroundColor Red
    }
    Write-Host ''
    Read-Host 'Press Enter to exit'
    exit 1
}

# Check for concurrent deployment
$lockFile = Join-Path $CLAUDE_DIR '.seagull-deploy.lock'
if (Test-Path $lockFile) {
    Write-Host '[!] Another deployment may be in progress' -ForegroundColor Yellow
    Write-Host "    Lock file: $lockFile" -ForegroundColor DarkGray
    Write-Host '    If you are sure no other deploy is running, delete the lock file' -ForegroundColor DarkGray
    Write-Host ''
    $continue = Read-Host 'Continue anyway? (Y/N)'
    if ($continue -ne 'Y' -and $continue -ne 'y') {
        exit 0
    }
}

# Ensure target directory
if (!(Test-Path $CLAUDE_DIR)) {
    if (New-DirSafe $CLAUDE_DIR) {
        Write-Host '[+] Created .claude directory' -ForegroundColor Yellow
    } else {
        Write-Host '[!] Failed to create .claude directory' -ForegroundColor Red
        if (!$IS_ADMIN) {
            Write-Host '    Try running as administrator' -ForegroundColor Red
        }
        Read-Host 'Press Enter to exit'
        exit 1
    }
}

# Create lock file
New-LockFile $CLAUDE_DIR | Out-Null

# Backup
$backupCount = Backup-Config $CLAUDE_DIR
if ($backupCount -gt 0) {
    Write-Host "[*] Backed up $backupCount existing files" -ForegroundColor DarkGray
}

# Deploy
$result = Deploy-Config $CLAUDE_DIR $BUNDLE_DIR

# Remove lock file
Remove-LockFile $CLAUDE_DIR

# Deploy to ALL detected config directories
foreach ($dir in $ALL_DIRS) {
    if ($dir -ne $CLAUDE_DIR) {
        Write-Host ''
        Write-Host "[*] Deploying to: $dir" -ForegroundColor Yellow
        $dirResult = Deploy-Config $dir $BUNDLE_DIR
        if ($dirResult.Fail -eq 0) {
            Write-Host "    Deploy complete! ($($dirResult.Ok)/4)" -ForegroundColor Green
        } else {
            Write-Host "    Deploy done ($($dirResult.Ok) ok, $($dirResult.Fail) fail)" -ForegroundColor Yellow
        }
    }
}

# Summary
Write-Host ''
Write-Host '============================================' -ForegroundColor Cyan
if ($result.Fail -eq 0) {
    Write-Host "  Deploy complete! ($($result.Ok)/4)" -ForegroundColor Green
} else {
    Write-Host "  Deploy done ($($result.Ok) ok, $($result.Fail) fail)" -ForegroundColor Yellow
    if (!$IS_ADMIN) {
        Write-Host '  Try running as administrator if issues persist' -ForegroundColor DarkGray
    }
}
Write-Host ''
Write-Host '  Restart Claude Code and test.' -ForegroundColor Cyan
Write-Host '============================================' -ForegroundColor Cyan
Write-Host ''
Read-Host 'Press Enter to exit'
