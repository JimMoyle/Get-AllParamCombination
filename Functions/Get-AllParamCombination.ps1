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
		[System.String]$Name,
		
		[Parameter(Position = 1,
			 Mandatory = $false,
			 ValuefromPipelineByPropertyName = $true)]
		[System.Int32]$Module
	)
	
	BEGIN {
        Set-StrictMode -Version Latest
		$expandedParams = $null
		$PSBoundParameters.GetEnumerator() | ForEach-Object { $expandedParams += ' -' + $_.key + ' '; $expandedParams += $_.value }
		Write-Verbose "Starting: $($MyInvocation.MyCommand.Name)$expandedParams"

	}
	
	PROCESS {
        $paramValues = @()
        $commandsOutputted = @()
		try {
            $advancedParams = 'Verbose','Debug','ErrorAction','WarningAction','InformationAction','ErrorVariable','WarningVariable','InformationVariable','OutVariable','OutBuffer','PipelineVariable'
            $functionData = Get-Command $Name -ErrorAction Stop
            $paramList = $functionData.Parameters.GetEnumerator() | Where-Object {$advancedParams -notcontains $_.key}

            foreach ($param in $paramList){
                $paramMetadata = [PSCustomObject]@{
                    Name = $param.key
                    Type = $param.value.ParameterType.Name #ToString()
                    Mandatory = $param.value.ParameterSets.Values.IsMandatory
                    IsSwitch = $param.value.SwitchParameter
                    Validate = $param.Value.Attributes.TypeID | Select-Object -First 1 | Where-Object { $_.Name -ne 'ParameterAttribute' } | Select-Object -ExpandProperty Name
                    ValueFromPipeline = $param.value.ParameterSets.Values.ValueFromPipeline
                    ValueFromPipelineByPropertyName = $param.value.ParameterSets.Values.ValuefromPipelineByPropertyName
                    ParameterSet = $param.value.ParameterSets.Keys
                }
                $paramValues += $paramMetadata
            }
            
            if ($paramValues.ParameterSet.count -gt 1){
                $sets = $paramValues.ParameterSet | Get-Unique | Where-Object {$_ -ne '__AllParameterSets'}
            }
            else{
                $sets = $paramValues.ParameterSet
            }

            foreach ($set in $sets){

                $minCommand = $Name

                $setValues = $paramValues | Where-Object {$_.ParameterSet -eq $set -or $_.ParameterSet -eq '__AllParameterSets'}

                $paramInSet = $paramValues | Where-Object { $_.ParameterSet -eq $set}

                if (($paramInSet | Measure-Object | Select-Object -ExpandProperty Count) -eq 1){
                    
                    $paramInSet.Mandatory = $true

                }
            
                $setValues | Where-Object {$_.Mandatory -eq $true -or $null -ne $_.Validate } | ForEach-Object {

                    if ($_.IsSwitch){
                        $minCommand += " `-$($_.Name)"
                     }
                     else {

                        $minCommand += " `-$($_.Name) [$($_.Type)]"
                     }

                }
                
                $optionalParams = $setValues | Where-Object {$_.Mandatory -eq $false -and $null -eq $_.Validate}

                if ($optionalParams){
                    $snip = $optionalParams | ForEach-Object {
                        
                        if ($_.IsSwitch){
                            $invSnip = " `-$($_.Name)"
                        }
                        else {
                            $invSnip = " `-$($_.Name) [$($_.Type)]"
                        }

                        $invSnip

                    }

                    foreach ($combination in (Get-Combination -Array $snip)) {

                        $out = "$minCommand$combination"
                        if ($commandsOutputted -notcontains $out){
                            Write-Output $out
                            $commandsOutputted += $out
                        }
                    }
                }
                else{
                      Write-Output $minCommand         
                }
            }
		}
		
		catch {
            throw $error[0]
		}
	}
	END {
	}
}