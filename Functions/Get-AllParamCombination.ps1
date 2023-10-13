<#	
	.NOTES
	===========================================================================
	 Created on:   	01/02/2017 13:55
	 Created by:   	Jim Moyle
	 Github: https://github.com/JimMoyle/
	 Twitter: @jimmoyle
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

function Get-AllParamCombination {
	[CmdletBinding()]
	param(
		[Parameter(Position = 0,
			 Mandatory = $false,
             ValuefromPipeline = $true,
			 ValuefromPipelineByPropertyName = $true)]
		[System.String]$Name
	)
	
	BEGIN {
        Set-StrictMode -Version Latest
		$expandedParams = $null
		$PSBoundParameters.GetEnumerator() | ForEach-Object { $expandedParams += ' -' + $_.key + ' '; $expandedParams += $_.value }
		Write-Verbose "Starting: $($MyInvocation.MyCommand.Name)$expandedParams"

        $advancedParams = 'Verbose','Debug','ErrorAction','WarningAction','InformationAction','ErrorVariable','WarningVariable','InformationVariable','OutVariable','OutBuffer','PipelineVariable'

	}
	
	PROCESS {
		try {
            $functionData = Get-Command $Name -ErrorAction Stop
        }
        catch{
            Write-Error "Can not find command $name"
        }

        foreach ($set in $functionData.ParameterSets){
            $params = $set.Parameters | Where-Object {$_.Name -notin $advancedParams}
            $mandatoryParams = $params | Where-Object IsMandatory -eq $true
            $optionalParams = $params | Where-Object IsMandatory -ne $true

            $optionalCombinations = Get-Combination $optionalParams.Name 
        }
           
	}
	END {
	}
}

'Get-Content' | Get-AllParamCombination