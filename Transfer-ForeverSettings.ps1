<#
.SYNOPSIS
    1337cookie's WoW setting transfer utility
    Lists all logged in accounts, realms, and characters for the Forever client
    and transfers settings account-wide and per-character.

.DESCRIPTION
    Standalone PowerShell script designed to run directly from local file or URL via IEX.
    - Self-elevates to Administrator (with automatic temporary file caching when run via IEX)
    - Hides console/terminal window
    - Embeds logo.png as binary base64 for window icon and header display
    - Clean greyscale background with crisp white typography
#>

# =========================================================================
# Step 1: Hide Console Window
# =========================================================================
try {
    if (-not ([System.Management.Automation.PSTypeName]'Win32Internal.WinAPI').Type) {
        Add-Type -Name WinAPI -Namespace Win32Internal -MemberDefinition '
        [DllImport("Kernel32.dll")]
        public static extern IntPtr GetConsoleWindow();

        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
        '
    }
    $hConsole = [Win32Internal.WinAPI]::GetConsoleWindow()
    if ($hConsole -ne [IntPtr]::Zero) {
        [Win32Internal.WinAPI]::ShowWindow($hConsole, 0) | Out-Null
    }
} catch {}

# =========================================================================
# Step 2: Administrator Elevation Check (with IEX In-Memory Support)
# =========================================================================
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $scriptToRun = $null
    if ($PSCommandPath -and (Test-Path -LiteralPath $PSCommandPath)) {
        $scriptToRun = $PSCommandPath
    } else {
        # Running via IEX / in-memory string: cache script text to temp file
        $scriptToRun = Join-Path $env:TEMP "1337cookie_WoW_Transfer.ps1"
        $scriptDef = if ($MyInvocation.MyCommand.Definition) {
            $MyInvocation.MyCommand.Definition
        } else {
            $MyInvocation.Line
        }
        [System.IO.File]::WriteAllText($scriptToRun, $scriptDef, [System.Text.Encoding]::UTF8)
    }

    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "powershell.exe"
        $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptToRun`""
        $psi.Verb = "RunAs"
        $psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
        $psi.UseShellExecute = $true
        [System.Diagnostics.Process]::Start($psi) | Out-Null
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Administrator elevation is required to modify World of Warcraft settings in Program Files.`n`nError: $($_.Exception.Message)",
            "1337cookie's WoW setting transfer utility",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
    }
    exit
}

# =========================================================================
# Step 3: Assemblies and Embedded Binary Assets
# =========================================================================
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Embedded logo.png (420x420 RGBA)
$EmbeddedLogoBase64 = "iVBORw0KGgoAAAANSUhEUgAAAaQAAAGkCAYAAAB+TFE1AAAACXBIWXMAAA7EAAAOxAGVKw4bAAAF+mlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS42LWMxNDUgNzkuMTYzNDk5LCAyMDE4LzA4LzEzLTE2OjQwOjIyICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RFdnQ9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZUV2ZW50IyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ0MgMjAxOSAoV2luZG93cykiIHhtcDpDcmVhdGVEYXRlPSIyMDIwLTA5LTA3VDE4OjA0OjI2KzEyOjAwIiB4bXA6TW9kaWZ5RGF0ZT0iMjAyMS0wNC0yOFQyMDoxNToxNysxMjowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMS0wNC0yOFQyMDoxNToxNysxMjowMCIgZGM6Zm9ybWF0PSJpbWFnZS9wbmciIHBob3Rvc2hvcDpDb2xvck1vZGU9IjMiIHBob3Rvc2hvcDpJQ0NQcm9maWxlPSJzUkdCIElFQzYxOTY2LTIuMSIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDo4NTczMzExZC1iMDZhLTQyNGUtYTlhNy0wODlhNGQ2OGE0YzYiIHhtcE1NOkRvY3VtZW50SUQ9ImFkb2JlOmRvY2lkOnBob3Rvc2hvcDo2ZGY5ZjhmMS05NDNjLTZlNGItYmFkZS1lN2JkYjUwNGUzOGMiIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDoxNTBjYzBjZS03ZTE3LTc4NGMtYjY4OS03YmQzNWI0MDI2YTUiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjE1MGNjMGNlLTdlMTctNzg0Yy1iNjg5LTdiZDM1YjQwMjZhNSIgc3RFdnQ6d2hlbj0iMjAyMC0wOS0wN1QxODowNDoyNisxMjowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTkgKFdpbmRvd3MpIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDo4NTczMzExZC1iMDZhLTQyNGUtYTlhNy0wODlhNGQ2OGE0YzYiIHN0RXZ0OndoZW49IjIwMjEtMDQtMjhUMjA6MTU6MTcrMTI6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCBDQyAyMDE5IChXaW5kb3dzKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz6qe3wYAAAFLElEQVR42u3XwQ3CMBBFQVZKK+5im3IlbspduJjljDiBAglkpoTvxE/equoGAEfbTACAIAGAIAEgSAAgSAAIEgAIEgCCBACCBIAgAYAgASBIACBIAAgSAAgSAIIEAIIEgCABgCABIEgAIEgACBIACBIAggQAggSAIAGAIAEgSAAgSAAIEgAIEgCCBACCBACCBIAgPVt9liPhFW1kWMF/xH/8R15IAHghAYAgASBIACBIAAgSAAgSAIIEAIIEgCABgCABIEgAIEgACBIACBIAggQAggSAIAGAIAEgSAAgSAAIEgAIEgCCBACCBIAgAYAgASBIACBIAAgSAAgSAIIEAIIEAIIEgCABgCABIEgAIEgACBIACBIAggQAggSAIAGAIAEgSAAgSAAIEgAIEgCCBACCBIAgAYAgASBIACBIAAgSAAgSAIIEAIIEgCABgCABIEgAIEgACBIACBIAggQAggQAggSAIAGAIAEgSLCv1WdZAQRpd21kOBKXLrhjBAkABAkAQQIAQQIAQQJAkABAkAAQJAAQJAAECQAECQBBAgBBAkCQAECQABAkABAkAAQJAAQJAEECAEECQJAAQJAAECQAECQABAkABAkAQQIAQQJAkABAkAAQJAAQJAAECQAECQBBMgEAggQAggSAIAGAIAEgSAAgSAAIEgAIEgCCBACCBIAgAYAgASBIACBIAAgSAAgSAIIEAIIEgCABgCABIEgAIEgACBIACBIAggQAggSAIAGAIAEgSAAgSAAIEgAIEgCcLEirz3IkgDvmu9rIECQAECQABAkABAkAQQIAQQJAkABAkAAQJAAQJAAECQAECQBBAgBBAkCQAECQABAkABAkAAQJAAQJAEECAEECQJAAQJAAECQAECQABAkABAkAQQIAQQJAkABAkABAkAAQJAAQJAAECQAECQBBAgBBAkCQAECQABAkABAkAAQJAAQJAEECAEECQJAAQJAAECQAECQABAkABAkAQQIAQQJAkABAkAAQJAAQJAAECQAECQBBAgBBAkCQAECQAECQABAkABAkAAQJAAQJAEGCj2gjwwqPVp9lBQQJAAQJAEECAEECQJAAQJAAECQAECQABAkABAkAQQIAQQJAkABAkAAQJAAQJAAECQAECQBBAgBBAgBBAkCQAECQABAkABAkAAQJAAQJAEECAEECQJAAQJAAECQAECQABAkABAkAQQIAQQJAkABAkAAQJAAQJAAECQAECQBBAgBBAkCQAECQABAkABAkAAQJAAQJAEECAEECAEECQJAAQJAAECQAECQABAkABAkAQQIAQQJAkABAkAAQJAAQJAAECQAECQBBAgBBupI2MqyAb+V9q8+ygiABgCABIEgAIEgACBIACBIAggQAggSAIAGAIAEgSAAgSAAIEgAIEgCCBACCBIAgAYAgASBIACBIAAgSAAgSAIIEAIIEgCABgCABgCABIEgAIEgACBIACBIAggQAggSAIAGAIAEgSAAgSAAIEgAIEgCCBACCBIAgAYAgASBIACBIAAgSAAgSAIIEAIIEgCABgCABIEgAIEgACBIACBIAggQAggSAIJkAAEECAEECQJAAQJAAECQAECQABAkABAkAQQIAQQJAkADgl4PURoYjAdwvggQAggSAIAGAIAGAIAEgSAAgSAAIEgAIEgCCBACCBIAgAYAgASBIACBIAAgSAAgSAIIEAIIEgCABgCABIEgAIEgACBIACBIAggQAggSAIAGAIAEgSAAgSAAIEgAIEgCXdQdUFStwYmKHswAAAABJRU5ErkJggg=="

$logoBytes = [System.Convert]::FromBase64String($EmbeddedLogoBase64)
$logoMs = New-Object System.IO.MemoryStream(,$logoBytes)
$global:AppLogoBitmap = [System.Drawing.Bitmap]::FromStream($logoMs)
$global:AppIcon = [System.Drawing.Icon]::FromHandle($global:AppLogoBitmap.GetHicon())

# =========================================================================
# Step 4: Core Domain Helpers
# =========================================================================
function Ensure-Directory {
    param([string]$Path)
    if (-not [string]::IsNullOrWhiteSpace($Path)) {
        [System.IO.Directory]::CreateDirectory($Path) | Out-Null
    }
}

function Get-DefaultForeverWtfPath {
    $candidates = @(
        "C:\Program Files (x86)\World of Warcraft\_forever_\WTF",
        "C:\Program Files\World of Warcraft\_forever_\WTF",
        "D:\World of Warcraft\_forever_\WTF",
        "E:\World of Warcraft\_forever_\WTF",
        "C:\Games\World of Warcraft\_forever_\WTF",
        "D:\Games\World of Warcraft\_forever_\WTF"
    )

    $regKeys = @(
        "HKLM:\SOFTWARE\WOW6432Node\Blizzard Entertainment\World of Warcraft",
        "HKLM:\SOFTWARE\Blizzard Entertainment\World of Warcraft",
        "HKCU:\Software\Blizzard Entertainment\World of Warcraft"
    )
    foreach ($rk in $regKeys) {
        try {
            $val = Get-ItemPropertyValue -Path $rk -Name "InstallPath" -ErrorAction SilentlyContinue
            if ($val) {
                $candidates += (Join-Path $val "_forever_\WTF")
            }
        } catch {}
    }

    foreach ($p in $candidates) {
        if (Test-Path -LiteralPath $p) {
            return (Get-Item -LiteralPath $p).FullName
        }
    }
    return "C:\Program Files (x86)\World of Warcraft\_forever_\WTF"
}

function Get-RunningWowClientProcesses {
    return Get-Process -Name "Wow*", "World*" -ErrorAction SilentlyContinue |
        Where-Object { $_.ProcessName -notmatch "worldserver|bnetserver|mysql" }
}

function Scan-WtfHierarchy {
    param([string]$WtfPath)

    $hierarchy = [PSCustomObject]@{
        WtfPath         = $WtfPath
        AccountFolder   = (Join-Path $WtfPath "Account")
        Exists          = (Test-Path -LiteralPath $WtfPath)
        Accounts        = @()
        TotalAccounts   = 0
        TotalRealms     = 0
        TotalCharacters = 0
    }

    if (-not (Test-Path -LiteralPath $hierarchy.AccountFolder)) {
        return $hierarchy
    }

    $accountDirs = Get-ChildItem -LiteralPath $hierarchy.AccountFolder -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne "SavedVariables" }

    $allAccounts = @()
    foreach ($accDir in $accountDirs) {
        $accName = $accDir.Name

        $accFiles = @{
            Bindings = (Test-Path -LiteralPath (Join-Path $accDir.FullName "bindings-cache.wtf"))
            Config   = (Test-Path -LiteralPath (Join-Path $accDir.FullName "config-cache.wtf"))
            Macros   = (Test-Path -LiteralPath (Join-Path $accDir.FullName "macros-cache.txt"))
            EditMode = (Test-Path -LiteralPath (Join-Path $accDir.FullName "edit-mode-cache-account.txt"))
            Chat     = (Test-Path -LiteralPath (Join-Path $accDir.FullName "chat-cache.txt"))
            TTS      = (Test-Path -LiteralPath (Join-Path $accDir.FullName "tts-cache-account.txt"))
            Flagged  = (Test-Path -LiteralPath (Join-Path $accDir.FullName "flagged-cache-account.txt"))
            Layout   = (Test-Path -LiteralPath (Join-Path $accDir.FullName "layout-local.txt"))
        }

        $svDir = Join-Path $accDir.FullName "SavedVariables"
        $svFiles = @()
        if (Test-Path -LiteralPath $svDir) {
            $svFiles = Get-ChildItem -LiteralPath $svDir -Filter "*.lua" -File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
        }

        $realmDirs = Get-ChildItem -LiteralPath $accDir.FullName -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -ne "SavedVariables" }

        $realms = @()
        foreach ($rDir in $realmDirs) {
            $realmName = $rDir.Name

            $charDirs = Get-ChildItem -LiteralPath $rDir.FullName -Directory -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -ne "SavedVariables" }

            $characters = @()
            foreach ($cDir in $charDirs) {
                $charName = $cDir.Name

                $charSvDir = Join-Path $cDir.FullName "SavedVariables"
                $charSvFiles = @()
                if (Test-Path -LiteralPath $charSvDir) {
                    $charSvFiles = Get-ChildItem -LiteralPath $charSvDir -Filter "*.lua" -File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
                }

                $charFiles = @{
                    Layout        = (Test-Path -LiteralPath (Join-Path $cDir.FullName "layout-local.txt"))
                    EditMode      = (Test-Path -LiteralPath (Join-Path $cDir.FullName "edit-mode-cache-character.txt"))
                    Config        = (Test-Path -LiteralPath (Join-Path $cDir.FullName "config-cache.wtf"))
                    Chat          = (Test-Path -LiteralPath (Join-Path $cDir.FullName "chat-cache.txt"))
                    Bindings      = (Test-Path -LiteralPath (Join-Path $cDir.FullName "bindings-cache.wtf"))
                    ClickBindings = (Test-Path -LiteralPath (Join-Path $cDir.FullName "click-bindings-cache.txt"))
                    Macros        = (Test-Path -LiteralPath (Join-Path $cDir.FullName "macros-cache.txt"))
                    AddOns        = (Test-Path -LiteralPath (Join-Path $cDir.FullName "AddOns.txt"))
                    TTS           = (Test-Path -LiteralPath (Join-Path $cDir.FullName "tts-cache-character.txt"))
                    Flagged       = (Test-Path -LiteralPath (Join-Path $cDir.FullName "flagged-cache-character.txt"))
                }

                $characters += [PSCustomObject]@{
                    Name                = $charName
                    Account             = $accName
                    Realm               = $realmName
                    Path                = $cDir.FullName
                    Files               = $charFiles
                    SavedVariables      = $charSvFiles
                    SavedVariablesCount = $charSvFiles.Count
                    LastWriteTime       = $cDir.LastWriteTime
                }
            }

            $realms += [PSCustomObject]@{
                Name        = $realmName
                Account     = $accName
                Path        = $rDir.FullName
                Characters  = $characters
            }
        }

        $allAccounts += [PSCustomObject]@{
            Name                = $accName
            Path                = $accDir.FullName
            Files               = $accFiles
            SavedVariables      = $svFiles
            SavedVariablesCount = $svFiles.Count
            Realms              = $realms
            LastWriteTime       = $accDir.LastWriteTime
        }
    }

    $hierarchy.Accounts = $allAccounts
    $hierarchy.TotalAccounts = $allAccounts.Count
    $hierarchy.TotalRealms = ($allAccounts | ForEach-Object { $_.Realms.Count } | Measure-Object -Sum).Sum
    $hierarchy.TotalCharacters = ($allAccounts | ForEach-Object { $_.Realms | ForEach-Object { $_.Characters.Count } } | Measure-Object -Sum).Sum

    return $hierarchy
}

function New-WtfBackup {
    param(
        [string]$WtfPath,
        [string]$TargetFolder,
        [string]$BackupType,
        [string]$TargetName
    )
    if (-not (Test-Path -LiteralPath $TargetFolder)) {
        return $null
    }

    $backupRoot = Join-Path $WtfPath "_TransferBackups"
    Ensure-Directory $backupRoot

    $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
    $safeName = "${timestamp}_${BackupType}_" + ($TargetName -replace '[\\/:*?"<>| #]', '_')
    $backupDir = Join-Path $backupRoot $safeName
    Ensure-Directory $backupDir

    Get-ChildItem -LiteralPath $TargetFolder -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
        $rel = $_.FullName.Substring($TargetFolder.Length).TrimStart('\', '/')
        $dest = Join-Path $backupDir $rel
        Ensure-Directory ([System.IO.Path]::GetDirectoryName($dest))
        Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
    }

    $manifest = [PSCustomObject]@{
        Timestamp    = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        BackupType   = $BackupType
        TargetName   = $TargetName
        TargetFolder = $TargetFolder
        BackupDir    = $backupDir
    }
    $manifest | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $backupDir "manifest.json") -Encoding UTF8

    return $backupDir
}

function Copy-FileWithOldVariant {
    param(
        [string]$SourceFolder,
        [string]$TargetFolder,
        [string]$FileName,
        [ref]$Count
    )
    $variants = @($FileName, ($FileName -replace '\.[^.]+$', '.old'))
    foreach ($v in $variants) {
        $src = Join-Path $SourceFolder $v
        if (Test-Path -LiteralPath $src) {
            $dst = Join-Path $TargetFolder $v
            Ensure-Directory ([System.IO.Path]::GetDirectoryName($dst))
            Copy-Item -LiteralPath $src -Destination $dst -Force
            $Count.Value++
        }
    }
}

function Copy-AddonSavedVariables {
    param(
        [string]$SourceFolder,
        [string]$TargetFolder,
        [ref]$Count
    )
    $srcSv = Join-Path $SourceFolder "SavedVariables"
    if (Test-Path -LiteralPath $srcSv) {
        $dstSv = Join-Path $TargetFolder "SavedVariables"
        Ensure-Directory $dstSv
        Get-ChildItem -LiteralPath $srcSv -File -ErrorAction SilentlyContinue | ForEach-Object {
            $dest = Join-Path $dstSv $_.Name
            Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
            $Count.Value++
        }
    }
}

function Remove-CacheHash {
    param([string]$TargetFolder)
    $cacheFile = Join-Path $TargetFolder "cache.md5"
    if (Test-Path -LiteralPath $cacheFile) {
        Remove-Item -LiteralPath $cacheFile -Force -ErrorAction SilentlyContinue
    }
}

# =========================================================================
# Step 5: Pure Greyscale Theme Configuration
# =========================================================================
$currentWtfPath = Get-DefaultForeverWtfPath
$global:WtfHierarchy = Scan-WtfHierarchy $currentWtfPath

# Neutral Greyscale Palette (zero color tints)
$cWindowBg    = [System.Drawing.Color]::FromArgb(26, 26, 26)
$cHeaderBg    = [System.Drawing.Color]::FromArgb(18, 18, 18)
$cCardBg      = [System.Drawing.Color]::FromArgb(35, 35, 35)
$cCardBorder  = [System.Drawing.Color]::FromArgb(55, 55, 55)
$cInputBg     = [System.Drawing.Color]::FromArgb(20, 20, 20)
$cLogBg       = [System.Drawing.Color]::FromArgb(14, 14, 14)
$cAlertBg     = [System.Drawing.Color]::FromArgb(38, 38, 38)
$cAlertBorder = [System.Drawing.Color]::FromArgb(65, 65, 65)

# Typography (pure white for all headers/text, light grey for muted subtitles)
$cTextWhite   = [System.Drawing.Color]::FromArgb(255, 255, 255)
$cTextMuted   = [System.Drawing.Color]::FromArgb(180, 180, 180)
$cTextLog     = [System.Drawing.Color]::FromArgb(235, 235, 235)

# Action button backgrounds (clean solid tones)
$cBtnPrimary  = [System.Drawing.Color]::FromArgb(45, 125, 50)   # Clean Forest Green
$cBtnSecondary= [System.Drawing.Color]::FromArgb(44, 44, 44)   # Greyscale button
$cBtnBatch    = [System.Drawing.Color]::FromArgb(38, 65, 100)  # Steel blue accent
$cBtnAlert    = [System.Drawing.Color]::FromArgb(170, 45, 45)  # Crimson button

# Form Setup
$form = New-Object System.Windows.Forms.Form
$form.Text = "1337cookie's WoW setting transfer utility"
$form.Icon = $global:AppIcon
$form.Size = New-Object System.Drawing.Size(1060, 800)
$form.MinimumSize = New-Object System.Drawing.Size(960, 720)
$form.StartPosition = "CenterScreen"
$form.BackColor = $cWindowBg
$form.ForeColor = $cTextWhite
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# Logger function
function Log-Msg {
    param([string]$Message, [string]$Type = "INFO")
    $ts = (Get-Date).ToString("HH:mm:ss")
    $tag = "[$Type]"
    $line = "[$ts] $tag $Message`r`n"
    if ($txtLog -and -not $txtLog.IsDisposed) {
        $txtLog.AppendText($line)
        $txtLog.SelectionStart = $txtLog.TextLength
        $txtLog.ScrollToCaret()
    }
}

# -------------------------------------------------------------------------
# Top Header Panel with Embedded Logo
# -------------------------------------------------------------------------
$pnlHeader = New-Object System.Windows.Forms.Panel
$pnlHeader.Dock = [System.Windows.Forms.DockStyle]::Top
$pnlHeader.Height = 124
$pnlHeader.BackColor = $cHeaderBg
$pnlHeader.Padding = New-Object System.Windows.Forms.Padding(14, 8, 14, 8)
$form.Controls.Add($pnlHeader)

# Logo PictureBox
$picLogo = New-Object System.Windows.Forms.PictureBox
$picLogo.Size = New-Object System.Drawing.Size(66, 66)
$picLogo.Location = New-Object System.Drawing.Point(14, 12)
$picLogo.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
$picLogo.Image = $global:AppLogoBitmap
$picLogo.BackColor = [System.Drawing.Color]::Transparent
$pnlHeader.Controls.Add($picLogo)

# Heading Title (Pure White)
$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "1337cookie's WoW setting transfer utility"
$lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$lblTitle.ForeColor = $cTextWhite
$lblTitle.AutoSize = $true
$lblTitle.Location = New-Object System.Drawing.Point(90, 11)
$pnlHeader.Controls.Add($lblTitle)

# Subtitle
$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text = "Clone UI frame layouts, modern edit mode, keybinds, macros, CVars & addon databases across accounts and characters"
$lblSub.Font = New-Object System.Drawing.Font("Segoe UI", 8.5)
$lblSub.ForeColor = $cTextMuted
$lblSub.AutoSize = $true
$lblSub.Location = New-Object System.Drawing.Point(92, 38)
$pnlHeader.Controls.Add($lblSub)

# Path selection controls
$lblWtf = New-Object System.Windows.Forms.Label
$lblWtf.Text = "WTF Folder:"
$lblWtf.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$lblWtf.ForeColor = $cTextWhite
$lblWtf.AutoSize = $true
$lblWtf.Location = New-Object System.Drawing.Point(92, 63)
$pnlHeader.Controls.Add($lblWtf)

$txtWtfPath = New-Object System.Windows.Forms.TextBox
$txtWtfPath.Text = $currentWtfPath
$txtWtfPath.Location = New-Object System.Drawing.Point(176, 60)
$txtWtfPath.Size = New-Object System.Drawing.Size(490, 24)
$txtWtfPath.BackColor = $cInputBg
$txtWtfPath.ForeColor = $cTextWhite
$txtWtfPath.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$pnlHeader.Controls.Add($txtWtfPath)

$btnBrowse = New-Object System.Windows.Forms.Button
$btnBrowse.Text = "Browse..."
$btnBrowse.Location = New-Object System.Drawing.Point(674, 58)
$btnBrowse.Size = New-Object System.Drawing.Size(80, 28)
$btnBrowse.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnBrowse.FlatAppearance.BorderColor = $cCardBorder
$btnBrowse.BackColor = $cBtnSecondary
$btnBrowse.ForeColor = $cTextWhite
$btnBrowse.Cursor = [System.Windows.Forms.Cursors]::Hand
$pnlHeader.Controls.Add($btnBrowse)

$btnRescan = New-Object System.Windows.Forms.Button
$btnRescan.Text = "Rescan"
$btnRescan.Location = New-Object System.Drawing.Point(758, 58)
$btnRescan.Size = New-Object System.Drawing.Size(80, 28)
$btnRescan.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRescan.FlatAppearance.BorderColor = $cCardBorder
$btnRescan.BackColor = $cBtnSecondary
$btnRescan.ForeColor = $cTextWhite
$btnRescan.Cursor = [System.Windows.Forms.Cursors]::Hand
$pnlHeader.Controls.Add($btnRescan)

$btnOpenFolder = New-Object System.Windows.Forms.Button
$btnOpenFolder.Text = "Open Folder"
$btnOpenFolder.Location = New-Object System.Drawing.Point(842, 58)
$btnOpenFolder.Size = New-Object System.Drawing.Size(95, 28)
$btnOpenFolder.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnOpenFolder.FlatAppearance.BorderColor = $cCardBorder
$btnOpenFolder.BackColor = $cBtnSecondary
$btnOpenFolder.ForeColor = $cTextWhite
$btnOpenFolder.Cursor = [System.Windows.Forms.Cursors]::Hand
$pnlHeader.Controls.Add($btnOpenFolder)

# WoW running alert bar (Greyscale background, White text)
$pnlWowAlert = New-Object System.Windows.Forms.Panel
$pnlWowAlert.Location = New-Object System.Drawing.Point(14, 92)
$pnlWowAlert.Size = New-Object System.Drawing.Size(1012, 26)
$pnlWowAlert.BackColor = $cAlertBg
$pnlHeader.Controls.Add($pnlWowAlert)

$lblWowAlert = New-Object System.Windows.Forms.Label
$lblWowAlert.Text = "Checking WoW client status..."
$lblWowAlert.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
$lblWowAlert.ForeColor = $cTextWhite
$lblWowAlert.Location = New-Object System.Drawing.Point(8, 4)
$lblWowAlert.AutoSize = $true
$pnlWowAlert.Controls.Add($lblWowAlert)

$btnCloseWow = New-Object System.Windows.Forms.Button
$btnCloseWow.Text = "Close WoW Client"
$btnCloseWow.Location = New-Object System.Drawing.Point(780, 2)
$btnCloseWow.Size = New-Object System.Drawing.Size(130, 22)
$btnCloseWow.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnCloseWow.FlatAppearance.BorderColor = $cCardBorder
$btnCloseWow.BackColor = $cBtnAlert
$btnCloseWow.ForeColor = $cTextWhite
$btnCloseWow.Font = New-Object System.Drawing.Font("Segoe UI", 7.5, [System.Drawing.FontStyle]::Bold)
$btnCloseWow.Cursor = [System.Windows.Forms.Cursors]::Hand
$btnCloseWow.Visible = $false
$pnlWowAlert.Controls.Add($btnCloseWow)

$btnRecheckWow = New-Object System.Windows.Forms.Button
$btnRecheckWow.Text = "Recheck"
$btnRecheckWow.Location = New-Object System.Drawing.Point(916, 2)
$btnRecheckWow.Size = New-Object System.Drawing.Size(75, 22)
$btnRecheckWow.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRecheckWow.FlatAppearance.BorderColor = $cCardBorder
$btnRecheckWow.BackColor = $cBtnSecondary
$btnRecheckWow.ForeColor = $cTextWhite
$btnRecheckWow.Font = New-Object System.Drawing.Font("Segoe UI", 7.5)
$btnRecheckWow.Cursor = [System.Windows.Forms.Cursors]::Hand
$pnlWowAlert.Controls.Add($btnRecheckWow)

function Update-WowStatus {
    $procs = Get-RunningWowClientProcesses
    if ($procs -and $procs.Count -gt 0) {
        $pnlWowAlert.BackColor = [System.Drawing.Color]::FromArgb(50, 30, 30)
        $procNames = ($procs | ForEach-Object { "$($_.ProcessName) (PID: $($_.Id))" }) -join ", "
        $lblWowAlert.Text = "WARNING: WoW is running ($procNames). WoW overwrites WTF files on logout! Exit WoW before copying."
        $lblWowAlert.ForeColor = $cTextWhite
        $btnCloseWow.Visible = $true
    } else {
        $pnlWowAlert.BackColor = $cAlertBg
        $lblWowAlert.Text = "WoW client is closed. Safe to transfer settings."
        $lblWowAlert.ForeColor = $cTextWhite
        $btnCloseWow.Visible = $false
    }
}

$btnCloseWow.Add_Click({
    $procs = Get-RunningWowClientProcesses
    if ($procs) {
        $confirm = [System.Windows.Forms.MessageBox]::Show(
            "Terminate running WoW process(es)? Unsaved in-game settings will be discarded.",
            "Confirm Close WoW",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )
        if ($confirm -eq [System.Windows.Forms.DialogResult]::Yes) {
            foreach ($p in $procs) {
                try {
                    Stop-Process -Id $p.Id -Force
                    Log-Msg "Terminated process $($p.ProcessName) (PID: $($p.Id))" "ALERT"
                } catch {
                    Log-Msg "Could not terminate process $($p.ProcessName): $($_.Exception.Message)" "ERROR"
                }
            }
            Start-Sleep -Milliseconds 500
            Update-WowStatus
        }
    }
})

$btnRecheckWow.Add_Click({
    Update-WowStatus
})

# -------------------------------------------------------------------------
# Bottom Panel: Log & Status Strip
# -------------------------------------------------------------------------
$pnlBottom = New-Object System.Windows.Forms.Panel
$pnlBottom.Dock = [System.Windows.Forms.DockStyle]::Bottom
$pnlBottom.Height = 145
$pnlBottom.BackColor = $cHeaderBg
$form.Controls.Add($pnlBottom)

$pnlLogHeader = New-Object System.Windows.Forms.Panel
$pnlLogHeader.Dock = [System.Windows.Forms.DockStyle]::Top
$pnlLogHeader.Height = 26
$pnlLogHeader.BackColor = [System.Drawing.Color]::FromArgb(24, 24, 24)
$pnlBottom.Controls.Add($pnlLogHeader)

$lblLog = New-Object System.Windows.Forms.Label
$lblLog.Text = "Transfer Activity Log:"
$lblLog.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
$lblLog.ForeColor = $cTextWhite
$lblLog.Location = New-Object System.Drawing.Point(12, 5)
$lblLog.AutoSize = $true
$pnlLogHeader.Controls.Add($lblLog)

$btnClearLog = New-Object System.Windows.Forms.Button
$btnClearLog.Text = "Clear"
$btnClearLog.Location = New-Object System.Drawing.Point(950, 2)
$btnClearLog.Size = New-Object System.Drawing.Size(60, 22)
$btnClearLog.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnClearLog.FlatAppearance.BorderColor = $cCardBorder
$btnClearLog.BackColor = $cBtnSecondary
$btnClearLog.ForeColor = $cTextWhite
$btnClearLog.Font = New-Object System.Drawing.Font("Segoe UI", 7.5)
$btnClearLog.Cursor = [System.Windows.Forms.Cursors]::Hand
$pnlLogHeader.Controls.Add($btnClearLog)

$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Dock = [System.Windows.Forms.DockStyle]::Fill
$txtLog.Multiline = $true
$txtLog.ReadOnly = $true
$txtLog.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
$txtLog.BackColor = $cLogBg
$txtLog.ForeColor = $cTextLog
$txtLog.Font = New-Object System.Drawing.Font("Consolas", 8.5)
$txtLog.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$pnlBottom.Controls.Add($txtLog)

$btnClearLog.Add_Click({
    $txtLog.Clear()
})

$statusStrip = New-Object System.Windows.Forms.StatusStrip
$statusStrip.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
$statusStrip.ForeColor = $cTextMuted
$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = "Ready"
$statusStrip.Items.Add($statusLabel) | Out-Null
$pnlBottom.Controls.Add($statusStrip)

# -------------------------------------------------------------------------
# Center Panel: TabControl
# -------------------------------------------------------------------------
$tabs = New-Object System.Windows.Forms.TabControl
$tabs.Dock = [System.Windows.Forms.DockStyle]::Fill
$tabs.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($tabs)
$tabs.BringToFront()

$tabCharacter = New-Object System.Windows.Forms.TabPage
$tabCharacter.Text = "  Character Settings  "
$tabCharacter.BackColor = $cWindowBg

$tabAccount = New-Object System.Windows.Forms.TabPage
$tabAccount.Text = "  Account Settings  "
$tabAccount.BackColor = $cWindowBg

$tabOverview = New-Object System.Windows.Forms.TabPage
$tabOverview.Text = "  Explorer & Backups  "
$tabOverview.BackColor = $cWindowBg

$tabs.TabPages.AddRange(@($tabCharacter, $tabAccount, $tabOverview))

# =========================================================================
# TAB 1: Character Settings Transfer
# =========================================================================
$grpCharSrc = New-Object System.Windows.Forms.GroupBox
$grpCharSrc.Text = " Source Character "
$grpCharSrc.Location = New-Object System.Drawing.Point(16, 12)
$grpCharSrc.Size = New-Object System.Drawing.Size(315, 420)
$grpCharSrc.ForeColor = $cTextWhite
$grpCharSrc.BackColor = $cCardBg
$tabCharacter.Controls.Add($grpCharSrc)

$lblSrcAcc = New-Object System.Windows.Forms.Label
$lblSrcAcc.Text = "Account:"
$lblSrcAcc.Location = New-Object System.Drawing.Point(14, 25)
$lblSrcAcc.AutoSize = $true
$lblSrcAcc.ForeColor = $cTextWhite
$grpCharSrc.Controls.Add($lblSrcAcc)

$cmbSrcCharAcc = New-Object System.Windows.Forms.ComboBox
$cmbSrcCharAcc.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$cmbSrcCharAcc.Location = New-Object System.Drawing.Point(14, 45)
$cmbSrcCharAcc.Size = New-Object System.Drawing.Size(285, 23)
$cmbSrcCharAcc.BackColor = $cInputBg
$cmbSrcCharAcc.ForeColor = $cTextWhite
$grpCharSrc.Controls.Add($cmbSrcCharAcc)

$lblSrcRealm = New-Object System.Windows.Forms.Label
$lblSrcRealm.Text = "Server / Realm:"
$lblSrcRealm.Location = New-Object System.Drawing.Point(14, 75)
$lblSrcRealm.AutoSize = $true
$lblSrcRealm.ForeColor = $cTextWhite
$grpCharSrc.Controls.Add($lblSrcRealm)

$cmbSrcCharRealm = New-Object System.Windows.Forms.ComboBox
$cmbSrcCharRealm.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$cmbSrcCharRealm.Location = New-Object System.Drawing.Point(14, 95)
$cmbSrcCharRealm.Size = New-Object System.Drawing.Size(285, 23)
$cmbSrcCharRealm.BackColor = $cInputBg
$cmbSrcCharRealm.ForeColor = $cTextWhite
$grpCharSrc.Controls.Add($cmbSrcCharRealm)

$lblSrcName = New-Object System.Windows.Forms.Label
$lblSrcName.Text = "Character:"
$lblSrcName.Location = New-Object System.Drawing.Point(14, 125)
$lblSrcName.AutoSize = $true
$lblSrcName.ForeColor = $cTextWhite
$grpCharSrc.Controls.Add($lblSrcName)

$cmbSrcCharName = New-Object System.Windows.Forms.ComboBox
$cmbSrcCharName.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$cmbSrcCharName.Location = New-Object System.Drawing.Point(14, 145)
$cmbSrcCharName.Size = New-Object System.Drawing.Size(285, 23)
$cmbSrcCharName.BackColor = $cInputBg
$cmbSrcCharName.ForeColor = $cTextWhite
$grpCharSrc.Controls.Add($cmbSrcCharName)

$lblSrcDetailsTitle = New-Object System.Windows.Forms.Label
$lblSrcDetailsTitle.Text = "Available Settings in Source:"
$lblSrcDetailsTitle.Location = New-Object System.Drawing.Point(14, 180)
$lblSrcDetailsTitle.AutoSize = $true
$lblSrcDetailsTitle.ForeColor = $cTextMuted
$grpCharSrc.Controls.Add($lblSrcDetailsTitle)

$txtSrcCharDetails = New-Object System.Windows.Forms.TextBox
$txtSrcCharDetails.Location = New-Object System.Drawing.Point(14, 202)
$txtSrcCharDetails.Size = New-Object System.Drawing.Size(285, 205)
$txtSrcCharDetails.Multiline = $true
$txtSrcCharDetails.ReadOnly = $true
$txtSrcCharDetails.BackColor = $cInputBg
$txtSrcCharDetails.ForeColor = $cTextWhite
$txtSrcCharDetails.Font = New-Object System.Drawing.Font("Consolas", 8.5)
$txtSrcCharDetails.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$grpCharSrc.Controls.Add($txtSrcCharDetails)

# Transfer Options Box (Center)
$grpCharOpts = New-Object System.Windows.Forms.GroupBox
$grpCharOpts.Text = " Settings to Transfer "
$grpCharOpts.Location = New-Object System.Drawing.Point(341, 12)
$grpCharOpts.Size = New-Object System.Drawing.Size(345, 420)
$grpCharOpts.ForeColor = $cTextWhite
$grpCharOpts.BackColor = $cCardBg
$tabCharacter.Controls.Add($grpCharOpts)

$chkCharLayout = New-Object System.Windows.Forms.CheckBox
$chkCharLayout.Text = "UI Frame Positions (layout-local.txt)"
$chkCharLayout.Location = New-Object System.Drawing.Point(18, 25)
$chkCharLayout.Size = New-Object System.Drawing.Size(310, 22)
$chkCharLayout.ForeColor = $cTextWhite
$chkCharLayout.Checked = $true
$grpCharOpts.Controls.Add($chkCharLayout)

$chkCharEditMode = New-Object System.Windows.Forms.CheckBox
$chkCharEditMode.Text = "Modern Edit Mode HUD Layout"
$chkCharEditMode.Location = New-Object System.Drawing.Point(18, 50)
$chkCharEditMode.Size = New-Object System.Drawing.Size(310, 22)
$chkCharEditMode.ForeColor = $cTextWhite
$chkCharEditMode.Checked = $true
$grpCharOpts.Controls.Add($chkCharEditMode)

$chkCharConfig = New-Object System.Windows.Forms.CheckBox
$chkCharConfig.Text = "Character Config & CVars (config-cache.wtf)"
$chkCharConfig.Location = New-Object System.Drawing.Point(18, 75)
$chkCharConfig.Size = New-Object System.Drawing.Size(310, 22)
$chkCharConfig.ForeColor = $cTextWhite
$chkCharConfig.Checked = $true
$grpCharOpts.Controls.Add($chkCharConfig)

$chkCharChat = New-Object System.Windows.Forms.CheckBox
$chkCharChat.Text = "Chat Windows & Channels (chat-cache.txt)"
$chkCharChat.Location = New-Object System.Drawing.Point(18, 100)
$chkCharChat.Size = New-Object System.Drawing.Size(310, 22)
$chkCharChat.ForeColor = $cTextWhite
$chkCharChat.Checked = $true
$grpCharOpts.Controls.Add($chkCharChat)

$chkCharBindings = New-Object System.Windows.Forms.CheckBox
$chkCharBindings.Text = "Character Key Bindings (bindings-cache.wtf)"
$chkCharBindings.Location = New-Object System.Drawing.Point(18, 125)
$chkCharBindings.Size = New-Object System.Drawing.Size(310, 22)
$chkCharBindings.ForeColor = $cTextWhite
$chkCharBindings.Checked = $true
$grpCharOpts.Controls.Add($chkCharBindings)

$chkCharClickBindings = New-Object System.Windows.Forms.CheckBox
$chkCharClickBindings.Text = "Click-Cast Bindings (click-bindings-cache.txt)"
$chkCharClickBindings.Location = New-Object System.Drawing.Point(18, 150)
$chkCharClickBindings.Size = New-Object System.Drawing.Size(310, 22)
$chkCharClickBindings.ForeColor = $cTextWhite
$chkCharClickBindings.Checked = $true
$grpCharOpts.Controls.Add($chkCharClickBindings)

$chkCharMacros = New-Object System.Windows.Forms.CheckBox
$chkCharMacros.Text = "Character Macros (macros-cache.txt)"
$chkCharMacros.Location = New-Object System.Drawing.Point(18, 175)
$chkCharMacros.Size = New-Object System.Drawing.Size(310, 22)
$chkCharMacros.ForeColor = $cTextWhite
$chkCharMacros.Checked = $true
$grpCharOpts.Controls.Add($chkCharMacros)

$chkCharAddons = New-Object System.Windows.Forms.CheckBox
$chkCharAddons.Text = "Addon Enabled States (AddOns.txt)"
$chkCharAddons.Location = New-Object System.Drawing.Point(18, 200)
$chkCharAddons.Size = New-Object System.Drawing.Size(310, 22)
$chkCharAddons.ForeColor = $cTextWhite
$chkCharAddons.Checked = $true
$grpCharOpts.Controls.Add($chkCharAddons)

$chkCharSavedVars = New-Object System.Windows.Forms.CheckBox
$chkCharSavedVars.Text = "Character Addon Data (SavedVariables/*.lua)"
$chkCharSavedVars.Location = New-Object System.Drawing.Point(18, 225)
$chkCharSavedVars.Size = New-Object System.Drawing.Size(310, 22)
$chkCharSavedVars.ForeColor = $cTextWhite
$chkCharSavedVars.Checked = $true
$grpCharOpts.Controls.Add($chkCharSavedVars)

$chkCharResetMd5 = New-Object System.Windows.Forms.CheckBox
$chkCharResetMd5.Text = "Reset Target cache.md5 (Forces client reload)"
$chkCharResetMd5.Location = New-Object System.Drawing.Point(18, 255)
$chkCharResetMd5.Size = New-Object System.Drawing.Size(310, 22)
$chkCharResetMd5.ForeColor = $cTextWhite
$chkCharResetMd5.Checked = $true
$grpCharOpts.Controls.Add($chkCharResetMd5)

$chkCharBackup = New-Object System.Windows.Forms.CheckBox
$chkCharBackup.Text = "Create Automatic Target Backup before copy"
$chkCharBackup.Location = New-Object System.Drawing.Point(18, 280)
$chkCharBackup.Size = New-Object System.Drawing.Size(310, 22)
$chkCharBackup.ForeColor = $cTextWhite
$chkCharBackup.Checked = $true
$grpCharOpts.Controls.Add($chkCharBackup)

$btnCharSelectAll = New-Object System.Windows.Forms.Button
$btnCharSelectAll.Text = "Select All"
$btnCharSelectAll.Location = New-Object System.Drawing.Point(18, 315)
$btnCharSelectAll.Size = New-Object System.Drawing.Size(95, 26)
$btnCharSelectAll.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnCharSelectAll.FlatAppearance.BorderColor = $cCardBorder
$btnCharSelectAll.BackColor = $cBtnSecondary
$btnCharSelectAll.ForeColor = $cTextWhite
$btnCharSelectAll.Cursor = [System.Windows.Forms.Cursors]::Hand
$grpCharOpts.Controls.Add($btnCharSelectAll)

$btnCharClearAll = New-Object System.Windows.Forms.Button
$btnCharClearAll.Text = "Clear All"
$btnCharClearAll.Location = New-Object System.Drawing.Point(120, 315)
$btnCharClearAll.Size = New-Object System.Drawing.Size(95, 26)
$btnCharClearAll.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnCharClearAll.FlatAppearance.BorderColor = $cCardBorder
$btnCharClearAll.BackColor = $cBtnSecondary
$btnCharClearAll.ForeColor = $cTextWhite
$btnCharClearAll.Cursor = [System.Windows.Forms.Cursors]::Hand
$grpCharOpts.Controls.Add($btnCharClearAll)

$btnCharSelectAll.Add_Click({
    $chkCharLayout.Checked = $true
    $chkCharEditMode.Checked = $true
    $chkCharConfig.Checked = $true
    $chkCharChat.Checked = $true
    $chkCharBindings.Checked = $true
    $chkCharClickBindings.Checked = $true
    $chkCharMacros.Checked = $true
    $chkCharAddons.Checked = $true
    $chkCharSavedVars.Checked = $true
})

$btnCharClearAll.Add_Click({
    $chkCharLayout.Checked = $false
    $chkCharEditMode.Checked = $false
    $chkCharConfig.Checked = $false
    $chkCharChat.Checked = $false
    $chkCharBindings.Checked = $false
    $chkCharClickBindings.Checked = $false
    $chkCharMacros.Checked = $false
    $chkCharAddons.Checked = $false
    $chkCharSavedVars.Checked = $false
})

# Target Box (Right)
$grpCharDst = New-Object System.Windows.Forms.GroupBox
$grpCharDst.Text = " Target Character "
$grpCharDst.Location = New-Object System.Drawing.Point(696, 12)
$grpCharDst.Size = New-Object System.Drawing.Size(325, 420)
$grpCharDst.ForeColor = $cTextWhite
$grpCharDst.BackColor = $cCardBg
$tabCharacter.Controls.Add($grpCharDst)

$lblDstAcc = New-Object System.Windows.Forms.Label
$lblDstAcc.Text = "Account:"
$lblDstAcc.Location = New-Object System.Drawing.Point(14, 25)
$lblDstAcc.AutoSize = $true
$lblDstAcc.ForeColor = $cTextWhite
$grpCharDst.Controls.Add($lblDstAcc)

$cmbDstCharAcc = New-Object System.Windows.Forms.ComboBox
$cmbDstCharAcc.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$cmbDstCharAcc.Location = New-Object System.Drawing.Point(14, 45)
$cmbDstCharAcc.Size = New-Object System.Drawing.Size(295, 23)
$cmbDstCharAcc.BackColor = $cInputBg
$cmbDstCharAcc.ForeColor = $cTextWhite
$grpCharDst.Controls.Add($cmbDstCharAcc)

$lblDstRealm = New-Object System.Windows.Forms.Label
$lblDstRealm.Text = "Server / Realm:"
$lblDstRealm.Location = New-Object System.Drawing.Point(14, 75)
$lblDstRealm.AutoSize = $true
$lblDstRealm.ForeColor = $cTextWhite
$grpCharDst.Controls.Add($lblDstRealm)

$cmbDstCharRealm = New-Object System.Windows.Forms.ComboBox
$cmbDstCharRealm.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$cmbDstCharRealm.Location = New-Object System.Drawing.Point(14, 95)
$cmbDstCharRealm.Size = New-Object System.Drawing.Size(295, 23)
$cmbDstCharRealm.BackColor = $cInputBg
$cmbDstCharRealm.ForeColor = $cTextWhite
$grpCharDst.Controls.Add($cmbDstCharRealm)

$rbDstExistingChar = New-Object System.Windows.Forms.RadioButton
$rbDstExistingChar.Text = "Existing Character:"
$rbDstExistingChar.Location = New-Object System.Drawing.Point(14, 125)
$rbDstExistingChar.AutoSize = $true
$rbDstExistingChar.ForeColor = $cTextWhite
$rbDstExistingChar.Checked = $true
$grpCharDst.Controls.Add($rbDstExistingChar)

$cmbDstCharName = New-Object System.Windows.Forms.ComboBox
$cmbDstCharName.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$cmbDstCharName.Location = New-Object System.Drawing.Point(14, 145)
$cmbDstCharName.Size = New-Object System.Drawing.Size(295, 23)
$cmbDstCharName.BackColor = $cInputBg
$cmbDstCharName.ForeColor = $cTextWhite
$grpCharDst.Controls.Add($cmbDstCharName)

$rbDstNewChar = New-Object System.Windows.Forms.RadioButton
$rbDstNewChar.Text = "Or Create New Character Name:"
$rbDstNewChar.Location = New-Object System.Drawing.Point(14, 175)
$rbDstNewChar.AutoSize = $true
$rbDstNewChar.ForeColor = $cTextWhite
$grpCharDst.Controls.Add($rbDstNewChar)

$txtDstNewCharName = New-Object System.Windows.Forms.TextBox
$txtDstNewCharName.Location = New-Object System.Drawing.Point(14, 195)
$txtDstNewCharName.Size = New-Object System.Drawing.Size(295, 23)
$txtDstNewCharName.BackColor = $cInputBg
$txtDstNewCharName.ForeColor = $cTextWhite
$txtDstNewCharName.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$txtDstNewCharName.Enabled = $false
$grpCharDst.Controls.Add($txtDstNewCharName)

$rbDstExistingChar.Add_CheckedChanged({
    $cmbDstCharName.Enabled = $rbDstExistingChar.Checked
    $txtDstNewCharName.Enabled = $rbDstNewChar.Checked
    Update-TargetCharDetails
})

$rbDstNewChar.Add_CheckedChanged({
    $cmbDstCharName.Enabled = $rbDstExistingChar.Checked
    $txtDstNewCharName.Enabled = $rbDstNewChar.Checked
    Update-TargetCharDetails
})

$lblDstDetailsTitle = New-Object System.Windows.Forms.Label
$lblDstDetailsTitle.Text = "Target Character Status:"
$lblDstDetailsTitle.Location = New-Object System.Drawing.Point(14, 230)
$lblDstDetailsTitle.AutoSize = $true
$lblDstDetailsTitle.ForeColor = $cTextMuted
$grpCharDst.Controls.Add($lblDstDetailsTitle)

$txtDstCharDetails = New-Object System.Windows.Forms.TextBox
$txtDstCharDetails.Location = New-Object System.Drawing.Point(14, 252)
$txtDstCharDetails.Size = New-Object System.Drawing.Size(295, 155)
$txtDstCharDetails.Multiline = $true
$txtDstCharDetails.ReadOnly = $true
$txtDstCharDetails.BackColor = $cInputBg
$txtDstCharDetails.ForeColor = $cTextWhite
$txtDstCharDetails.Font = New-Object System.Drawing.Font("Consolas", 8.5)
$txtDstCharDetails.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$grpCharDst.Controls.Add($txtDstCharDetails)

# Character Transfer Actions
$btnTransferChar = New-Object System.Windows.Forms.Button
$btnTransferChar.Text = "Transfer Selected Settings to Target Character"
$btnTransferChar.Location = New-Object System.Drawing.Point(16, 442)
$btnTransferChar.Size = New-Object System.Drawing.Size(670, 36)
$btnTransferChar.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnTransferChar.FlatAppearance.BorderColor = $cBtnPrimary
$btnTransferChar.BackColor = $cBtnPrimary
$btnTransferChar.ForeColor = $cTextWhite
$btnTransferChar.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btnTransferChar.Cursor = [System.Windows.Forms.Cursors]::Hand
$tabCharacter.Controls.Add($btnTransferChar)

$btnBatchRealm = New-Object System.Windows.Forms.Button
$btnBatchRealm.Text = "Batch: Sync to ALL Characters on Realm..."
$btnBatchRealm.Location = New-Object System.Drawing.Point(696, 442)
$btnBatchRealm.Size = New-Object System.Drawing.Size(325, 36)
$btnBatchRealm.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnBatchRealm.FlatAppearance.BorderColor = $cCardBorder
$btnBatchRealm.BackColor = $cBtnBatch
$btnBatchRealm.ForeColor = $cTextWhite
$btnBatchRealm.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$btnBatchRealm.Cursor = [System.Windows.Forms.Cursors]::Hand
$tabCharacter.Controls.Add($btnBatchRealm)

# =========================================================================
# TAB 2: Account Settings Transfer
# =========================================================================
$grpAccSrc = New-Object System.Windows.Forms.GroupBox
$grpAccSrc.Text = " Source Account "
$grpAccSrc.Location = New-Object System.Drawing.Point(16, 12)
$grpAccSrc.Size = New-Object System.Drawing.Size(315, 420)
$grpAccSrc.ForeColor = $cTextWhite
$grpAccSrc.BackColor = $cCardBg
$tabAccount.Controls.Add($grpAccSrc)

$lblSrcAccountOnly = New-Object System.Windows.Forms.Label
$lblSrcAccountOnly.Text = "Select Account:"
$lblSrcAccountOnly.Location = New-Object System.Drawing.Point(14, 25)
$lblSrcAccountOnly.AutoSize = $true
$lblSrcAccountOnly.ForeColor = $cTextWhite
$grpAccSrc.Controls.Add($lblSrcAccountOnly)

$cmbSrcAccount = New-Object System.Windows.Forms.ComboBox
$cmbSrcAccount.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$cmbSrcAccount.Location = New-Object System.Drawing.Point(14, 48)
$cmbSrcAccount.Size = New-Object System.Drawing.Size(285, 23)
$cmbSrcAccount.BackColor = $cInputBg
$cmbSrcAccount.ForeColor = $cTextWhite
$grpAccSrc.Controls.Add($cmbSrcAccount)

$txtSrcAccountDetails = New-Object System.Windows.Forms.TextBox
$txtSrcAccountDetails.Location = New-Object System.Drawing.Point(14, 85)
$txtSrcAccountDetails.Size = New-Object System.Drawing.Size(285, 320)
$txtSrcAccountDetails.Multiline = $true
$txtSrcAccountDetails.ReadOnly = $true
$txtSrcAccountDetails.BackColor = $cInputBg
$txtSrcAccountDetails.ForeColor = $cTextWhite
$txtSrcAccountDetails.Font = New-Object System.Drawing.Font("Consolas", 8.5)
$txtSrcAccountDetails.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$grpAccSrc.Controls.Add($txtSrcAccountDetails)

# Account Options (Center)
$grpAccOpts = New-Object System.Windows.Forms.GroupBox
$grpAccOpts.Text = " Account Settings to Transfer "
$grpAccOpts.Location = New-Object System.Drawing.Point(341, 12)
$grpAccOpts.Size = New-Object System.Drawing.Size(345, 420)
$grpAccOpts.ForeColor = $cTextWhite
$grpAccOpts.BackColor = $cCardBg
$tabAccount.Controls.Add($grpAccOpts)

$chkAccBindings = New-Object System.Windows.Forms.CheckBox
$chkAccBindings.Text = "Account Key Bindings (bindings-cache.wtf)"
$chkAccBindings.Location = New-Object System.Drawing.Point(18, 30)
$chkAccBindings.Size = New-Object System.Drawing.Size(310, 24)
$chkAccBindings.ForeColor = $cTextWhite
$chkAccBindings.Checked = $true
$grpAccOpts.Controls.Add($chkAccBindings)

$chkAccConfig = New-Object System.Windows.Forms.CheckBox
$chkAccConfig.Text = "Account Config & CVars (config-cache.wtf)"
$chkAccConfig.Location = New-Object System.Drawing.Point(18, 60)
$chkAccConfig.Size = New-Object System.Drawing.Size(310, 24)
$chkAccConfig.ForeColor = $cTextWhite
$chkAccConfig.Checked = $true
$grpAccOpts.Controls.Add($chkAccConfig)

$chkAccMacros = New-Object System.Windows.Forms.CheckBox
$chkAccMacros.Text = "Account-Wide Macros (macros-cache.txt)"
$chkAccMacros.Location = New-Object System.Drawing.Point(18, 90)
$chkAccMacros.Size = New-Object System.Drawing.Size(310, 24)
$chkAccMacros.ForeColor = $cTextWhite
$chkAccMacros.Checked = $true
$grpAccOpts.Controls.Add($chkAccMacros)

$chkAccEditMode = New-Object System.Windows.Forms.CheckBox
$chkAccEditMode.Text = "Account Edit Mode Layout (edit-mode-cache-account.txt)"
$chkAccEditMode.Location = New-Object System.Drawing.Point(18, 120)
$chkAccEditMode.Size = New-Object System.Drawing.Size(310, 24)
$chkAccEditMode.ForeColor = $cTextWhite
$chkAccEditMode.Checked = $true
$grpAccOpts.Controls.Add($chkAccEditMode)

$chkAccChat = New-Object System.Windows.Forms.CheckBox
$chkAccChat.Text = "Account Chat Cache (chat-cache.txt)"
$chkAccChat.Location = New-Object System.Drawing.Point(18, 150)
$chkAccChat.Size = New-Object System.Drawing.Size(310, 24)
$chkAccChat.ForeColor = $cTextWhite
$chkAccChat.Checked = $true
$grpAccOpts.Controls.Add($chkAccChat)

$chkAccTTS = New-Object System.Windows.Forms.CheckBox
$chkAccTTS.Text = "Account TTS & Flags (tts/flagged-cache)"
$chkAccTTS.Location = New-Object System.Drawing.Point(18, 180)
$chkAccTTS.Size = New-Object System.Drawing.Size(310, 24)
$chkAccTTS.ForeColor = $cTextWhite
$chkAccTTS.Checked = $true
$grpAccOpts.Controls.Add($chkAccTTS)

$chkAccSavedVars = New-Object System.Windows.Forms.CheckBox
$chkAccSavedVars.Text = "Account Addon Databases (SavedVariables/*.lua)"
$chkAccSavedVars.Location = New-Object System.Drawing.Point(18, 210)
$chkAccSavedVars.Size = New-Object System.Drawing.Size(310, 24)
$chkAccSavedVars.ForeColor = $cTextWhite
$chkAccSavedVars.Checked = $true
$grpAccOpts.Controls.Add($chkAccSavedVars)

$chkAccResetMd5 = New-Object System.Windows.Forms.CheckBox
$chkAccResetMd5.Text = "Reset Target cache.md5"
$chkAccResetMd5.Location = New-Object System.Drawing.Point(18, 245)
$chkAccResetMd5.Size = New-Object System.Drawing.Size(310, 24)
$chkAccResetMd5.ForeColor = $cTextWhite
$chkAccResetMd5.Checked = $true
$grpAccOpts.Controls.Add($chkAccResetMd5)

$chkAccBackup = New-Object System.Windows.Forms.CheckBox
$chkAccBackup.Text = "Create Automatic Target Backup before overwrite"
$chkAccBackup.Location = New-Object System.Drawing.Point(18, 275)
$chkAccBackup.Size = New-Object System.Drawing.Size(310, 24)
$chkAccBackup.ForeColor = $cTextWhite
$chkAccBackup.Checked = $true
$grpAccOpts.Controls.Add($chkAccBackup)

$btnAccSelectAll = New-Object System.Windows.Forms.Button
$btnAccSelectAll.Text = "Select All"
$btnAccSelectAll.Location = New-Object System.Drawing.Point(18, 315)
$btnAccSelectAll.Size = New-Object System.Drawing.Size(95, 26)
$btnAccSelectAll.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnAccSelectAll.FlatAppearance.BorderColor = $cCardBorder
$btnAccSelectAll.BackColor = $cBtnSecondary
$btnAccSelectAll.ForeColor = $cTextWhite
$btnAccSelectAll.Cursor = [System.Windows.Forms.Cursors]::Hand
$grpAccOpts.Controls.Add($btnAccSelectAll)

$btnAccClearAll = New-Object System.Windows.Forms.Button
$btnAccClearAll.Text = "Clear All"
$btnAccClearAll.Location = New-Object System.Drawing.Point(120, 315)
$btnAccClearAll.Size = New-Object System.Drawing.Size(95, 26)
$btnAccClearAll.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnAccClearAll.FlatAppearance.BorderColor = $cCardBorder
$btnAccClearAll.BackColor = $cBtnSecondary
$btnAccClearAll.ForeColor = $cTextWhite
$btnAccClearAll.Cursor = [System.Windows.Forms.Cursors]::Hand
$grpAccOpts.Controls.Add($btnAccClearAll)

$btnAccSelectAll.Add_Click({
    $chkAccBindings.Checked = $true
    $chkAccConfig.Checked = $true
    $chkAccMacros.Checked = $true
    $chkAccEditMode.Checked = $true
    $chkAccChat.Checked = $true
    $chkAccTTS.Checked = $true
    $chkAccSavedVars.Checked = $true
})

$btnAccClearAll.Add_Click({
    $chkAccBindings.Checked = $false
    $chkAccConfig.Checked = $false
    $chkAccMacros.Checked = $false
    $chkAccEditMode.Checked = $false
    $chkAccChat.Checked = $false
    $chkAccTTS.Checked = $false
    $chkAccSavedVars.Checked = $false
})

# Target Account Box (Right)
$grpAccDst = New-Object System.Windows.Forms.GroupBox
$grpAccDst.Text = " Target Account "
$grpAccDst.Location = New-Object System.Drawing.Point(696, 12)
$grpAccDst.Size = New-Object System.Drawing.Size(325, 420)
$grpAccDst.ForeColor = $cTextWhite
$grpAccDst.BackColor = $cCardBg
$tabAccount.Controls.Add($grpAccDst)

$lblDstAccountOnly = New-Object System.Windows.Forms.Label
$lblDstAccountOnly.Text = "Select Target Account:"
$lblDstAccountOnly.Location = New-Object System.Drawing.Point(14, 25)
$lblDstAccountOnly.AutoSize = $true
$lblDstAccountOnly.ForeColor = $cTextWhite
$grpAccDst.Controls.Add($lblDstAccountOnly)

$cmbDstAccount = New-Object System.Windows.Forms.ComboBox
$cmbDstAccount.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$cmbDstAccount.Location = New-Object System.Drawing.Point(14, 48)
$cmbDstAccount.Size = New-Object System.Drawing.Size(295, 23)
$cmbDstAccount.BackColor = $cInputBg
$cmbDstAccount.ForeColor = $cTextWhite
$grpAccDst.Controls.Add($cmbDstAccount)

$txtDstAccountDetails = New-Object System.Windows.Forms.TextBox
$txtDstAccountDetails.Location = New-Object System.Drawing.Point(14, 85)
$txtDstAccountDetails.Size = New-Object System.Drawing.Size(295, 320)
$txtDstAccountDetails.Multiline = $true
$txtDstAccountDetails.ReadOnly = $true
$txtDstAccountDetails.BackColor = $cInputBg
$txtDstAccountDetails.ForeColor = $cTextWhite
$txtDstAccountDetails.Font = New-Object System.Drawing.Font("Consolas", 8.5)
$txtDstAccountDetails.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$grpAccDst.Controls.Add($txtDstAccountDetails)

# Account Transfer Actions
$btnTransferAccount = New-Object System.Windows.Forms.Button
$btnTransferAccount.Text = "Transfer Selected Account Settings"
$btnTransferAccount.Location = New-Object System.Drawing.Point(16, 442)
$btnTransferAccount.Size = New-Object System.Drawing.Size(670, 36)
$btnTransferAccount.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnTransferAccount.FlatAppearance.BorderColor = $cBtnPrimary
$btnTransferAccount.BackColor = $cBtnPrimary
$btnTransferAccount.ForeColor = $cTextWhite
$btnTransferAccount.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btnTransferAccount.Cursor = [System.Windows.Forms.Cursors]::Hand
$tabAccount.Controls.Add($btnTransferAccount)

$btnBatchAllAccounts = New-Object System.Windows.Forms.Button
$btnBatchAllAccounts.Text = "Batch: Sync to ALL Other Accounts..."
$btnBatchAllAccounts.Location = New-Object System.Drawing.Point(696, 442)
$btnBatchAllAccounts.Size = New-Object System.Drawing.Size(325, 36)
$btnBatchAllAccounts.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnBatchAllAccounts.FlatAppearance.BorderColor = $cCardBorder
$btnBatchAllAccounts.BackColor = $cBtnBatch
$btnBatchAllAccounts.ForeColor = $cTextWhite
$btnBatchAllAccounts.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$btnBatchAllAccounts.Cursor = [System.Windows.Forms.Cursors]::Hand
$tabAccount.Controls.Add($btnBatchAllAccounts)

# =========================================================================
# TAB 3: Explorer Tree & Backup Manager
# =========================================================================
$grpTree = New-Object System.Windows.Forms.GroupBox
$grpTree.Text = " WTF Accounts & Characters Hierarchy "
$grpTree.Location = New-Object System.Drawing.Point(16, 12)
$grpTree.Size = New-Object System.Drawing.Size(480, 465)
$grpTree.ForeColor = $cTextWhite
$grpTree.BackColor = $cCardBg
$tabOverview.Controls.Add($grpTree)

$treeWtf = New-Object System.Windows.Forms.TreeView
$treeWtf.Dock = [System.Windows.Forms.DockStyle]::Fill
$treeWtf.BackColor = $cInputBg
$treeWtf.ForeColor = $cTextWhite
$treeWtf.LineColor = $cTextMuted
$treeWtf.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$treeWtf.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$grpTree.Controls.Add($treeWtf)

$grpBackups = New-Object System.Windows.Forms.GroupBox
$grpBackups.Text = " Saved Backups & Restore "
$grpBackups.Location = New-Object System.Drawing.Point(510, 12)
$grpBackups.Size = New-Object System.Drawing.Size(510, 465)
$grpBackups.ForeColor = $cTextWhite
$grpBackups.BackColor = $cCardBg
$tabOverview.Controls.Add($grpBackups)

$lblBackupsIntro = New-Object System.Windows.Forms.Label
$lblBackupsIntro.Text = "Previous backups created before transfers (stored in _TransferBackups):"
$lblBackupsIntro.Location = New-Object System.Drawing.Point(14, 22)
$lblBackupsIntro.Size = New-Object System.Drawing.Size(480, 20)
$lblBackupsIntro.ForeColor = $cTextMuted
$grpBackups.Controls.Add($lblBackupsIntro)

$lstBackups = New-Object System.Windows.Forms.ListBox
$lstBackups.Location = New-Object System.Drawing.Point(14, 45)
$lstBackups.Size = New-Object System.Drawing.Size(480, 270)
$lstBackups.BackColor = $cInputBg
$lstBackups.ForeColor = $cTextWhite
$lstBackups.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$lstBackups.Font = New-Object System.Drawing.Font("Consolas", 8.5)
$grpBackups.Controls.Add($lstBackups)

$txtBackupInfo = New-Object System.Windows.Forms.TextBox
$txtBackupInfo.Location = New-Object System.Drawing.Point(14, 322)
$txtBackupInfo.Size = New-Object System.Drawing.Size(480, 95)
$txtBackupInfo.Multiline = $true
$txtBackupInfo.ReadOnly = $true
$txtBackupInfo.BackColor = $cInputBg
$txtBackupInfo.ForeColor = $cTextWhite
$txtBackupInfo.Font = New-Object System.Drawing.Font("Consolas", 8)
$txtBackupInfo.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$grpBackups.Controls.Add($txtBackupInfo)

$btnRestoreBackup = New-Object System.Windows.Forms.Button
$btnRestoreBackup.Text = "Restore Selected Backup"
$btnRestoreBackup.Location = New-Object System.Drawing.Point(14, 424)
$btnRestoreBackup.Size = New-Object System.Drawing.Size(180, 30)
$btnRestoreBackup.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRestoreBackup.FlatAppearance.BorderColor = $cCardBorder
$btnRestoreBackup.BackColor = $cBtnSecondary
$btnRestoreBackup.ForeColor = $cTextWhite
$btnRestoreBackup.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
$btnRestoreBackup.Cursor = [System.Windows.Forms.Cursors]::Hand
$grpBackups.Controls.Add($btnRestoreBackup)

$btnOpenBackupsDir = New-Object System.Windows.Forms.Button
$btnOpenBackupsDir.Text = "Open Backups Folder"
$btnOpenBackupsDir.Location = New-Object System.Drawing.Point(202, 424)
$btnOpenBackupsDir.Size = New-Object System.Drawing.Size(155, 30)
$btnOpenBackupsDir.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnOpenBackupsDir.FlatAppearance.BorderColor = $cCardBorder
$btnOpenBackupsDir.BackColor = $cBtnSecondary
$btnOpenBackupsDir.ForeColor = $cTextWhite
$btnOpenBackupsDir.Cursor = [System.Windows.Forms.Cursors]::Hand
$grpBackups.Controls.Add($btnOpenBackupsDir)

$btnRefreshBackups = New-Object System.Windows.Forms.Button
$btnRefreshBackups.Text = "Refresh"
$btnRefreshBackups.Location = New-Object System.Drawing.Point(365, 424)
$btnRefreshBackups.Size = New-Object System.Drawing.Size(80, 30)
$btnRefreshBackups.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRefreshBackups.FlatAppearance.BorderColor = $cCardBorder
$btnRefreshBackups.BackColor = $cBtnSecondary
$btnRefreshBackups.ForeColor = $cTextWhite
$btnRefreshBackups.Cursor = [System.Windows.Forms.Cursors]::Hand
$grpBackups.Controls.Add($btnRefreshBackups)

# =========================================================================
# Step 6: Data Binding and Event Wiring
# =========================================================================
function Populate-AllData {
    param([PSCustomObject]$Data)

    $cmbSrcCharAcc.BeginUpdate()
    $cmbDstCharAcc.BeginUpdate()
    $cmbSrcAccount.BeginUpdate()
    $cmbDstAccount.BeginUpdate()
    $treeWtf.BeginUpdate()

    $cmbSrcCharAcc.Items.Clear()
    $cmbDstCharAcc.Items.Clear()
    $cmbSrcAccount.Items.Clear()
    $cmbDstAccount.Items.Clear()
    $treeWtf.Nodes.Clear()

    if ($Data.Accounts.Count -eq 0) {
        $cmbSrcCharAcc.EndUpdate()
        $cmbDstCharAcc.EndUpdate()
        $cmbSrcAccount.EndUpdate()
        $cmbDstAccount.EndUpdate()
        $treeWtf.EndUpdate()
        $statusLabel.Text = "No accounts found in $($Data.WtfPath)"
        Log-Msg "No account directories detected in $($Data.AccountFolder)" "WARN"
        return
    }

    $rootNode = New-Object System.Windows.Forms.TreeNode("WTF Root ($($Data.WtfPath))")

    foreach ($acc in $Data.Accounts) {
        $cmbSrcCharAcc.Items.Add($acc.Name) | Out-Null
        $cmbDstCharAcc.Items.Add($acc.Name) | Out-Null
        $cmbSrcAccount.Items.Add($acc.Name) | Out-Null
        $cmbDstAccount.Items.Add($acc.Name) | Out-Null

        $accNode = New-Object System.Windows.Forms.TreeNode("Account: $($acc.Name) [Addon SV: $($acc.SavedVariablesCount)]")
        
        $accSetNode = New-Object System.Windows.Forms.TreeNode("Account Settings (Bindings: $($acc.Files.Bindings), Config: $($acc.Files.Config), Macros: $($acc.Files.Macros))")
        $accNode.Nodes.Add($accSetNode) | Out-Null

        foreach ($r in $acc.Realms) {
            $realmNode = New-Object System.Windows.Forms.TreeNode("Realm: $($r.Name) ($($r.Characters.Count) Characters)")
            foreach ($c in $r.Characters) {
                $charText = "$($c.Name) (Layout: $($c.Files.Layout), EditMode: $($c.Files.EditMode), SV: $($c.SavedVariablesCount))"
                $charNode = New-Object System.Windows.Forms.TreeNode($charText)
                $charNode.Tag = $c
                $realmNode.Nodes.Add($charNode) | Out-Null
            }
            $accNode.Nodes.Add($realmNode) | Out-Null
        }
        $rootNode.Nodes.Add($accNode) | Out-Null
    }

    $treeWtf.Nodes.Add($rootNode) | Out-Null
    $rootNode.Expand()
    foreach ($n in $rootNode.Nodes) { $n.Expand() }

    $cmbSrcCharAcc.EndUpdate()
    $cmbDstCharAcc.EndUpdate()
    $cmbSrcAccount.EndUpdate()
    $cmbDstAccount.EndUpdate()
    $treeWtf.EndUpdate()

    if ($cmbSrcCharAcc.Items.Count -gt 0) { $cmbSrcCharAcc.SelectedIndex = 0 }
    if ($cmbDstCharAcc.Items.Count -gt 1) { $cmbDstCharAcc.SelectedIndex = 1 } elseif ($cmbDstCharAcc.Items.Count -gt 0) { $cmbDstCharAcc.SelectedIndex = 0 }
    if ($cmbSrcAccount.Items.Count -gt 0) { $cmbSrcAccount.SelectedIndex = 0 }
    if ($cmbDstAccount.Items.Count -gt 1) { $cmbDstAccount.SelectedIndex = 1 } elseif ($cmbDstAccount.Items.Count -gt 0) { $cmbDstAccount.SelectedIndex = 0 }

    $statusLabel.Text = "Accounts: $($Data.TotalAccounts) | Realms: $($Data.TotalRealms) | Characters: $($Data.TotalCharacters)"
    Log-Msg "Loaded WTF data: $($Data.TotalAccounts) accounts, $($Data.TotalRealms) realms, $($Data.TotalCharacters) characters." "INFO"
    
    Populate-BackupsList
}

function Populate-BackupsList {
    $lstBackups.Items.Clear()
    $backupRoot = Join-Path $txtWtfPath.Text "_TransferBackups"
    if (Test-Path -LiteralPath $backupRoot) {
        $dirs = Get-ChildItem -LiteralPath $backupRoot -Directory -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending
        foreach ($d in $dirs) {
            $lstBackups.Items.Add($d.Name) | Out-Null
        }
    }
}

$lstBackups.Add_SelectedIndexChanged({
    if ($lstBackups.SelectedItem) {
        $backupRoot = Join-Path $txtWtfPath.Text "_TransferBackups"
        $selectedDir = Join-Path $backupRoot $lstBackups.SelectedItem
        $manifestPath = Join-Path $selectedDir "manifest.json"
        if (Test-Path -LiteralPath $manifestPath) {
            $txtBackupInfo.Text = (Get-Content -LiteralPath $manifestPath -Raw)
        } else {
            $fileCount = (Get-ChildItem -LiteralPath $selectedDir -Recurse -File -ErrorAction SilentlyContinue).Count
            $txtBackupInfo.Text = "Path: $selectedDir`r`nFiles: $fileCount`r`n(No manifest.json)"
        }
    } else {
        $txtBackupInfo.Clear()
    }
})

$btnRefreshBackups.Add_Click({
    Populate-BackupsList
    Log-Msg "Backups list refreshed." "INFO"
})

$btnOpenBackupsDir.Add_Click({
    $backupRoot = Join-Path $txtWtfPath.Text "_TransferBackups"
    Ensure-Directory $backupRoot
    [System.Diagnostics.Process]::Start("explorer.exe", "`"$backupRoot`"") | Out-Null
})

$btnRestoreBackup.Add_Click({
    if (-not $lstBackups.SelectedItem) {
        [System.Windows.Forms.MessageBox]::Show("Please select a backup to restore from the list.", "Select Backup", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        return
    }

    $backupRoot = Join-Path $txtWtfPath.Text "_TransferBackups"
    $selectedDir = Join-Path $backupRoot $lstBackups.SelectedItem
    $manifestPath = Join-Path $selectedDir "manifest.json"

    if (-not (Test-Path -LiteralPath $manifestPath)) {
        [System.Windows.Forms.MessageBox]::Show("Manifest file missing for this backup. Cannot determine target folder.", "Restore Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    $target = $manifest.TargetFolder

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Are you sure you want to restore backup '$($lstBackups.SelectedItem)' to:`n`n$target`n`nExisting files in the target folder will be overwritten by this backup.",
        "Confirm Restore Backup",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    if ($confirm -eq [System.Windows.Forms.DialogResult]::Yes) {
        try {
            $restoredCount = 0
            Get-ChildItem -LiteralPath $selectedDir -Recurse -File | Where-Object { $_.Name -ne "manifest.json" } | ForEach-Object {
                $rel = $_.FullName.Substring($selectedDir.Length).TrimStart('\', '/')
                $dest = Join-Path $target $rel
                Ensure-Directory ([System.IO.Path]::GetDirectoryName($dest))
                Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
                $restoredCount++
            }
            Remove-CacheHash $target
            Log-Msg "Successfully restored backup to $target ($restoredCount files restored)." "SUCCESS"
            [System.Windows.Forms.MessageBox]::Show("Backup successfully restored! ($restoredCount files)", "Restore Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            Rescan-All
        } catch {
            Log-Msg "Restore failed: $($_.Exception.Message)" "ERROR"
            [System.Windows.Forms.MessageBox]::Show("Restore failed: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }
})

# -------------------------------------------------------------------------
# Dynamic Dropdown Event Handlers (Character Tab)
# -------------------------------------------------------------------------
function Update-SourceCharRealms {
    $cmbSrcCharRealm.Items.Clear()
    $cmbSrcCharName.Items.Clear()
    $txtSrcCharDetails.Clear()

    $accName = $cmbSrcCharAcc.SelectedItem
    $accObj = $global:WtfHierarchy.Accounts | Where-Object { $_.Name -eq $accName }
    if ($accObj) {
        foreach ($r in $accObj.Realms) {
            $cmbSrcCharRealm.Items.Add($r.Name) | Out-Null
        }
        if ($cmbSrcCharRealm.Items.Count -gt 0) {
            $cmbSrcCharRealm.SelectedIndex = 0
        }
    }
}

function Update-SourceCharNames {
    $cmbSrcCharName.Items.Clear()
    $txtSrcCharDetails.Clear()

    $accName = $cmbSrcCharAcc.SelectedItem
    $realmName = $cmbSrcCharRealm.SelectedItem
    $accObj = $global:WtfHierarchy.Accounts | Where-Object { $_.Name -eq $accName }
    if ($accObj) {
        $realmObj = $accObj.Realms | Where-Object { $_.Name -eq $realmName }
        if ($realmObj) {
            foreach ($c in $realmObj.Characters) {
                $cmbSrcCharName.Items.Add($c.Name) | Out-Null
            }
            if ($cmbSrcCharName.Items.Count -gt 0) {
                $cmbSrcCharName.SelectedIndex = 0
            }
        }
    }
}

function Update-SourceCharDetails {
    $accName = $cmbSrcCharAcc.SelectedItem
    $realmName = $cmbSrcCharRealm.SelectedItem
    $charName = $cmbSrcCharName.SelectedItem
    
    $accObj = $global:WtfHierarchy.Accounts | Where-Object { $_.Name -eq $accName }
    if ($accObj) {
        $realmObj = $accObj.Realms | Where-Object { $_.Name -eq $realmName }
        if ($realmObj) {
            $charObj = $realmObj.Characters | Where-Object { $_.Name -eq $charName }
            if ($charObj) {
                $sb = New-Object System.Text.StringBuilder
                [void]$sb.AppendLine("Character: $($charObj.Name)")
                [void]$sb.AppendLine("Account:   $($charObj.Account)")
                [void]$sb.AppendLine("Realm:     $($charObj.Realm)")
                [void]$sb.AppendLine("Updated:   $($charObj.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))")
                [void]$sb.AppendLine("-----------------------------")
                [void]$sb.AppendLine("UI Layout:       $($charObj.Files.Layout)")
                [void]$sb.AppendLine("Edit Mode HUD:   $($charObj.Files.EditMode)")
                [void]$sb.AppendLine("Config / CVars:  $($charObj.Files.Config)")
                [void]$sb.AppendLine("Chat Cache:      $($charObj.Files.Chat)")
                [void]$sb.AppendLine("Key Bindings:    $($charObj.Files.Bindings)")
                [void]$sb.AppendLine("Click Cast:      $($charObj.Files.ClickBindings)")
                [void]$sb.AppendLine("Char Macros:     $($charObj.Files.Macros)")
                [void]$sb.AppendLine("Addons List:     $($charObj.Files.AddOns)")
                [void]$sb.AppendLine("Addon Data:      $($charObj.SavedVariablesCount) files")
                $txtSrcCharDetails.Text = $sb.ToString()
                return
            }
        }
    }
    $txtSrcCharDetails.Text = "(No character selected)"
}

$cmbSrcCharAcc.Add_SelectedIndexChanged({ Update-SourceCharRealms })
$cmbSrcCharRealm.Add_SelectedIndexChanged({ Update-SourceCharNames })
$cmbSrcCharName.Add_SelectedIndexChanged({ Update-SourceCharDetails })

function Update-TargetCharRealms {
    $cmbDstCharRealm.Items.Clear()
    $cmbDstCharName.Items.Clear()
    $txtDstCharDetails.Clear()

    $accName = $cmbDstCharAcc.SelectedItem
    $accObj = $global:WtfHierarchy.Accounts | Where-Object { $_.Name -eq $accName }
    if ($accObj) {
        foreach ($r in $accObj.Realms) {
            $cmbDstCharRealm.Items.Add($r.Name) | Out-Null
        }
        if ($cmbDstCharRealm.Items.Count -gt 0) {
            $cmbDstCharRealm.SelectedIndex = 0
        }
    }
}

function Update-TargetCharNames {
    $cmbDstCharName.Items.Clear()
    $txtDstCharDetails.Clear()

    $accName = $cmbDstCharAcc.SelectedItem
    $realmName = $cmbDstCharRealm.SelectedItem
    $accObj = $global:WtfHierarchy.Accounts | Where-Object { $_.Name -eq $accName }
    if ($accObj) {
        $realmObj = $accObj.Realms | Where-Object { $_.Name -eq $realmName }
        if ($realmObj) {
            foreach ($c in $realmObj.Characters) {
                $cmbDstCharName.Items.Add($c.Name) | Out-Null
            }
            if ($cmbDstCharName.Items.Count -gt 0) {
                $cmbDstCharName.SelectedIndex = 0
            }
        }
    }
    Update-TargetCharDetails
}

function Update-TargetCharDetails {
    $accName = $cmbDstCharAcc.SelectedItem
    $realmName = $cmbDstCharRealm.SelectedItem
    
    if ($rbDstNewChar.Checked) {
        $newName = $txtDstNewCharName.Text.Trim()
        if ([string]::IsNullOrWhiteSpace($newName)) {
            $txtDstCharDetails.Text = "[NEW CHARACTER]`r`nPlease enter a name above.`r`nA new folder will be created under:`r`nWTF\Account\$accName\$realmName\<NewName>"
        } else {
            $destPath = Join-Path $txtWtfPath.Text "Account\$accName\$realmName\$newName"
            $exists = Test-Path -LiteralPath $destPath
            $txtDstCharDetails.Text = "[NEW CHARACTER]`r`nName:   $newName`r`nPath:   $destPath`r`nExists: $exists`r`n(Settings will be ready when you log in!)"
        }
        return
    }

    $charName = $cmbDstCharName.SelectedItem
    $accObj = $global:WtfHierarchy.Accounts | Where-Object { $_.Name -eq $accName }
    if ($accObj) {
        $realmObj = $accObj.Realms | Where-Object { $_.Name -eq $realmName }
        if ($realmObj) {
            $charObj = $realmObj.Characters | Where-Object { $_.Name -eq $charName }
            if ($charObj) {
                $sb = New-Object System.Text.StringBuilder
                [void]$sb.AppendLine("[EXISTING CHARACTER]")
                [void]$sb.AppendLine("Name:     $($charObj.Name)")
                [void]$sb.AppendLine("Account:  $($charObj.Account)")
                [void]$sb.AppendLine("Realm:    $($charObj.Realm)")
                [void]$sb.AppendLine("Updated:  $($charObj.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))")
                [void]$sb.AppendLine("-----------------------------")
                [void]$sb.AppendLine("Files Present:")
                [void]$sb.AppendLine("Layout:      $($charObj.Files.Layout)")
                [void]$sb.AppendLine("Edit Mode:   $($charObj.Files.EditMode)")
                [void]$sb.AppendLine("Config:      $($charObj.Files.Config)")
                [void]$sb.AppendLine("Addon Data:  $($charObj.SavedVariablesCount) files")
                $txtDstCharDetails.Text = $sb.ToString()
                return
            }
        }
    }
    $txtDstCharDetails.Text = "(No target character selected)"
}

$cmbDstCharAcc.Add_SelectedIndexChanged({ Update-TargetCharRealms })
$cmbDstCharRealm.Add_SelectedIndexChanged({ Update-TargetCharNames })
$cmbDstCharName.Add_SelectedIndexChanged({ Update-TargetCharDetails })
$txtDstNewCharName.Add_TextChanged({ Update-TargetCharDetails })

# -------------------------------------------------------------------------
# Dynamic Dropdown Event Handlers (Account Tab)
# -------------------------------------------------------------------------
function Update-SourceAccountDetails {
    $accName = $cmbSrcAccount.SelectedItem
    $accObj = $global:WtfHierarchy.Accounts | Where-Object { $_.Name -eq $accName }
    if ($accObj) {
        $sb = New-Object System.Text.StringBuilder
        [void]$sb.AppendLine("Account:        $($accObj.Name)")
        [void]$sb.AppendLine("Path:           $($accObj.Path)")
        [void]$sb.AppendLine("Last Modified:  $($accObj.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))")
        [void]$sb.AppendLine("Realms Found:   $($accObj.Realms.Count)")
        $totalChars = ($accObj.Realms | ForEach-Object { $_.Characters.Count } | Measure-Object -Sum).Sum
        [void]$sb.AppendLine("Total Characters: $totalChars")
        [void]$sb.AppendLine("=============================")
        [void]$sb.AppendLine("Account-Wide Settings:")
        [void]$sb.AppendLine("Key Bindings:    $($accObj.Files.Bindings)")
        [void]$sb.AppendLine("Config / CVars:  $($accObj.Files.Config)")
        [void]$sb.AppendLine("Account Macros:  $($accObj.Files.Macros)")
        [void]$sb.AppendLine("Edit Mode Layout: $($accObj.Files.EditMode)")
        [void]$sb.AppendLine("Chat Cache:      $($accObj.Files.Chat)")
        [void]$sb.AppendLine("TTS / Flags:     $($accObj.Files.TTS)")
        [void]$sb.AppendLine("SavedVariables:  $($accObj.SavedVariablesCount) addon databases")
        $txtSrcAccountDetails.Text = $sb.ToString()
    } else {
        $txtSrcAccountDetails.Clear()
    }
}

function Update-TargetAccountDetails {
    $accName = $cmbDstAccount.SelectedItem
    $accObj = $global:WtfHierarchy.Accounts | Where-Object { $_.Name -eq $accName }
    if ($accObj) {
        $sb = New-Object System.Text.StringBuilder
        [void]$sb.AppendLine("Target Account: $($accObj.Name)")
        [void]$sb.AppendLine("Path:           $($accObj.Path)")
        [void]$sb.AppendLine("Last Modified:  $($accObj.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))")
        [void]$sb.AppendLine("Realms Found:   $($accObj.Realms.Count)")
        $totalChars = ($accObj.Realms | ForEach-Object { $_.Characters.Count } | Measure-Object -Sum).Sum
        [void]$sb.AppendLine("Total Characters: $totalChars")
        [void]$sb.AppendLine("=============================")
        [void]$sb.AppendLine("Existing Settings:")
        [void]$sb.AppendLine("Key Bindings:    $($accObj.Files.Bindings)")
        [void]$sb.AppendLine("Config / CVars:  $($accObj.Files.Config)")
        [void]$sb.AppendLine("Account Macros:  $($accObj.Files.Macros)")
        [void]$sb.AppendLine("Edit Mode Layout: $($accObj.Files.EditMode)")
        [void]$sb.AppendLine("Chat Cache:      $($accObj.Files.Chat)")
        [void]$sb.AppendLine("SavedVariables:  $($accObj.SavedVariablesCount) addon databases")
        $txtDstAccountDetails.Text = $sb.ToString()
    } else {
        $txtDstAccountDetails.Clear()
    }
}

$cmbSrcAccount.Add_SelectedIndexChanged({ Update-SourceAccountDetails })
$cmbDstAccount.Add_SelectedIndexChanged({ Update-TargetAccountDetails })

# Rescan & Path Browse buttons
function Rescan-All {
    $p = $txtWtfPath.Text.Trim()
    if (-not (Test-Path -LiteralPath $p)) {
        Log-Msg "Folder does not exist: $p" "ERROR"
        [System.Windows.Forms.MessageBox]::Show("The specified WTF path does not exist:`n$p", "Path Not Found", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }
    $global:WtfHierarchy = Scan-WtfHierarchy $p
    Populate-AllData $global:WtfHierarchy
    Update-WowStatus
}

$btnBrowse.Add_Click({
    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
    $fbd.Description = "Select World of Warcraft _forever_\WTF folder"
    $fbd.SelectedPath = $txtWtfPath.Text
    if ($fbd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtWtfPath.Text = $fbd.SelectedPath
        Rescan-All
    }
})

$btnRescan.Add_Click({
    Rescan-All
})

$btnOpenFolder.Add_Click({
    $p = $txtWtfPath.Text.Trim()
    if (Test-Path -LiteralPath $p) {
        [System.Diagnostics.Process]::Start("explorer.exe", "`"$p`"") | Out-Null
    }
})

# =========================================================================
# Step 7: Character Transfer Execution
# =========================================================================
function Execute-CharacterTransfer {
    param(
        [string]$SourcePath,
        [string]$TargetPath,
        [string]$TargetName,
        [string]$TargetAccount,
        [string]$TargetRealm,
        [bool]$DoBackup = $true
    )

    if (-not (Test-Path -LiteralPath $SourcePath)) {
        throw "Source character path does not exist: $SourcePath"
    }

    if (-not (Test-Path -LiteralPath $TargetPath)) {
        Ensure-Directory $TargetPath
        Log-Msg "Created target character directory: $TargetPath" "INFO"
    } elseif ($DoBackup) {
        $backupDir = New-WtfBackup $txtWtfPath.Text $TargetPath "Char" "${TargetAccount}_${TargetRealm}_${TargetName}"
        if ($backupDir) {
            Log-Msg "Created backup of existing target in: $backupDir" "BACKUP"
        }
    }

    $copiedCount = 0

    if ($chkCharLayout.Checked) {
        Copy-FileWithOldVariant $SourcePath $TargetPath "layout-local.txt" ([ref]$copiedCount)
    }
    if ($chkCharEditMode.Checked) {
        Copy-FileWithOldVariant $SourcePath $TargetPath "edit-mode-cache-character.txt" ([ref]$copiedCount)
    }
    if ($chkCharConfig.Checked) {
        Copy-FileWithOldVariant $SourcePath $TargetPath "config-cache.wtf" ([ref]$copiedCount)
    }
    if ($chkCharChat.Checked) {
        Copy-FileWithOldVariant $SourcePath $TargetPath "chat-cache.txt" ([ref]$copiedCount)
    }
    if ($chkCharBindings.Checked) {
        Copy-FileWithOldVariant $SourcePath $TargetPath "bindings-cache.wtf" ([ref]$copiedCount)
    }
    if ($chkCharClickBindings.Checked) {
        Copy-FileWithOldVariant $SourcePath $TargetPath "click-bindings-cache.txt" ([ref]$copiedCount)
    }
    if ($chkCharMacros.Checked) {
        Copy-FileWithOldVariant $SourcePath $TargetPath "macros-cache.txt" ([ref]$copiedCount)
    }
    if ($chkCharAddons.Checked) {
        Copy-FileWithOldVariant $SourcePath $TargetPath "AddOns.txt" ([ref]$copiedCount)
    }
    Copy-FileWithOldVariant $SourcePath $TargetPath "tts-cache-character.txt" ([ref]$copiedCount)
    Copy-FileWithOldVariant $SourcePath $TargetPath "flagged-cache-character.txt" ([ref]$copiedCount)

    if ($chkCharSavedVars.Checked) {
        Copy-AddonSavedVariables $SourcePath $TargetPath ([ref]$copiedCount)
    }

    if ($chkCharResetMd5.Checked) {
        Remove-CacheHash $TargetPath
    }

    return $copiedCount
}

$btnTransferChar.Add_Click({
    $srcAcc = $cmbSrcCharAcc.SelectedItem
    $srcRealm = $cmbSrcCharRealm.SelectedItem
    $srcChar = $cmbSrcCharName.SelectedItem

    if (-not $srcAcc -or -not $srcRealm -or -not $srcChar) {
        [System.Windows.Forms.MessageBox]::Show("Please select a complete source character.", "Selection Missing", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    $srcPath = Join-Path $txtWtfPath.Text "Account\$srcAcc\$srcRealm\$srcChar"

    $dstAcc = $cmbDstCharAcc.SelectedItem
    $dstRealm = $cmbDstCharRealm.SelectedItem
    if (-not $dstAcc -or -not $dstRealm) {
        [System.Windows.Forms.MessageBox]::Show("Please select a target account and realm.", "Selection Missing", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    $dstChar = ""
    if ($rbDstNewChar.Checked) {
        $dstChar = $txtDstNewCharName.Text.Trim()
        if ([string]::IsNullOrWhiteSpace($dstChar)) {
            [System.Windows.Forms.MessageBox]::Show("Please type a new character name.", "Name Required", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }
    } else {
        $dstChar = $cmbDstCharName.SelectedItem
        if (-not $dstChar) {
            [System.Windows.Forms.MessageBox]::Show("Please select an existing target character or choose 'Create New Character Name'.", "Selection Missing", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }
    }

    $dstPath = Join-Path $txtWtfPath.Text "Account\$dstAcc\$dstRealm\$dstChar"

    if ($srcPath -eq $dstPath) {
        [System.Windows.Forms.MessageBox]::Show("Source and target are the same character folder.`n`nPlease choose a different target.", "Same Source and Target", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        return
    }

    $procs = Get-RunningWowClientProcesses
    if ($procs -and $procs.Count -gt 0) {
        $warn = [System.Windows.Forms.MessageBox]::Show(
            "World of Warcraft is currently RUNNING!`n`nIf you proceed, WoW may overwrite your transferred settings when you close the game.`n`nDo you want to continue anyway?",
            "WoW Client Running Warning",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        if ($warn -ne [System.Windows.Forms.DialogResult]::Yes) {
            return
        }
    }

    try {
        Log-Msg "Starting character transfer from [$srcChar ($srcRealm-$srcAcc)] to [$dstChar ($dstRealm-$dstAcc)]..." "TRANSFER"
        $count = Execute-CharacterTransfer -SourcePath $srcPath -TargetPath $dstPath -TargetName $dstChar -TargetAccount $dstAcc -TargetRealm $dstRealm -DoBackup $chkCharBackup.Checked
        Log-Msg "Character settings transfer COMPLETE! ($count files copied)." "SUCCESS"
        [System.Windows.Forms.MessageBox]::Show(
            "Successfully transferred settings from:`n  $srcChar ($srcRealm - $srcAcc)`nto:`n  $dstChar ($dstRealm - $dstAcc)`n`nTotal files transferred: $count",
            "Transfer Complete",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
        Rescan-All
    } catch {
        Log-Msg "Character transfer failed: $($_.Exception.Message)" "ERROR"
        [System.Windows.Forms.MessageBox]::Show("Error transferring character settings: $($_.Exception.Message)", "Transfer Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

$btnBatchRealm.Add_Click({
    $srcAcc = $cmbSrcCharAcc.SelectedItem
    $srcRealm = $cmbSrcCharRealm.SelectedItem
    $srcChar = $cmbSrcCharName.SelectedItem

    $dstAcc = $cmbDstCharAcc.SelectedItem
    $dstRealm = $cmbDstCharRealm.SelectedItem

    if (-not $srcAcc -or -not $srcRealm -or -not $srcChar -or -not $dstAcc -or -not $dstRealm) {
        [System.Windows.Forms.MessageBox]::Show("Please select a source character and a target account/realm.", "Selection Missing", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    $srcPath = Join-Path $txtWtfPath.Text "Account\$srcAcc\$srcRealm\$srcChar"
    $targetRealmObj = ($global:WtfHierarchy.Accounts | Where-Object { $_.Name -eq $dstAcc }).Realms | Where-Object { $_.Name -eq $dstRealm }
    
    if (-not $targetRealmObj -or $targetRealmObj.Characters.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No characters found on target realm $dstRealm.", "No Characters", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        return
    }

    $targets = $targetRealmObj.Characters | Where-Object { $_.Path -ne $srcPath }
    if ($targets.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No other characters found on target realm.", "Info", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        return
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Copy settings from '$srcChar' to ALL $($targets.Count) other character(s) on realm '$dstRealm' ($dstAcc)?`n`nTargets:`n" + (($targets | ForEach-Object { " • $($_.Name)" }) -join "`n"),
        "Confirm Batch Realm Sync",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if ($confirm -eq [System.Windows.Forms.DialogResult]::Yes) {
        $totalDone = 0
        foreach ($t in $targets) {
            try {
                $c = Execute-CharacterTransfer -SourcePath $srcPath -TargetPath $t.Path -TargetName $t.Name -TargetAccount $dstAcc -TargetRealm $dstRealm -DoBackup $chkCharBackup.Checked
                $totalDone++
                Log-Msg "Batch synced to $($t.Name) ($c files)." "SUCCESS"
            } catch {
                Log-Msg "Batch error for $($t.Name): $($_.Exception.Message)" "ERROR"
            }
        }
        [System.Windows.Forms.MessageBox]::Show("Batch sync finished! Synced to $totalDone character(s).", "Batch Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        Rescan-All
    }
})

# =========================================================================
# Step 8: Account Transfer Execution
# =========================================================================
function Execute-AccountTransfer {
    param(
        [string]$SourcePath,
        [string]$TargetPath,
        [string]$TargetName,
        [bool]$DoBackup = $true
    )

    if (-not (Test-Path -LiteralPath $SourcePath)) {
        throw "Source account path does not exist: $SourcePath"
    }

    if (-not (Test-Path -LiteralPath $TargetPath)) {
        Ensure-Directory $TargetPath
        Log-Msg "Created target account directory: $TargetPath" "INFO"
    } elseif ($DoBackup) {
        $backupDir = New-WtfBackup $txtWtfPath.Text $TargetPath "Account" $TargetName
        if ($backupDir) {
            Log-Msg "Created backup of existing account in: $backupDir" "BACKUP"
        }
    }

    $copiedCount = 0

    if ($chkAccBindings.Checked) {
        Copy-FileWithOldVariant $SourcePath $TargetPath "bindings-cache.wtf" ([ref]$copiedCount)
    }
    if ($chkAccConfig.Checked) {
        Copy-FileWithOldVariant $SourcePath $TargetPath "config-cache.wtf" ([ref]$copiedCount)
    }
    if ($chkAccMacros.Checked) {
        Copy-FileWithOldVariant $SourcePath $TargetPath "macros-cache.txt" ([ref]$copiedCount)
    }
    if ($chkAccEditMode.Checked) {
        Copy-FileWithOldVariant $SourcePath $TargetPath "edit-mode-cache-account.txt" ([ref]$copiedCount)
    }
    if ($chkAccChat.Checked) {
        Copy-FileWithOldVariant $SourcePath $TargetPath "chat-cache.txt" ([ref]$copiedCount)
    }
    if ($chkAccTTS.Checked) {
        Copy-FileWithOldVariant $SourcePath $TargetPath "tts-cache-account.txt" ([ref]$copiedCount)
        Copy-FileWithOldVariant $SourcePath $TargetPath "flagged-cache-account.txt" ([ref]$copiedCount)
    }
    if ($chkAccSavedVars.Checked) {
        Copy-AddonSavedVariables $SourcePath $TargetPath ([ref]$copiedCount)
    }

    if ($chkAccResetMd5.Checked) {
        Remove-CacheHash $TargetPath
    }

    return $copiedCount
}

$btnTransferAccount.Add_Click({
    $srcAcc = $cmbSrcAccount.SelectedItem
    $dstAcc = $cmbDstAccount.SelectedItem

    if (-not $srcAcc -or -not $dstAcc) {
        [System.Windows.Forms.MessageBox]::Show("Please select both a source and target account.", "Selection Missing", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    if ($srcAcc -eq $dstAcc) {
        [System.Windows.Forms.MessageBox]::Show("Source and target are the same account.`n`nPlease choose a different target account.", "Same Account", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        return
    }

    $srcPath = Join-Path $txtWtfPath.Text "Account\$srcAcc"
    $dstPath = Join-Path $txtWtfPath.Text "Account\$dstAcc"

    $procs = Get-RunningWowClientProcesses
    if ($procs -and $procs.Count -gt 0) {
        $warn = [System.Windows.Forms.MessageBox]::Show(
            "World of Warcraft is currently RUNNING!`n`nIf you proceed, WoW may overwrite account settings upon exit.`n`nDo you want to continue anyway?",
            "WoW Client Running Warning",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        if ($warn -ne [System.Windows.Forms.DialogResult]::Yes) {
            return
        }
    }

    try {
        Log-Msg "Starting account transfer from [$srcAcc] to [$dstAcc]..." "TRANSFER"
        $count = Execute-AccountTransfer -SourcePath $srcPath -TargetPath $dstPath -TargetName $dstAcc -DoBackup $chkAccBackup.Checked
        Log-Msg "Account settings transfer COMPLETE! ($count files copied)." "SUCCESS"
        [System.Windows.Forms.MessageBox]::Show(
            "Successfully transferred account settings from:`n  Account: $srcAcc`nto:`n  Account: $dstAcc`n`nTotal files transferred: $count",
            "Transfer Complete",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
        Rescan-All
    } catch {
        Log-Msg "Account transfer failed: $($_.Exception.Message)" "ERROR"
        [System.Windows.Forms.MessageBox]::Show("Error transferring account settings: $($_.Exception.Message)", "Transfer Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

$btnBatchAllAccounts.Add_Click({
    $srcAcc = $cmbSrcAccount.SelectedItem
    if (-not $srcAcc) {
        [System.Windows.Forms.MessageBox]::Show("Please select a source account.", "Selection Missing", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    $otherAccounts = $global:WtfHierarchy.Accounts | Where-Object { $_.Name -ne $srcAcc }
    if ($otherAccounts.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No other accounts found to sync to.", "Info", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        return
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Copy account settings from '$srcAcc' to ALL $($otherAccounts.Count) other account(s)?`n`nTarget Accounts:`n" + (($otherAccounts | ForEach-Object { " • $($_.Name)" }) -join "`n"),
        "Confirm Batch Account Sync",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if ($confirm -eq [System.Windows.Forms.DialogResult]::Yes) {
        $srcPath = Join-Path $txtWtfPath.Text "Account\$srcAcc"
        $totalDone = 0
        foreach ($oa in $otherAccounts) {
            try {
                $c = Execute-AccountTransfer -SourcePath $srcPath -TargetPath $oa.Path -TargetName $oa.Name -DoBackup $chkAccBackup.Checked
                $totalDone++
                Log-Msg "Batch synced account to $($oa.Name) ($c files)." "SUCCESS"
            } catch {
                Log-Msg "Batch error for account $($oa.Name): $($_.Exception.Message)" "ERROR"
            }
        }
        [System.Windows.Forms.MessageBox]::Show("Batch sync finished! Synced to $totalDone account(s).", "Batch Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        Rescan-All
    }
})

# =========================================================================
# Step 9: Initialize and Show Form
# =========================================================================
$form.Add_Shown({
    Update-WowStatus
    Populate-AllData $global:WtfHierarchy
    Log-Msg "1337cookie's WoW setting transfer utility ready." "READY"
})

[System.Windows.Forms.Application]::Run($form)
