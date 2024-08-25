
. $PSScriptRoot\fzf\bindings.ps1

Set-PSReadlineKeyHandler -Key Spacebar -Function Complete
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

Set-PSReadLineKeyHandler -Chord 'Ctrl+f,Ctrl+g' -ScriptBlock { $global:r = Select-GitCommits }
Set-PSReadLineKeyHandler -Chord 'Ctrl+f,Ctrl+r' -ScriptBlock { $global:r = Select-FilesWithContent }
Set-PSReadLineKeyHandler -Chord 'Ctrl+f,Ctrl+d' -ScriptBlock { $global:r = Select-Paths }
Set-PSReadLineKeyHandler -Chord 'Ctrl+f,Ctrl+h' -ScriptBlock { $global:r = Select-Command }
Set-PSReadLineKeyHandler -Chord 'Ctrl+f,Ctrl+e' -ScriptBlock { $global:r = Select-EnvVar }
Set-PSReadLineKeyHandler -Chord 'Ctrl+f,Ctrl+p' -ScriptBlock { $global:r = Select-Process }
