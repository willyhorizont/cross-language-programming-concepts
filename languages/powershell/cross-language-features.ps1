<#
1. support function as value
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
$CreateMultiplier = { param($a) { param($b) ($a * $b) }.GetNewClosure() }
$MultiplyByTwo = &$CreateMultiplier 2
Write-Host "MultiplyByTwo 10: $(&$MultiplyByTwo 10)"
$MultiplyByEight = &$CreateMultiplier 8
Write-Host "MultiplyByEight 4: $(&$MultiplyByEight 4)"
Write-Host "MultiplyByTwo 8: $(&$MultiplyByTwo 8)"

<#
2. support dynamic-typed value, or has workaround
#>
$SomePythonLikeList = @(
    $null,
    $true,
    $false,
    "foo",
    123,
    -123,
    123.789,
    -123.789,
    @(1, 2, 3),
    @{ "foo" = "bar"; },
    { param($a, $b) ($a * $b) }
)
Write-Host "SomePythonLikeList: $($SomePythonLikeList | ConvertTo-Json)"
$SomePythonLikeDict = @{
    "some_null" = $null;
    "some_boolean_true" = $true;
    "some_boolean_false" = $false;
    "some_string" = "foo";
    "some_int_positive" = 123;
    "some_int_negative" = -123;
    "some_float_positive" = 123.789;
    "some_float_negative" = -123.789;
    "some_python_like_list" = @(1, 2, 3);
    "some_python_like_dict" = @{ "foo" = "bar" };
    "some_function" = { param($a, $b) ($a * $b) }
}
Write-Host "SomePythonLikeDict: $($SomePythonLikeDict | ConvertTo-Json)"
