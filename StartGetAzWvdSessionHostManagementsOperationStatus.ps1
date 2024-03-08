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

$cmdletName = 'Get-AzWvdSessionHostManagementsOperationStatus'

#$fakeMandatoryPlace = (Get-Content 'D:\GitHub\Pester.SessionHostUpdate\FakeParamSetData\MandatoryParameters.txt')
#$fakeMarketPlace = $fakeMandatoryPlace + (Get-Content 'D:\GitHub\Pester.SessionHostUpdate\FakeParamSetData\FakeMarketPlace.txt')
#$fakeCustomImage = $fakeMandatoryPlace + (Get-Content 'D:\GitHub\Pester.SessionHostUpdate\FakeParamSetData\FakeCustomImage.txt')
#$fakeActiveDirectory = $fakeMandatoryPlace + (Get-Content 'D:\GitHub\Pester.SessionHostUpdate\FakeParamSetData\FakeActiveDirectory.txt')
#$OptionalParameters = (Get-Content 'D:\GitHub\Pester.SessionHostUpdate\FakeParamSetData\OptionalParameters.txt')

#$fakeMarketPlaceSet = New-FakeParameterSet -Name 'FakeMarketplace' -functionName $cmdletName -ParametersInSet $fakeMarketPlace -OptionalParameters $OptionalParameters

#$fakeCustomImageSet = New-FakeParameterSet -Name 'FakeCustomImage' -functionName $cmdletName -ParametersInSet $fakeCustomImage -OptionalParameters $OptionalParameters

#$fakeActiveDirectorySet = New-FakeParameterSet -Name 'FakeActiveDirectory' -functionName $cmdletName -ParametersInSet $fakeActiveDirectory -OptionalParameters $OptionalParameters

$parameterValuesPath = 'D:\GitHub\Pester.SessionHostUpdate\FakeParamSetData\parameterValues.json' 
# -FakeParameterSet $fakeMarketPlaceSet, $fakeCustomImageSet, $fakeActiveDirectorySet 
Get-AllParamCombination -Name $cmdletName -ExcludeBadAzureParameters -ExcludeParameters DefaultProfile | New-PesterItTest -ParameterValues $parameterValuesPath | Out-File ($cmdletName + '.txt')