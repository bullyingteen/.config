#
# This is to keep tracking of packages I installed,
# But I did not test it
# Should work fine though
#

function Install-ScoopPackages {
    # install scoop if N/A
    if (-not $(where.exe 'scoop.cmd')) {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    }

    if (-not $(where.exe 'scoop.cmd')) {
        throw 'scoop installer is N/A'
    }

    scoop install 7zip aria2 dark
    scoop install bottom docker `
        nodejs python rust lua `
        posh-git terminal-icons `
        fzf fd ripgrep eza zoxide tokei `
        sudo tldr universal-ctags `
        wasmtime emscripten
}
