$env:EDITOR = (where.exe 'code.cmd')
$env:VISUAL = $env:EDITOR

# git-ssh
$env:GIT_SSH='C:\Windows\System32\OpenSSH\ssh.exe'

# fzf
$env:FZF_DEFAULT_COMMAND='fd --color=always --strip-cwd-prefix'
$env:FZF_DEFAULT_OPTS=''

# PATH
$env:my_tools_directory = 'C:\Development\Tools'
$env:PATH += ";$env:my_tools_directory"

# vs build tools environment
. $PSScriptRoot\utility\vs_dev_shell.ps1
if ($env:my_tools_directory) {
    TryLaunch-VsDevShell -VSWhereExe (Join-Path $env:my_tools_directory 'vswhere.exe')
}
