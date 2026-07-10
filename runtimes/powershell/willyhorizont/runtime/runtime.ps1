class Xl {
    static [string] JsonStringify($A, [System.Collections.IDictionary]$O = @{}) {
        $P = if ($O.ContainsKey("Pretty")) { [bool]$O["Pretty"] } else { $false }
        $T = " " * 4
        $S = [System.Collections.Generic.Stack[object]]::new()
        $S.Push([PSCustomObject]@{ "t" = "v"; "v" = $A; "d" = 0 })
        $R = ""
        while ($S.Count -gt 0) {
            $C = $S.Pop()
            if ($C."t" -eq "r") {
                $R += $C."v"
                continue
            }
            $V = $C."v"
            $CurD = $C."d"
            if ($null -eq $V) {
                $R += "null"
                continue
            }
            if ($V -is [bool]) {
                $R += if ($V) { "true" } else { "false" }
                continue
            }
            if ($V -is [string]) {
                $R += """" + $V + """"
                continue
            }
            if ($V -is [int] -or $V -is [double] -or $V -is [decimal] -or $V -is [long] -or $V -is [float]) {
                $R += $V.ToString()
                continue
            }
            if ($V -is [scriptblock]) {
                $R += """[object Function]"""
                continue
            }
            if ($V -is [System.Collections.IList] -and $V -isnot [System.Collections.IDictionary]) {
                if ($V.Count -eq 0) {
                    $R += "[]"
                    continue
                }
                $ChildD = $CurD + 1
                $S.Push([PSCustomObject]@{
                    "t" = "r";
                    "v" = if ($P) { "`n" + ($T * $CurD) + "]" } else { "]" };
                    "d" = $CurD;
                })
                for ($I = $V.Count - 1; $I -ge 0; $I--) {
                    $S.Push([PSCustomObject]@{
                        "t" = "v";
                        "v" = $V[$I];
                        "d" = $ChildD;
                    })
                    if ($I -gt 0) {
                        $S.Push([PSCustomObject]@{
                            "t" = "r";
                            "v" = if ($P) { ",`n" + ($T * $ChildD) } else { "," };
                            "d" = $ChildD;
                        })
                    }
                }
                $S.Push([PSCustomObject]@{
                    "t" = "r";
                    "v" = if ($P) { "[`n" + ($T * $ChildD) } else { "[" };
                    "d" = $ChildD;
                })
                continue
            }
            if ($V -is [System.Collections.IDictionary] -or $V -is [PSCustomObject] -or $V.GetType().IsClass) {
                $Dpl = @()
                if ($V -is [System.Collections.IDictionary]) {
                    foreach ($Dplelk in $V.Keys) {
                        $Dpl += ,@($Dplelk, $V[$Dplelk])
                    }
                } elseif ($V -is [PSCustomObject]) {
                    foreach ($D in $V.PSObject.Properties) {
                        $Dpl += ,@($D.Name, $D.Value)
                    }
                } else {
                    foreach ($D in $V.GetType().GetProperties()) {
                        $Dpl += ,@($D.Name, $D.GetValue($V))
                    }
                }
                if ($Dpl.Count -eq 0) {
                    $R += "{}"
                    continue
                }
                $ChildD = $CurD + 1
                $S.Push([PSCustomObject]@{
                    "t" = "r";
                    "v" = if ($P) { "`n" + ($T * $CurD) + "}" } else { "}" };
                    "d" = $CurD;
                })
                for ($I = $Dpl.Count - 1; $I -ge 0; $I -= 1) {
                    $dK = $Dpl[$I][0]
                    $dV = $Dpl[$I][1]
                    $S.Push([PSCustomObject]@{
                        "t" = "v";
                        "v" = $dV;
                        "d" = $ChildD;
                    })
                    $S.Push([PSCustomObject]@{
                        "t" = "r";
                        "v" = if ($P) { """" + $dK + """: " } else { """" + $dK + """:" };
                        "d" = $ChildD;
                    })
                    if ($I -gt 0) {
                        $S.Push([PSCustomObject]@{
                            "t" = "r";
                            "v" = if ($P) { ",`n" + ($T * $ChildD) } else { "," };
                            "d" = $ChildD;
                        })
                    }
                }
                $S.Push([PSCustomObject]@{
                    "t" = "r";
                    "v" = if ($P) { "{`n" + ($T * $ChildD) } else { "{" };
                    "d" = $ChildD
                })
                continue
            }
            $R += """[object [""""" + $V.GetType().Name + """""]]"""
        }
        return $R
    }
    static [string] JsonStringify($A) {
        return [Xl]::JsonStringify($A, @{})
    }
}
