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
        [System.String]$StringVar,
    
        [Parameter(
            ParameterSetName = 'InputObject',
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [PSTypeName('Param.Info')]$InputObject
    )

    begin {
        Set-StrictMode -Version Latest
    } # begin
    process {

        $cmdLine = $InputObject.Invocation + ' -ErrorAction Stop'

        Write-Output "
        It `'Testing parameter $($InputObject.ParameterName)`' {
            $cmdLine
        }
        "
        
    } # process
    end {} # end
}  #function