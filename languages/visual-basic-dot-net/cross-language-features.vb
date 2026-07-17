Imports System
Imports System.Collections.Generic
Imports System.Linq
Imports Xl = WillyHorizont.Runtime

Module Program
    Sub Main()
        ' 1. support closure as value, or has workaround
        Dim SayHello As Object = Function(Va() As Object) As Object
            Dim Itr As Object = Va.GetEnumerator()
            Dim CallbackFunction As Object = New Object() {Itr.MoveNext(), Itr.Current}.Last()
            Console.WriteLine("hello")
            CallbackFunction.DynamicInvoke(New Object() { New Object() {} })
            Return Nothing
        End Function
        SayHello.DynamicInvoke(New Object() {
            New Object() {
                Function(Va() As Object) As Object
                    Console.WriteLine("world")
                    Return Nothing
                End Function
            }
        })
        Dim CreateMultiplier As Object = Function(VaAa() As Object) As Object
            Dim ItrAa As Object = VaAa.GetEnumerator()
            Dim Aa As Object = New Object() {ItrAa.MoveNext(), ItrAa.Current}.Last()
            Return Function(VaBb() As Object) As Object
                Dim ItrBb As Object = VaBb.GetEnumerator()
                Dim Bb As Object = New Object() {ItrBb.MoveNext(), ItrBb.Current}.Last()
                Return Aa * Bb
            End Function
        End Function
        Dim MultiplyByTwo As Object = CreateMultiplier.DynamicInvoke(New Object() {New Object() {2}})
        Console.WriteLine($"multiply_by_two(10): {MultiplyByTwo.DynamicInvoke(New Object() {New Object() {10}})}")
        Dim MultiplyByEight As Object = CreateMultiplier.DynamicInvoke(New Object() {New Object() {8}})
        Console.WriteLine($"multiply_by_eight(4): {MultiplyByEight.DynamicInvoke(New Object() {New Object() {4}})}")
        Console.WriteLine($"multiply_by_two(8): {MultiplyByTwo.DynamicInvoke(New Object() {New Object() {8}})}")

        ' 2. support dynamic-typed value, or has workaround
        Dim XlList As Object = New List(Of Object) From {
            Nothing,
            True,
            False,
            "foo",
            0,
            -123,
            123.789,
            -123.789,
            New List(Of Object) From {1, 2, 3},
            New Dictionary(Of String, Object) From {{"foo", "bar"}},
            Function(Va() As Object) As Object
                Dim Itr As Object = Va.GetEnumerator()
                Dim Aa As Object = New Object() {Itr.MoveNext(), Itr.Current}.Last()
                Dim Bb As Object = New Object() {Itr.MoveNext(), Itr.Current}.Last()
                Return Aa * Bb
            End Function
        }
        Console.WriteLine($"xl_list: {Xl.JsonStringify(XlList)}")
        Console.WriteLine($"xl_list: {Xl.JsonStringify(XlList, Pretty:=True)}")
        Dim XlDict As Object = New Dictionary(Of String, Object) From {
            {"xl_none", Nothing},
            {"xl_bool_true", True},
            {"xl_bool_false", False},
            {"xl_string", "foo"},
            {"xl_int_positive", 0},
            {"xl_int_negative", -123},
            {"xl_float_positive", 123.789},
            {"xl_float_negative", -123.789},
            {"xl_list", New List(Of Object) From {1, 2, 3}},
            {"xl_dict", New Dictionary(Of String, Object) From {{"foo", "bar"}}},
            {"xl_closure", Function(Va() As Object) As Object
                Dim Itr As Object = Va.GetEnumerator()
                Dim Aa As Object = New Object() {Itr.MoveNext(), Itr.Current}.Last()
                Dim Bb As Object = New Object() {Itr.MoveNext(), Itr.Current}.Last()
                Return Aa * Bb
            End Function}
        }
        Console.WriteLine($"xl_dict: {Xl.JsonStringify(XlDict)}")
        Console.WriteLine($"xl_dict: {Xl.JsonStringify(XlDict, Pretty:=True)}")
    End Sub
End Module
