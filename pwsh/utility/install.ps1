param([switch]$Scoop)

function Install-ScoopPackages {
    # install scoop if N/A
    if (-not $(where.exe 'scoop.cmd')) {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    }
    
    if (-not $(where.exe 'scoop.cmd')) {
        throw 'scoop installer is N/A'
    }
    
    #
    # This is to keep tracking of packages I installed,
    # But I did not test it
    # Should work fine though
    #
    scoop install aria2 7zip dark pwsh
    
    scoop bucket add extras

    scoop install neovim bottom docker `
        nodejs python rust lua `
        posh-git terminal-icons `
        fzf fd ripgrep eza zoxide delta bat tokei fq `
        sudo tldr universal-ctags `
        wasmtime emscripten

    scoop install vscodium # freeplane krita blender reaper

    pip install jrnl
}

if ($Scoop) {
    Install-ScoopPackages
}
