$Functions = @( Get-ChildItem -Path Functions\*.ps1 -ErrorAction SilentlyContinue )

Foreach ($import in $Functions) {
    Try {
        Write-Information "Importing $($Import.FullName)"
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

$fakeMandatoryPlace = (Get-Content 'D:\GitHub\Pester.SessionHostUpdate\FakeParamSetData\New-AzWvdSessionHostConfig\MandatoryParameters.txt')
$fakeMarketPlace = $fakeMandatoryPlace + (Get-Content 'D:\GitHub\Pester.SessionHostUpdate\FakeParamSetDataNew-AzWvdSessionHostConfig\\FakeMarketPlace.txt')
$fakeCustomImage = $fakeMandatoryPlace + (Get-Content 'D:\GitHub\Pester.SessionHostUpdate\FakeParamSetData\New-AzWvdSessionHostConfig\FakeCustomImage.txt')
$fakeActiveDirectory = $fakeMandatoryPlace + (Get-Content 'D:\GitHub\Pester.SessionHostUpdate\FakeParamSetData\New-AzWvdSessionHostConfig\FakeActiveDirectory.txt')
$OptionalParameters = (Get-Content 'D:\GitHub\Pester.SessionHostUpdate\FakeParamSetData\New-AzWvdSessionHostConfig\OptionalParameters.txt')

$fakeMarketPlaceSet = New-FakeParameterSet -Name 'FakeMarketplace' -functionName 'New-AzWvdSessionHostConfiguration' -ParametersInSet $fakeMarketPlace -OptionalParameters $OptionalParameters

$fakeCustomImageSet = New-FakeParameterSet -Name 'FakeCustomImage' -functionName 'New-AzWvdSessionHostConfiguration' -ParametersInSet $fakeCustomImage -OptionalParameters $OptionalParameters

$fakeActiveDirectorySet = New-FakeParameterSet -Name 'FakeActiveDirectory' -functionName 'New-AzWvdSessionHostConfiguration' -ParametersInSet $fakeActiveDirectory -OptionalParameters $OptionalParameters

$parameterValuesPath = 'D:\GitHub\Pester.SessionHostUpdate\FakeParamSetData\parameterValues.json'

Get-AllParamCombination -Name 'Update-AzWvdSessionHostConfiguration' -ExcludeBadAzureParameters -FakeParameterSet $fakeMarketPlaceSet, $fakeCustomImageSet, $fakeActiveDirectorySet -ExcludeParameters DefaultProfile | New-PesterItTest -ParameterValues $parameterValuesPath | Out-File 'New-AzWvdSessionHostConfiguration.txt'