
function TryLaunch-VsDevShell {
    param([string]$VSWhereExe)
    
    if (-not (Test-Path $VSWhereExe)) {
        $Directory = Split-Path -Parent $VSWhereExe
        if (-not (Test-Path $Directory)) {
            New-Item -ItemType Directory -Path $Directory -Force
        }
        # TODO: dynamically get latest vswhere.exe release tag?
        Invoke-WebRequest -Uri "https://github.com/microsoft/vswhere/releases/download/3.1.7/vswhere.exe" -OutFile $VSWhereExe
    }

    $VsInstallationPath = Invoke-Expression -Command "${VSWhereExe} -nologo -prerelease -latest -property installationPath"
    
    if (-not (Test-Path $VsInstallationPath)) {
        throw "vs installation was not found"
    }

    $Launcher = Join-Path $VsInstallationPath 'Common7' 'Tools' 'Launch-VsDevShell.ps1'
    if (-not (Test-Path $Launcher)) {
        throw "vs dev shell launch script was not found"
    }
    
    Invoke-Expression -Command "& '${Launcher}' -Arch amd64 -HostArch amd64" > $null
}
