param($ProcessId, $ProcessName, $CommandLine)

# $cmd = $(Get-CimInstance Win32_Process -Filter "ProcessId = $ProcessId" | Select-Object CommandLine).CommandLine
if ($CommandLine) {
    $arguments = -Split $CommandLine

    write-host "pid: " -NoNewline
    write-host "$([char]27)[96m$ProcessId$([char]27)[0m" # -ForegroundColor cyan
    
    write-host "command:$([char]27)[93m" -NoNewline

    $i = 0
    $line = ''
    
    while ($i -lt $arguments.length) {
        if ($line.length -gt 60) {
            write-host $line
            $line = "`t`` $([char]27)[93m"
        }

        $line += ' '
        $line += $arguments[$i]
        $i += 1
    }

    if ($line -ne "`t`` ") {
        write-host $line
    }

    write-host "$([char]27)[0m"

} else {
    write-host "pid: " -NoNewline
    write-host "$([char]27)[96m$ProcessId$([char]27)[0m" #-ForegroundColor cyan
    
    write-host "command: " -NoNewline
    write-host "$([char]27)[93m$ProcessName$([char]27)[0m"
}
