function Get-Combination {
	[CmdletBinding()]
	param(
		[Parameter(Position = 0,
			 Mandatory = $true,
			 ValuefromPipeline = $true,
			 ValuefromPipelineByPropertyName = $true)]
		[array]$Array
    )

    #uncomment following to ensure only unique inputs are parsed
    #e.g. 'B','C','D','E','E' would become 'B','C','D','E'
    $Array = $Array | Select-Object -Unique

    #for any set of length n the maximum number of subsets is 2^n
  ` for ($i = 0; $i -lt [Math]::Pow(2,$Array.Length); $i++)
    { 
        #temporary array to hold output
        [string[]]$out = New-Object string[] $Array.length
        #iterate through each element
        for ($j = 0; $j -lt $Array.Length; $j++)
        { 
            #start at the end of the array take elements, work your way towards the front
            if (($i -band (1 -shl ($Array.Length - $j - 1))) -ne 0)
            {
                #store the subset in a temp array
                $out[$j] = $Array[$j]
            }
        }
        #stick subset into an array
        #$l += -join $out
        $output = [PSCustomObject]@{
            Combination = $out.Where({ $null -ne $_ })
            Iteration = $i
        }
        Write-Output $output
    }
    #group the subsets by length, iterate through them and sort
    #$output = $l | Group-Object -Property Length | ForEach-Object {$_.Group | Sort-Object}

    
}