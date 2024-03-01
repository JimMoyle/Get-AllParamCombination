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
			Mandatory = $true,
			ValuefromPipeline = $true,
			ValuefromPipelineByPropertyName = $true)]
		[System.String]$Name,

		[Parameter(
			ValuefromPipelineByPropertyName = $true)]
		[Switch]$ExcludeBadAzureParameters,

		[Parameter(
			ValuefromPipelineByPropertyName = $true)]
		[Switch]$WriteItBlock,

		[Parameter(
			ValuefromPipelineByPropertyName = $true)]
		[String[]]$FakeMandatoryParameterName
	)
	
	begin {
		Set-StrictMode -Version Latest
		$expandedParams = $null
		$PSBoundParameters.GetEnumerator() | ForEach-Object { $expandedParams += ' -' + $_.key + ' '; $expandedParams += $_.value }
		Write-Verbose "Starting: $($MyInvocation.MyCommand.Name)$expandedParams"

		$advancedParams = 'Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'InformationAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable', 'Confirm'
		if ($ExcludeBadAzureParameters) {
			$badAzureParameters = 'Break', 'HttpPipelineAppend', 'HttpPipelinePrepend', 'NoWait', 'Proxy', 'ProxyCredential', 'ProxyUseDefaultCredentials'
			$advancedParams += $badAzureParameters
		}
		#. .\Functions\Get-Combination.ps1

	}
	
	process {
		try {
			$functionData = Get-Command $Name -ErrorAction Stop
		}
		catch {
			Write-Error "Can not find command $name"
		}

		foreach ($set in $functionData.ParameterSets) {
			$params = $set.Parameters | Where-Object { $_.Name -notin $advancedParams }

			$mandatoryParams = $params | Where-Object { $_.IsMandatory -eq $true -or $_.Name -in $FakeMandatoryParameterName }

			$optionalParams = $params | Where-Object { $_.IsMandatory -ne $true -and $_.Name -notin $FakeMandatoryParameterName }

			$mandatoryString = $null

			foreach ($param in $mandatoryParams) {

				$paramString = ' -' + $param.Name + ' ' + '$' + $param.Name
				$mandatoryString += $paramString

			}

			$outputMinMandatoryCommand = $true
			
			foreach ($param in $mandatoryParams) {

				if ($param.ParameterType.ToString() -notlike "*Microsoft.Azure.PowerShell.Cmdlets.DesktopVirtualization*" ) {
					continue
				}
				$outputMandatory = [PSCustomObject]@{
					PSTypeName      = 'Param.Info'
					ParameterName   = $param.Name
					ParameterValues = $param.ParameterType.DeclaredFields.Name | Select-Object -Skip 1
					Invocation      = $Name + $mandatoryString

				}

				Write-Output $outputMandatory
				$outputMinMandatoryCommand = $false
			}

			if ($outputMinMandatoryCommand) {
				$outputMinMandatory = [PSCustomObject]@{
					PSTypeName      = 'Param.Info'
					ParameterName   = $null
					ParameterValues = $null
					Invocation      = $Name + $mandatoryString
				}

				Write-Output $outputMinMandatory
				$outputMinMandatoryCommand = $false
			}

			foreach ($optionalParam in $optionalParams) {
				$parameterValues = $null
				if ($optionalParam.ParameterType.Name -eq 'SwitchParameter') {
					$parameterData = $null
				}
				else {
					$parameterData = ' $' + $optionalParam.Name
				}

				if ($optionalParam.ParameterType.ToString() -like "*Microsoft.Azure.PowerShell.Cmdlets.DesktopVirtualization*" ) {
					$parameterValues = $optionalParam.ParameterType.DeclaredFields.Name | Select-Object -Skip 1
				}
				else {
					$parameterValues = $null
				}

				$outputOptional = [PSCustomObject]@{
					PSTypeName      = 'Param.Info'
					ParameterName   = $optionalParam.Name
					ParameterValues = $parameterValues
					Invocation      = $Name + $mandatoryString + ' -' + $optionalParam.Name + $parameterData
				}

				Write-Output $outputOptional
				Write-Information 'Done'
			}
		}
	}
	end {}
}


'New-AzWvdSessionHostConfiguration' | Get-AllParamCombination -ExcludeBadAzureParameters | New-PesterItTest