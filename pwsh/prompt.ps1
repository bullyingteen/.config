
class __Prompt_Data {
    [Boolean] $Failed
    [int] $ExitCode
    [string] $CommandLine
    [string] $Duration
    [string] $WorkingDirectory
    [string] $Time
}

class __Prompt_Theme {
    static [string] $Success = $PSStyle.Foreground.Green
    static [string] $Failure = $PSStyle.Foreground.Red
    static [string] $Duration = $PSStyle.Foreground.White
    static [string] $Time = $PSStyle.Foreground.Cyan
    static [string] $Input = $PSStyle.Foreground.White
    static [string] $Directory = $PSStyle.Foreground.Green
    
    static [string] $SuccessIcon = ''
    static [string] $FailureIcon = ''
    static [string] $CommandIcon = '' 
    static [string] $DirectoryIcon = '' 
    static [string] $ClockIcon = '' 
    static [string] $ArrowIcon = '' 
    static [string] $BracketOpenIcon = ''
    static [string] $BracketCloseIcon = ''

    static [string] Render([__Prompt_Data]$Data) {
        $__status_color = [__Prompt_Theme]::Success
        $__status_icon = [__Prompt_Theme]::SuccessIcon
    
        if ($Data.Failed) {
            $__status_color = [__Prompt_Theme]::Failure
            $__status_icon = [__Prompt_Theme]::FailureIcon
        }
    
        $__duration = "$([__Prompt_Theme]::Duration)$($Data.Duration)s$($global:PSStyle.Reset)"
        $__directory = "$([__Prompt_Theme]::Directory)$([__Prompt_Theme]::DirectoryIcon) $($Data.WorkingDirectory)$($global:PSStyle.Reset)"
        $__input = "$([__Prompt_Theme]::Input)$([__Prompt_Theme]::CommandIcon)$($global:PSStyle.Reset)"
        $__time = "$([__Prompt_Theme]::Time)$($Data.Time)$($global:PSStyle.Reset)"
        $__exitcode = "$([__Prompt_Theme]::ArrowIcon) ${__status_color}$($Data.ExitCode)$($global:PSStyle.Reset)"
        
        return "${__time} ${__status_color}${__status_icon}$($global:PSStyle.Reset) ${__duration} ${__exitcode}`n" `
            + "${__directory} ${__input} "
    }
}

function prompt {
    $__status = $?
    $__exitcode = $LASTEXITCODE
    $__cmd = (Get-History)[-1]
    
    $Data = [__Prompt_Data]::new()

    $Data.Failed = -Not ($__status)
    $Data.ExitCode = $__exitcode
    $Data.CommandLine = $__cmd.CommandLine
    $Data.Duration = [math]::round($__cmd.Duration.TotalSeconds, 3)
    $Data.WorkingDirectory = Get-Location
    $Data.Time = (Get-Date).ToLongTimeString()

    return [__Prompt_Theme]::Render($Data)
}
