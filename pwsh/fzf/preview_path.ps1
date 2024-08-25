param($fzfItem)

$path = $(Resolve-Path $fzfItem) 

if (test-path $path) { 
    if ($(get-item $path).PSIsContainer) { 
        Invoke-Expression -Command "eza -T -L 2 --git-ignore --color=always $path"
    } else { 
        Invoke-Expression -Command "bat --color=always $path" 
    } 
} else { 
    "no such file or directory: $path" 
}
