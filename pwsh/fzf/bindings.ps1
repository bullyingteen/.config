
enum Path_Type {
    File
    Directory
    Link
}

function Get-PathType {
    param([System.Management.Automation.PathInfo]$Path)
    $item = Get-Item $Path
    if ($item.Attributes -eq [IO.FileAttributes]::Directory) {
        return [Path_Type]::Directory
    } elseif ($item.Attributes -eq [IO.FileAttributes]::ReparsePoint) {
        return [Path_Type]::Link
    } else {
        return [Path_Type]::File
    }
}

class Path_Entry {
    [string]$Name
    [System.Management.Automation.PathInfo]$Path
    [Path_Type]$Type
}

function Select-Paths {
    $preview = "pwsh -NoProfile -NonInteractive -File `"${PSScriptRoot}\fzf\preview_path.ps1`" {1}"

    $fdprefix = 'fd --color=always --strip-cwd-prefix -u -E node_modules -E __pycache__ -E .git -E .vs -E .vscode'
    
    $result = fd --color=always --strip-cwd-prefix -u -E node_modules -E __pycache__ -E .git -E .vs -E .vscode `
    | fzf `
        --ansi `
        --multi `
        --color "hl:-1:underline,hl+:-1:underline:reverse" `
        --bind "ctrl-d:reload($fdprefix -td)+change-prompt(dir> )" `
        --bind "ctrl-f:reload($fdprefix -tf)+change-prompt(file> )" `
        --bind "ctrl-l:reload($fdprefix -tl)+change-prompt(link> )" `
        --bind "ctrl-a:reload($fdprefix)+change-prompt(all> )" `
        --prompt 'all> ' `
        --header '╱ CTRL-A (all) / CTRL-F (file) ╱ CTRL-D (dir) ╱ CTRL-L (link) /' `
        --preview $preview `
        --preview-window 'down,50%,border-top,+{2}+3/3,~3' `
        | ForEach-Object {
            $Path = $(Resolve-Path $_)
            $entry = [Path_Entry]::new()
            $entry.Name = $_
            $entry.Path = $Path
            $entry.Type = Get-PathType $Path
            $entry
        }
    
    # Write-Host "-- fzf: selected paths are now accessible from variable `$r:"
    Set-Variable -Name 'r' -Value $result -Scope Global
    return $global:r
}

class File_Entry {
    [string]$Name
    [System.Management.Automation.PathInfo]$Path
    [int]$Line
}

function Select-FilesWithContent {
    $RipGrep = "rg --column --line-number --no-heading --color=always --smart-case";
    
    $SearchString = Get-Clipboard

    $result = rg --column --line-number --no-heading --color=always --smart-case $SearchString `
    | fzf `
        --ansi `
        --multi `
        --color "hl:-1:underline,hl+:-1:underline:reverse" `
        --disabled --query "$SearchString" `
        --bind "change:reload: $RipGrep {q} || cd ." `
        --bind "ctrl-f:unbind(change,ctrl-f)+change-prompt(file> )+enable-search+clear-query+rebind(ctrl-r)" `
        --bind "ctrl-r:unbind(ctrl-r)+change-prompt(content> )+disable-search+reload($RipGrep {q} || cd .)+rebind(change,ctrl-f)" `
        --prompt 'content> ' `
        --delimiter : `
        --header '╱ CTRL-R (rg mode: content) ╱ CTRL-F (fzf mode: file) ╱' `
        --preview 'bat --color=always {1} --highlight-line {2}' `
        --preview-window 'down,50%,border-top,+{2}+3/3,~3' `
    | ForEach-Object { 
        $split = $_.Split(':')
        $fileName = $split[0]
        $lineNum = $split[1]
        $entry = [File_Entry]::new()
        $entry.Name = $fileName
        $entry.Path = Resolve-Path $fileName
        $entry.Line = [int]$lineNum
        $entry
    }

    # Write-Host "-- fzf: selected files are now accessible from variable `$r"
    Set-Variable -Name 'r' -Value $result -Scope Global
    return $global:r
}

#
# Commands/History
#
function Select-Command {
    $result = Get-History | ForEach-Object { "$_" } `
    | fzf --ansi `
        --color "hl:-1:underline,hl+:-1:underline:reverse" `
        --prompt 'command> '

    Set-ClipBoard -Value $result
    # Write-Host "-- fzf: command was copied to clipboard and is accessible from variable `$r"
    Set-Variable -Name 'r' -Value $result -Scope Global
}

#
# Git
#
class Git_Commit {
    [datetime]$Date
    [string]$AuthorEmail
    [string]$Message
    [string]$Hash
}

function Select-GitCommits {
    $preview_summary = "git show --summary --color=always {-1} | $(git config --get core.pager)"
    $preview_diff = "git diff --color=always {-1} | $(git config --get core.pager)"
    
    $result = git log --color=always --pretty=format:"%C(yellow)%as %C(cyan)%ae%C(reset) :: %C(green)%s%C(reset) %h" `
    | foreach-object {"$_"} `
    | fzf `
        --ansi `
        --multi `
        --header '/ CTRL-S (summary mode) / CTRL-D (diff mode) /' `
        --bind "ctrl-d:change-preview($preview_diff)+change-prompt(diff> )" `
        --bind "ctrl-s:change-preview($preview_summary)+change-prompt(summary> )" `
        --prompt 'summary> ' `
        --preview $preview_summary `
        --preview-window 'down,60%,border-top,+{2}+3/3,~3' `
    | foreach-object {
        # commit hash
        $tokens = -Split $_
        $date = [datetime]::ParseExact($tokens[0], "yyyy-MM-dd", [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None)
        $email = $tokens[1]
        $lastIndex = $tokens.length - 2
        $message = $tokens[3..$lastIndex] | Join-String -Separator ' '
        $hash = $tokens[-1]
        $commit = [Git_Commit]::new() 
        $commit.Date = $date
        $commit.AuthorEmail = $email
        $commit.Message = $message
        $commit.Hash = $hash
        $commit
    }

    # Write-Host "-- fzf: selected commit hashes are now accessible from variable `$r"
    Set-Variable -Name 'r' -Value $result -Scope Global
    return $global:r
}


#
# Environment
#
class Environment_Variable {
    [string]$Key
    [string]$Value
}

function Select-EnvVar {
    $result = Get-ChildItem env:* | Foreach-Object {
        $box = "$_"
        $kv = $box.Substring(1, $box.length-2) -Split ', '
        if ($kv[1][0] -ne '"') {
            $kv[1] = """$($kv[1])"""
        }
        "$([char]27)[93m$($kv[0])$([char]27)[0m=$($kv[1])"
    } `
    | fzf `
        --multi `
        --ansi `
        --color "hl:-1:underline,hl+:-1:underline:reverse" `
        --prompt 'env> ' `
    | Foreach-Object {
        $kv = $_ -Split '='
        $envvar = [Environment_Variable]::new()
        $envvar.Key = $kv[0]
        $envvar.Value = $kv[1]
        $envvar
    }
    
    # Write-Host "-- fzf: selected env vars are now accessible from variable `$r"
    Set-Variable -Name 'r' -Value $result -Scope Global
    # print results
    return $global:r
}


#
# Processes
#
class Process_Info {
    [int]$Id
    [string]$Name
    [string]$CommandLine
}

function Select-Process {
    $preview = "pwsh -NoProfile -NonInteractive -File `"${PSScriptRoot}\fzf\preview_process.ps1`" {1} {2} {3..}"

    $name_width = 60
    $result = Get-CimInstance Win32_Process | Select-Object Name,ProcessId,CommandLine | Sort-Object -Property Name | Foreach-Object {
        "$([char]27)[96m$($_.ProcessId)$([char]27)[0m`t$([char]27)[93m$(if ($_.Name.length -lt $name_width) { $_.Name + (' '*($name_width - $_.Name.length))} else { $_.Name })$([char]27)[0m $([char]27)[90m$(if ($_.CommandLine) {$_.CommandLine} else {$_.Name})$([char]27)[0m"
    } `
    | fzf `
        --multi `
        --ansi `
        --color "hl:-1:underline,hl+:-1:underline:reverse" `
        --prompt 'process> ' `
        --preview $preview `
        --preview-window 'down,50%,border-top,+{2}+3/3,~3' `
    | Foreach-Object {
        $tokens = -Split $_
        $proc = [Process_Info]::new()
        $proc.Id = [int]$tokens[0]
        $proc.Name = $tokens[1]
        $proc.CommandLine = $tokens[2..$tokens.length] | Join-String -Separator ' '
        $proc
    }

    # Write-Host "-- fzf: selected processes are now accessible from variable `$r:"
    Set-Variable -Name 'r' -Value $result -Scope Global
    return $global:r
}


enum C_Kind {
    Function
    Macro

}

class C_Function {
    [string]$Name
    [System.Management.Automation.PathInfo]$File
    [int]$Line
    [string]$Preview
}

class C_Variable {

}

class C_Source_File {

}

function Get-CTags {
    $(ctags -x -R *.c) | Foreach-Object {
        $tokens = -Split $_
        $name = $tokens[0]
        $type = $tokens[1]
        $line = $tokens[2]
        $file = $tokens[3]
        $preview = $tokens[4..$tokens.length] | Join-String -Separator ' '
        "${file}:${line}: $type ${name}: $preview"
        # ...
    } | fzf
}


#
# Consumers
#
function Open-FileLineInVSCode {
    param([File_Entry]$File)
    code -g "$($File.Path):$($File.Line)"
}

filter VSCode_Opener {
    begin{}
    process {
        # expects $_ of type File_Entry
        Open-FileLineInVSCode -File $_
    }
    end{}
}

filter Process_Killer {
    param([switch]$Force)
    begin { }
    process {
        # expects $_ of type Process_Info
        if ($Force) { 
            Stop-Process -Id $_.Id -Force 
        } else { 
            Stop-Process $_.Id
        } 
    }
    end { }
}
