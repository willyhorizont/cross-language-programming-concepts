Class Xl {
    Static [String] EscapeString([String]$S) {
        If ([String]::IsNullOrEmpty($S)) { Return "" }
        Return $S.Replace('\', '\\')
            .Replace('"', '\"')
            .Replace("`n", '\n')
            .Replace("`r", '\r')
            .Replace("`t", '\t')
    }
    Static [String] JsonStringify($A, [System.Collections.IDictionary]$O = @{}) {
        $P = If ($O.ContainsKey("Pretty")) { [Bool]$O["Pretty"] } Else { $False }
        $T = " " * 4
        $S = [System.Collections.Generic.Stack[Object]]::New()
        $S.Push([PSCustomObject]@{ "t" = "v"; "v" = $A; "d" = 0 })
        $R = ""
        While ($S.Count -GT 0) {
            $C = $S.Pop()
            If ($C."t" -EQ "r") {
                $R += $C."v"
                Continue
            }
            $V = $C."v"
            $CurD = $C."d"
            If ($Null -EQ $V) {
                $R += "null"
                Continue
            }
            If ($V -Is [Bool]) {
                $R += If ($V) { "true" } Else { "false" }
                Continue
            }
            If ($V -Is [String]) {
                $R += """" + [Xl]::EscapeString($V) + """"
                Continue
            }
            If ($V -Is [Int] -Or $V -Is [Double] -Or $V -Is [Decimal] -Or $V -Is [Long] -Or $V -Is [Float]) {
                $R += $V.ToString()
                Continue
            }
            If ($V -Is [ScriptBlock]) {
                $R += """[Object Function]"""
                Continue
            }
            If ($V -Is [System.Collections.IList] -And $V -IsNot [System.Collections.IDictionary]) {
                If ($V.Count -EQ 0) {
                    $R += "[]"
                    Continue
                }
                $ChildD = $CurD + 1
                $S.Push([PSCustomObject]@{
                    "t" = "r";
                    "v" = If ($P) { "`n" + ($T * $CurD) + "]" } Else { "]" };
                    "d" = $CurD;
                })
                For ($I = $V.Count - 1; $I -GE 0; $I--) {
                    $S.Push([PSCustomObject]@{
                        "t" = "v";
                        "v" = $V[$I];
                        "d" = $ChildD;
                    })
                    If ($I -GT 0) {
                        $S.Push([PSCustomObject]@{
                            "t" = "r";
                            "v" = If ($P) { ",`n" + ($T * $ChildD) } Else { "," };
                            "d" = $ChildD;
                        })
                    }
                }
                $S.Push([PSCustomObject]@{
                    "t" = "r";
                    "v" = If ($P) { "[`n" + ($T * $ChildD) } Else { "[" };
                    "d" = $ChildD;
                })
                Continue
            }
            If ($V -Is [System.Collections.IDictionary] -Or $V -Is [PSCustomObject] -Or $V.GetType().IsClass) {
                $Dpl = @()
                If ($V -Is [System.Collections.IDictionary]) {
                    ForEach ($Dplelk In $V.Keys) {
                        $Dpl += ,@($Dplelk, $V[$Dplelk])
                    }
                } ElseIf ($V -Is [PSCustomObject]) {
                    ForEach ($D In $V.PSObject.Properties) {
                        $Dpl += ,@($D.Name, $D.Value)
                    }
                } Else {
                    ForEach ($D In $V.GetType().GetProperties()) {
                        $Dpl += ,@($D.Name, $D.GetValue($V))
                    }
                }
                If ($Dpl.Count -EQ 0) {
                    $R += "{}"
                    Continue
                }
                $ChildD = $CurD + 1
                $S.Push([PSCustomObject]@{
                    "t" = "r";
                    "v" = If ($P) { "`n" + ($T * $CurD) + "}" } Else { "}" };
                    "d" = $CurD;
                })
                For ($I = $Dpl.Count - 1; $I -GE 0; $I -= 1) {
                    $PK = $Dpl[$I][0]
                    $PV = $Dpl[$I][1]
                    $S.Push([PSCustomObject]@{
                        "t" = "v";
                        "v" = $PV;
                        "d" = $ChildD;
                    })
                    $S.Push([PSCustomObject]@{
                        "t" = "r";
                        "v" = If ($P) { """" + $PK + """: " } Else { """" + $PK + """:" };
                        "d" = $ChildD;
                    })
                    If ($I -GT 0) {
                        $S.Push([PSCustomObject]@{
                            "t" = "r";
                            "v" = If ($P) { ",`n" + ($T * $ChildD) } Else { "," };
                            "d" = $ChildD;
                        })
                    }
                }
                $S.Push([PSCustomObject]@{
                    "t" = "r";
                    "v" = If ($P) { "{`n" + ($T * $ChildD) } Else { "{" };
                    "d" = $ChildD
                })
                Continue
            }
            $R += """[Object [""""" + $V.GetType().Name + """""]]"""
        }
        Return $R
    }
    Static [String] JsonStringify($A) {
        Return [Xl]::JsonStringify($A, @{})
    }
}
