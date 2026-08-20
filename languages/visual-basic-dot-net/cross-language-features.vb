Imports System
Imports System.Collections.Generic
Imports System.Linq
Imports WillyHorizont.Runtime.Xl

Module Program
    Sub Main()
        ' 1. support lambda as value, or has workaround
        Dim SayHello As Object = Xl.InitLambda(Function(Va)
            Dim Itr As Object = Xl.Iter(Va)
            Dim Callback As Object = Xl.GetNext(Itr)
            Console.WriteLine("hello")
            Callback.Invoke()
        End Function)
        SayHello.Invoke(Xl.InitLambda(Function(Va)
            Console.WriteLine("world")
        End Function))
        Dim CreateMultiplier As Object = Xl.InitLambda(Function(VaAa)
            Dim ItrAa As Object = Xl.Iter(VaAa)
            Dim Aa As Object = Xl.GetNext(ItrAa)
            Return Xl.InitLambda(Function(VaBb)
                Dim ItrBb As Object = Xl.Iter(VaBb)
                Dim Bb As Object = Xl.GetNext(ItrBb)
                Return Aa * Bb
            End Function)
        End Function)
        Dim MultiplyByTwo As Object = CreateMultiplier.Invoke(2)
        Console.WriteLine($"multiply_by_two(10): {MultiplyByTwo.Invoke(10)}")
        Dim MultiplyByEight As Object = CreateMultiplier.Invoke(8)
        Console.WriteLine($"multiply_by_eight(4): {MultiplyByEight.Invoke(4)}")
        Console.WriteLine($"multiply_by_two(8): {MultiplyByTwo.Invoke(8)}")

        ' 2. support dynamic-typed value, or has workaround
        Dim XlList As Object = Xl.InitList(
            Nothing,
            True,
            False,
            "foo",
            0,
            -123,
            123.789,
            -123.789,
            Xl.InitList(1, 2, 3),
            Xl.InitDict(Xl.InitPair("foo", "bar")),
            Xl.InitLambda(Function(Va)
                Dim Itr As Object = Xl.Iter(Va)
                Dim Aa As Object = Xl.GetNext(Itr)
                Dim Bb As Object = Xl.GetNext(Itr)
                Return Aa * Bb
            End Function)
        )
        Console.WriteLine($"xl_list: {Xl.JsonStringify(XlList)}")
        Console.WriteLine($"xl_list: {Xl.JsonStringify(XlList, Pretty:=True)}")
        Dim XlDict As Object = Xl.InitDict(
            Xl.InitPair("xl_none", Nothing),
            Xl.InitPair("xl_bool_true", True),
            Xl.InitPair("xl_bool_false", False),
            Xl.InitPair("xl_string", "foo"),
            Xl.InitPair("xl_int_positive", 0),
            Xl.InitPair("xl_int_negative", -123),
            Xl.InitPair("xl_float_positive", 123.789),
            Xl.InitPair("xl_float_negative", -123.789),
            Xl.InitPair("xl_list", Xl.InitList(1, 2, 3)),
            Xl.InitPair("xl_dict", Xl.InitDict(Xl.InitPair("foo", "bar"))),
            Xl.InitPair("xl_lambda", Xl.InitLambda(Function(Va)
                Dim Itr As Object = Xl.Iter(Va)
                Dim Aa As Object = Xl.GetNext(Itr)
                Dim Bb As Object = Xl.GetNext(Itr)
                Return Aa * Bb
            End Function))
        )
        Console.WriteLine($"xl_dict: {Xl.JsonStringify(XlDict)}")
        Console.WriteLine($"xl_dict: {Xl.JsonStringify(XlDict, Pretty:=True)}")
    End Sub
End Module
