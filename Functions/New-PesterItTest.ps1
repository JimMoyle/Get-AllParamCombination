function New-PesterItTest {
    [CmdletBinding()]

    Param (
        [Parameter(
            Position = 0,
            ParameterSetName = 'MyParameterSetName',
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [System.String]$ParameterValuesPath,
    
        [Parameter(
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [PSTypeName('Param.Info')]$InputObject
    )

    begin {
        Set-StrictMode -Version Latest
        Remove-Item -Path env:currentParameterset -ErrorAction SilentlyContinue

    } # begin
    process {
        $contextBegin = "
        Context `"Testing parameter Set $($InputObject.ParameterSetName)`" {
            BeforeAll {}
            BeforeEach {}
            AfterAll {}
            AfterEach {}"

        if (($env:currentParameterset | Measure-Object).Count -eq 0){           
            Write-Output $contextBegin
			Set-Item -Path env:currentParameterset -Value $InputObject.ParameterSetName
		}

        if ($env:currentParameterset -ne $InputObject.ParameterSetName) {
            Write-Output '}
            '
            Write-Output $contextBegin
            Set-Item -Path env:currentParameterset -Value $InputObject.ParameterSetName
        }

        $cmdLine = $InputObject.Invocation + ' -ErrorAction Stop'

        $parameterValues = Get-Content $ParameterValuesPath | ConvertFrom-Json

        #TODO: Get rid of Elseifs and replace with switch with inputs from new parameters.

        if ($ParameterValues.Name -contains $InputObject.ParameterName) {
            $newCmdLine = $cmdLine.Replace('$' + $($InputObject.ParameterName), '$_')

            $possibleValues = ($ParameterValues | Where-Object { $_.Name -eq $InputObject.ParameterName } | Select-Object -ExpandProperty Values) -join ', '
            
            $output = "
            It `'Testing parameter $($InputObject.ParameterName) from $($InputObject.ParameterSetName) with value <_>`' -ForEach $possibleValues {
                $newCmdLine
                (Get-AzWvdSessionHostManagement -HostPoolName `$HostPoolName -ResourceGroupName `$ResourceGroupName).$($InputObject.ParameterName) | Should -Be `$_
            }"
        }
        elseif ($InputObject.ParameterName -eq 'AllOptional' -or $InputObject.ParameterName -eq 'SubscriptionId' -or $InputObject.ParameterName -eq 'MinumimMandatory') {
            $output = "
            It `'Testing parameter $($InputObject.ParameterName) from $($InputObject.ParameterSetName)`' {
            $cmdLine
            (Get-AzWvdSessionHostManagement -HostPoolName `$HostPoolName -ResourceGroupName `$ResourceGroupName).ProvisioningState | Should -Be `'Default`'
            }"
        }
        elseif ($InputObject.ParameterName -eq 'WhatIf' -or $InputObject.ParameterName -eq 'AsJob' ) {
            $output = "
            It `'Testing parameter $($InputObject.ParameterName) from $($InputObject.ParameterSetName)`' {
            $cmdLine
            }"
        }
        else {
            $output = "
            It `'Testing parameter $($InputObject.ParameterName) from $($InputObject.ParameterSetName)`' {
            $cmdLine
            (Get-AzWvdSessionHostManagement -HostPoolName `$HostPoolName -ResourceGroupName `$ResourceGroupName).$($InputObject.ParameterName) | Should -Be `$$($InputObject.ParameterName)
            }"
        }

        Write-Output $output

    } # process
    end {
        Write-Output '}'
    } # end
}  #function