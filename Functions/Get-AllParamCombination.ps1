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
			ValuefromPipelineByPropertyName = $true)]
		[System.String]$Name,

		[Parameter(
			ValuefromPipelineByPropertyName = $true)]
		[Switch]$ExcludeBadAzureParameters,

		[Parameter(
			ValuefromPipelineByPropertyName = $true)]
		[String[]]$FakeMandatoryParameterName,

		[Parameter(
			ValuefromPipelineByPropertyName = $true)]
		[String[]]$ExcludeParameters,

		[Parameter(
			ValuefromPipeline = $true
		)]
		[PSObject[]]$FakeParameterSet
	)
	
	begin {
		Set-StrictMode -Version Latest
		$expandedParams = $null
		$PSBoundParameters.GetEnumerator() | ForEach-Object { $expandedParams += ' -' + $_.key + ' '; $expandedParams += $_.value }
		Write-Verbose "Starting: $($MyInvocation.MyCommand.Name)$expandedParams"

		$advancedParams = 'Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'ProgressAction', 'InformationAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable', 'Confirm'
		if ($ExcludeBadAzureParameters) {
			$badAzureParameters = 'Break', 'HttpPipelineAppend', 'HttpPipelinePrepend', 'NoWait', 'Proxy', 'ProxyCredential', 'ProxyUseDefaultCredentials'
			$advancedParams += $badAzureParameters
		}
		$advancedParams += $ExcludeParameters
	}
	
	process {

		$argumentCompleter = Get-Content 'D:\GitHub\Pester.SessionHostUpdate\FakeParamSetData\parameterValues.json' | ConvertFrom-Json
		try {
			$functionData = Get-Command $Name -ErrorAction Stop
		}
		catch {
			Write-Error "Can not find command $name"
		}

		$sets = $functionData.ParameterSets
		foreach ($fakeSet in $FakeParameterSet) {
			$sets += $fakeSet
		}
		$mandatoryParams = $null
		$optionalParams = $null
		foreach ($set in $sets) {
			$setName = $set.Name
			$params = $set.Parameters | Where-Object { $_.Name -notin $advancedParams }

			$mandatoryParams = $params | Where-Object { $_.IsMandatory -eq $true }

			$optionalParams = $params | Where-Object { $_.IsMandatory -ne $true }

			$mandatoryString = $null

			foreach ($param in $mandatoryParams) {

				$paramString = ' -' + $param.Name + ' ' + '$' + $param.Name
				$mandatoryString += $paramString

			}

			$outputMinMandatoryCommand = $true
			
			foreach ($param in $mandatoryParams) {

				if ($param.ParameterType.ToString() -notlike "*Microsoft.Azure.PowerShell.Cmdlets.DesktopVirtualization.Support*" ) {
					continue
				}
				$outputMandatory = [PSCustomObject]@{
					PSTypeName       = 'Param.Info'
					ParameterSetName = $setName 
					ParameterName    = $param.Name
					ParameterValues  = $argumentCompleter | Where-Object Name -eq $param.Name | Select-Object -ExpandProperty Values
					Invocation       = $Name + $mandatoryString
				}

				Write-Output $outputMandatory
				$outputMinMandatoryCommand = $false
			}

			if ($outputMinMandatoryCommand) {
				$outputMinMandatory = [PSCustomObject]@{
					PSTypeName       = 'Param.Info'
					ParameterSetName = $setName
					ParameterName    = 'MinumimMandatory'
					ParameterValues  = $null
					Invocation       = $Name + $mandatoryString
				}

				Write-Output $outputMinMandatory
				$outputMinMandatoryCommand = $false
			}

			$optionalAll = $null

			foreach ($optionalParam in $optionalParams) {
				$parameterValues = $null
				if ($optionalParam.ParameterType.Name -eq 'SwitchParameter') {
					$parameterData = $null
				}
				else {
					$parameterData = ' $' + $optionalParam.Name
				}

				if ($optionalParam.ParameterType.ToString() -like "*Microsoft.Azure.PowerShell.Cmdlets.DesktopVirtualization.Support*" ) {
					$parameterValues = $argumentCompleter | Where-Object Name -eq $optionalparam.Name | Select-Object -ExpandProperty Values
				}
				else {
					$parameterValues = $null
				}

				$optionalDetail = ' -' + $optionalParam.Name + $parameterData

				if ($optionalParam.Name -notin 'WhatIf', 'AsJob') {
					$optionalAll += $optionalDetail
				}

				$outputOptional = [PSCustomObject]@{
					PSTypeName       = 'Param.Info'
					ParameterSetName = $setName
					ParameterName    = $optionalParam.Name
					ParameterValues  = $parameterValues
					Invocation       = $Name + $mandatoryString + $optionalDetail
				}

				Write-Output $outputOptional
				
			}
			$outputOptionalAll = [PSCustomObject]@{
				PSTypeName       = 'Param.Info'
				ParameterSetName = $setName
				ParameterName    = 'AllOptional'
				ParameterValues  = $null
				Invocation       = $Name + $mandatoryString + $optionalAll
			}

			Write-Output $outputOptionalAll
			Write-Information 'Done'
		}
	}
	end {}
}