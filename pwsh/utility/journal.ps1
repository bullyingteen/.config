
class Jrnl_Entry {
    [string] $Date
    [string] $Time
    [string] $Title
    [string] $Body
    [string[]] $Tags
    [Boolean] $Starred

    static [Jrnl_Entry] FromJSON([System.Object]$JSON) {
        if (-not $JSON) {
            return $null
        }

        $result = [Jrnl_Entry]::new()

        $result.Date = $JSON.date
        $result.Time = $JSON.time
        $result.Title = $JSON.title
        $result.Body = $JSON.body

        $_tags = [System.Collections.ArrayList]@()
        $JSON.tags | foreach-object { $_tags.Add("$_") }
        $result.Tags = $_tags.ToArray()
        $result.Starred = $JSON.starred

        return $result
    }
}

class Jrnl_Search_Result {
    [hashtable] $Tags
    [Jrnl_Entry[]] $Entries

    static [Jrnl_Search_Result] FromJSON([System.Object]$JSON) {
        if (-not $JSON.entries.length) {
            return $null
        }

        $result = [Jrnl_Search_Result]::new()

        $result.Entries = $JSON.entries | foreach-object { [Jrnl_Entry]::FromJSON($_) }
        $result.Tags = @{}

        if ($JSON.tags.psobject.properties.length) {
            $JSON.tags.psobject.properties | foreach-object {
                $result.Tags[$_.Name] = $_.Value
            }
        }
        
        return $result
    }

}

function Search-Jrnl {
    param(
        [string]$OnDate = $null,
        [string]$OnTime = '',
        [string]$FromDate = $null,
        [string]$FromTime = '',
        [string]$ToDate = $null,
        [string]$ToTime = '',
        [string]$Text = $null,
        [string[]]$AnyTags = @(),
        [string[]]$AllTags = @(),
        [string[]]$NotTags = @(),
        [int]$Count = $null,
        [switch]$Starred,
        [switch]$Edit,
        [switch]$Delete
    )

    $command = 'jrnl '
    $prefix = ''

    if ($AnyTags.length) {
        $AnyTags | foreach-object {
            $command += "-tag '$_' "
        }
        $prefix = '-and'
    } elseif ($AllTags.length) {
        $AllTags | foreach-object {
            $command += "$prefix -tag '$_' "
            $prefix = '-and'
        }
    }

    if ($NotTags.length) {
        $NotTags | foreach-object {
            $command += "-not '$_' "
            $prefix = '-and'
        }
    }

    if ($OnDate) {
        $command += "-on '$OnDate$(if ($OnTime) {' '+$OnTime} else {''})' "
        $prefix = '-and '
    } elseif ($FromDate -or $ToDate) {
        if ($FromDate) {
            $command += "-from '$FromDate$(if ($FromTime) {' '+$FromTime} else {''})' "
            $prefix = '-and'
        }

        if ($ToDate) {
            $command += "-to '$ToDate$(if ($ToTime) {' '+$ToTime} else {''})' "
            $prefix = '-and'
        }
    }

    if ($Text) {
        $command += "$prefix -contains '$Text' "
        $prefix = '-and'
    }

    if ($Starred) {
        $command += "$prefix -starred "
        $prefix = '-and'
    }

    if ($Count) {
        $command += "$prefix -n $Count "
    }

    if (-not $prefix) {
        return $null
    }

    write-host "CMD: $command"

    if ($Edit) {
        $command += '--edit 2>$null'
        Invoke-Expression -Command $command
    } elseif ($Delete) {
        $command += '--delete'
        Invoke-Expression -Command $command
    } else {
        $command += '--format json 2>$null'
        $JSON = Invoke-Expression -Command $command | ConvertFrom-Json
        return [Jrnl_Search_Result]::FromJSON($JSON)
    }
}

function Edit-JrnlTasks {
    Search-Jrnl -AnyTags @('@task') -NotTags @('@done') -Edit
}

function Edit-JrnlEvents {
    Search-Jrnl -AnyTags @('@event') -FromDate 'today' -Edit
}

function List-JrnlUpcoming {
    Search-Jrnl -AnyTags @('@task', '@event') -NotTags @('@done') -FromDate 'today' -ToDate 'tomorrow' | Select-Object -ExpandProperty Entries | Select-Object Date,Time,Title
}
