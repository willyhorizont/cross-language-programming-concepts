Imports System
Imports System.Collections.Generic
Imports System.Linq
Imports WillyHorizont.Runtime.Xl

Module Program
    Sub Main()
        ' 1. support lambda as value, or has workaround
        Dim SayHello As Object = New Xl.Lambda(Function(Va)
            Dim Itr As Object = Xl.Iter(Va)
            Dim CallbackFunction As Object = Xl.NextItem(Itr)
            Console.WriteLine("hello")
            CallbackFunction.Invoke()
        End Function)
        SayHello.Invoke(New Xl.Lambda(Function(Va)
            Console.WriteLine("world")
        End Function))
        Dim CreateMultiplier As Object = New Xl.Lambda(Function(VaAa)
            Dim ItrAa As Object = Xl.Iter(VaAa)
            Dim Aa As Object = Xl.NextItem(ItrAa)
            Return New Xl.Lambda(Function(VaBb)
                Dim ItrBb As Object = Xl.Iter(VaBb)
                Dim Bb As Object = Xl.NextItem(ItrBb)
                Return Aa * Bb
            End Function)
        End Function)
        Dim MultiplyByTwo As Object = CreateMultiplier.Invoke(2)
        Console.WriteLine($"multiply_by_two(10): {MultiplyByTwo.Invoke(10)}")
        Dim MultiplyByEight As Object = CreateMultiplier.Invoke(8)
        Console.WriteLine($"multiply_by_eight(4): {MultiplyByEight.Invoke(4)}")
        Console.WriteLine($"multiply_by_two(8): {MultiplyByTwo.Invoke(8)}")

        ' 2. support dynamic-typed value, or has workaround
        Dim XlList As Object = New Xl.List From {
            Nothing,
            True,
            False,
            "foo",
            0,
            -123,
            123.789,
            -123.789,
            New Xl.List From {1, 2, 3},
            New Xl.Dict From { { "foo", "bar" } },
            New Xl.Lambda(Function(Va)
                Dim Itr As Object = Xl.Iter(Va)
                Dim Aa As Object = Xl.NextItem(Itr)
                Dim Bb As Object = Xl.NextItem(Itr)
                Return Aa * Bb
            End Function)
        }
        Console.WriteLine($"xl_list: {Xl.JsonStringify(XlList)}")
        Console.WriteLine($"xl_list: {Xl.JsonStringify(XlList, Pretty:=True)}")
        Dim XlDict As Object = New Xl.Dict From {
            { "xl_none", Nothing },
            { "xl_bool_true", True },
            { "xl_bool_false", False },
            { "xl_string", "foo" },
            { "xl_int_positive", 0 },
            { "xl_int_negative", -123 },
            { "xl_float_positive", 123.789 },
            { "xl_float_negative", -123.789 },
            { "xl_list", New Xl.List From {1, 2, 3} },
            { "xl_dict", New Xl.Dict From { { "foo", "bar" } } },
            { "xl_lambda", New Xl.Lambda(Function(Va)
                Dim Itr As Object = Xl.Iter(Va)
                Dim Aa As Object = Xl.NextItem(Itr)
                Dim Bb As Object = Xl.NextItem(Itr)
                Return Aa * Bb
            End Function) }
        }
        Console.WriteLine($"xl_dict: {Xl.JsonStringify(XlDict)}")
        Console.WriteLine($"xl_dict: {Xl.JsonStringify(XlDict, Pretty:=True)}")
    End Sub
End Module
