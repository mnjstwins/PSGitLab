Function GetMethodParameters {
# PSScript Analyzer misses the variables used by the escapedatastring method. 
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
[cmdletbinding()]
param(
    $GetURLParameters
)

$string = '?'
foreach ($Param in $GetUrlParameters) {
    $Param.Keys | ForEach-Object {
        $key = $_
        $value = $Param[$_]
    }
    $string += "&"
    $string += [uri]::EscapeDataString($key)
    $string += "="
    $string += [uri]::EscapeDataString($value)
}
$string = $string -replace '\?&','?'
Write-Output $string
}
