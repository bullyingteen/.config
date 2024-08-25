function Get-WeatherReport {
    curl wttr.in/Prague?3Q
}

function Show-DirectoryTree {
    param(
        $Path = '.',
        $Depth = 1,
        [switch]$All,
        [switch]$Long # eza --long ;; print permissions, ownership, size and modification date
    )
    return Invoke-Expression -Command "eza --hyperlink -T -L $Depth $(if ($Long) {'--long'} else {''}) $(if ($All) {'--all'} else {'--git-ignore'}) $Path"
}

function Show-FileContent {
    param([parameter(mandatory = $true)] $Path)
    return Invoke-Expression -Command "bat --color=always $Path"
}

function Find-Files {
    return Invoke-Expression -Command "fd --color=always --strip-cwd-prefix ${args}"
}

function Find-Matches {
    return Invoke-Expression -Command "rg --column --line-number --no-heading --color=always --smart-case ${args}"
}

function holofetch {
    if (Test-Path 'C:\Development\Projects\holofetch\build\holofetch.exe') {
        C:\Development\Projects\holofetch\build\holofetch.exe C:\Development\Projects\holofetch\assets\prerendered_image_data.utf.ans
    } else {
        Write-Host "error: Holofetch is N/A"
    }
}

#####################################################################
Invoke-Expression (& { (zoxide init --no-cmd powershell | Out-String) })
#####################################################################

$__aliases = Get-Alias
if ($__aliases | rg 'ls -> Get-ChildItem') { Remove-Alias ls -Force }
if ($__aliases | rg 'cd -> Set-Location') { Remove-Alias cd -Force }
if ($__aliases | rg 'cat -> Get-Content') { Remove-Alias cat -Force }
# annoying and useless alias to Where-Object (enforce it to be where.exe instead)
if ($__aliases | rg 'where -> Where-Object') { Remove-Alias where -Force }
Remove-Variable -Name '__aliases'

#####################################################################

Set-Alias -Name ls -Value Show-DirectoryTree
Set-Alias -Name cat -Value Show-FileContent
Set-Alias -Name cd -Value __zoxide_z
Set-Alias -Name find -Value Find-Files
Set-Alias -Name grep -Value Find-Matches
Set-Alias -Name weather -Value Get-WeatherReport

#####################################################################
