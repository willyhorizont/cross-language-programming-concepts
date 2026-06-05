$MultiplierAa = { param($x, $y) $x * $y }

&$MultiplierAa 5 4
$MultiplierAa.Invoke(5, 4)

$Numbers = 1..10
$EvenNumbers = $Numbers | Where-Object { $Args[0] % 2 -eq 0 }

$MultiplierBb = {
    $result = 1
    foreach ($num in $Args) {
        $result *= $num
    }
    return $result
}

&$MultiplierBb 5 4
&$MultiplierBb 2 +3 4 5
$MultiplierBb.Invoke(3, 3, 3)

$MultiplierCc = { $Args | ForEach-Object { $total = 1 } { $total *= $_ } { $total } }

$MySum = { ($Args | Measure-Object -Sum).Sum }

&$MySum 10 20 30 40

$Greeter = { "Halo, $($Args[0])!" }
&$Greeter "Budi" "Andi" "Siti"

$GetFirstEvent = {
    $evenNumbers = foreach ($num in $Args) {
        if ($num % 2 -eq 0) { $num }
    }

    $firstEven = $evenNumbers[0]

    return $firstEven
}

$Result = &$GetFirstEvent 1 3 4 7 8 10
Write-Host "First Even: $Result"

$ProcessData = {
    param(
        $FirstItem,
        
        [Parameter(ValueFromRemainingArguments = $true)]
        $RestItems
    )

    Write-Host "FirstItem: $FirstItem"
    Write-Host "RestArguments: $($RestItems -join ', ')"
}

&$ProcessData "Apple" "Banana" "Mango"
# Output:
# FirstItem: Apple
# RestArguments: Banana, Mango

$Logger = {
    $Prefix = $Args[0]

    $RestArguments = $Args[1..($Args.Count - 1)]

    Write-Host "[$Prefix]" @RestArguments
}

&$Logger "INFO" "Server" "successfully" "running"
# Output: [INFO] Server successfully running
