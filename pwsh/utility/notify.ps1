Add-Type -AssemblyName System.Windows.Forms

function Dispose-Notification {
    param($Event) 
    $Event.Sender.dispose()
    Unregister-Event -SourceIdentifier $Event.MessageData
    Remove-Job -Name $Event.MessageData
}

function Register-NotificationClick {
    param($Notification, [scriptblock]$Action, $MessageData)

    [void](Register-ObjectEvent -InputObject $Notification -EventName Click -SourceIdentifier "$Title Click" -MessageData $MessageData -Action $Action)   
    [void](Register-ObjectEvent -InputObject $Notification -EventName BalloonTipClicked -SourceIdentifier "$Title TipClick" -MessageData $MessageData -Action $Action)
}

function New-Notification {
    param([string]$Title, [string]$Text, [int]$Milliseconds = 5000)
    
    $Balloon = New-Object System.Windows.Forms.NotifyIcon
    
    $path = (Get-Process -id $pid).Path
    $Balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
    $Balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info 
    $Balloon.BalloonTipText = $Text
    $Balloon.BalloonTipTitle = $Title
    $Balloon.Visible = $true 
    $Balloon.ShowBalloonTip($Milliseconds)

    [void](Register-ObjectEvent -InputObject $Balloon -EventName BalloonTipClosed -SourceIdentifier "$Title TipClose" -MessageData "$Title TipClose" -Action {
        Dispose-Notification $Event
    })

    return $Balloon
}
