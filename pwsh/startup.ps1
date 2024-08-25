
Import-Module -Name Terminal-Icons
Import-Module -Name posh-git

Set-ExecutionPolicy -Scope CurrentUser Bypass
$ErrorActionPreference="Stop"

. $PSScriptRoot\environment.ps1
. $PSScriptRoot\aliases.ps1
. $PSScriptRoot\prompt.ps1
. $PSScriptRoot\keybindings.ps1

$ErrorActionPreference="Continue"

# TODO
holofetch
__zoxide_z projects
