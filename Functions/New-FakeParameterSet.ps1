function New-FakeParameterSet {
    [CmdletBinding()]

    Param (
        [Parameter(
            Position = 0,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [System.String]$Name,

        [Parameter(
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [String]$functionName,
    
        [Parameter(
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [String[]]$ParametersInSet,

        [Parameter(
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [String[]]$OptionalParameters       
    )

    begin {
        Set-StrictMode -Version Latest
    } # begin
    process {

        $functionData = Get-Command $functionName

        $fakeMandatoryParametesInSet = Foreach ($parameter in $ParametersInSet) {
            $paramData = $functionData.parameters.GetEnumerator() | Where-Object {$_.Key -eq $parameter} | Select-Object -ExpandProperty Value
            $paramData | Add-Member -MemberType NoteProperty -Name 'IsMandatory' -Value $true
            Write-Output $paramData
        }

        $fakeOptionalParametersInSet = Foreach ($parameter in $OptionalParameters) {
            if ($fakeMandatoryParametesInSet.Name -contains $parameter){
                continue
            }
            $paramData = $functionData.parameters.GetEnumerator() | Where-Object {$_.Key -eq $parameter} | Select-Object -ExpandProperty Value
            $paramData | Add-Member -MemberType NoteProperty -Name 'IsMandatory' -Value $false
            Write-Output $paramData
        }

        $fakeParametersInSet = $fakeMandatoryParametesInSet
        $fakeParametersInSet += $fakeOptionalParametersInSet

        $output = [PSCustomObject]@{
            PSTypeName = 'Param.FakeParameterSet'
            Name       = $name
            IsDefault  = $false
            IsFake     = $true
            Parameters = $fakeParametersInSet
        }
        Write-Output $output
    } # process
    end {} # end
}  #function


