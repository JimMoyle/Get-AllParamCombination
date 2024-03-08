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

$cmdletName = 'New-AzWvdSessionHostManagement'

Get-AllParamCombination -Name $cmdletName -ExcludeBadAzureParameters -ExcludeParameters DefaultProfile | New-PesterItTest -ParameterValues $parameterValuesPath | Out-File ($cmdletName + '.txt')