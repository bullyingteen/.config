
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
__zoxide_z projects
holofetch

# . $PSScriptRoot\utility\notify.ps1
# jrnl -tag '@task' -tag '@event' -on today --format json 2>$null | ConvertFrom-Json | Select-Object -ExpandProperty entries | Foreach-Object {
#     Show-Notification -Title "Today at $($_.Time): $($_.Title)" -Text $_.Body
# }

# jrnl -tag '@task' -tag '@event' -on tomorrow --format json 2>$null | ConvertFrom-Json | Select-Object -ExpandProperty entries | Foreach-Object {
#     Show-Notification -Title "Tomorrow at $($_.Time): $($_.Title)" -Text $_.Body
# }
