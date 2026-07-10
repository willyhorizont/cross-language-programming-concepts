. (Join-Path $PSScriptRoot "..\..\runtimes\powershell\willyhorizont\runtime\runtime.ps1")

<#
1. support closure as value, or has workaround
#>
$SayHello = {
    param($CallbackFunction)
    Write-Host "hello"
    &$CallbackFunction
}
&$SayHello {
    param()
    Write-Host "world"
}
$CreateMultiplier = { param($Aa) { param($Bb) ($Aa * $Bb) }.GetNewClosure() }
$MultiplyByTwo = &$CreateMultiplier 2
Write-Host "multiply_by_two(10): $(&$MultiplyByTwo 10)"
$MultiplyByEight = &$CreateMultiplier 8
Write-Host "multiply_by_eight(4): $(&$MultiplyByEight 4)"
Write-Host "multiply_by_two(8): $(&$MultiplyByTwo 8)"

<#
2. support dynamic-typed value, or has workaround
#>
$XlList = @(
    $null,
    $true,
    $false,
    "foo",
    0,
    -123,
    123.789,
    -123.789,
    @(1, 2, 3),
    @{ "foo" = "bar"; },
    { param($Aa, $Bb) ($Aa * $Bb) }
)
Write-Host "xl_list: $([Xl]::JsonStringify($XlList))"
Write-Host "xl_list: $([Xl]::JsonStringify($XlList, @{ Pretty = $true }))"
$XlDict = @{
    "xl_none" = $null;
    "xl_bool_true" = $true;
    "xl_bool_false" = $false;
    "xl_string" = "foo";
    "xl_int_positive" = 0;
    "xl_int_negative" = -123;
    "xl_float_positive" = 123.789;
    "xl_float_negative" = -123.789;
    "xl_list" = @(1, 2, 3);
    "xl_dict" = @{ "foo" = "bar" };
    "xl_closure" = { param($Aa, $Bb) ($Aa * $Bb) }
}
Write-Host "xl_dict: $([Xl]::JsonStringify($XlDict))"
Write-Host "xl_dict: $([Xl]::JsonStringify($XlDict, @{ Pretty = $true }))"
