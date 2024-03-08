function Get-ParameterTypeList {
    [CmdletBinding()]

    Param (
        [Parameter(
            Position = 0,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [System.String]$FunctionName,

        [Parameter(
			ValuefromPipelineByPropertyName = $true)]
		[Switch]$ExcludeBadAzureParameters,
    
        [Parameter(
            ValuefromPipeline = $true

        )]
        [String]$OutPath
    )

    begin {
        Set-StrictMode -Version Latest
    } # begin
    process {
        $functionData = Get-Command $FunctionName -ErrorAction Stop

        $advancedParams = 'Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'ProgressAction', 'InformationAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable', 'Confirm'

        if ($ExcludeBadAzureParameters) {
			$badAzureParameters = 'Break', 'HttpPipelineAppend', 'HttpPipelinePrepend', 'NoWait', 'Proxy', 'ProxyCredential', 'ProxyUseDefaultCredentials'
			$advancedParams += $badAzureParameters
		}
        
        $sets = $functionData.ParameterSets

        foreach ($set in $Sets){
            $setName = $set.Name
            $params = $set.Parameters | Where-Object { $_.Name -notin $advancedParams }
    
            $mandatoryParams = $params | Where-Object { $_.IsMandatory -eq $true }
    
            $optionalParams = $params | Where-Object { $_.IsMandatory -ne $true }

            Set-Content -Path ($setName + 'Mandatory.txt') -Value $mandatoryParams.Name

            Set-Content -Path ($setName + 'Optional.txt') -Value $optionalParams.Name

        }


    } # process
    end {} # end
}  #function

Get-ParameterTypeList -FunctionName 'Get-AzWvdSessionHostManagementsOperationStatus' -ExcludeBadAzureParameters