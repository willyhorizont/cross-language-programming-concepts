using System;
using System.Collections.Generic;
using System.Linq;
using WillyHorizont.Runtime.Xl;

class Program
{
    static void Main()
    {
        /*
        1. support lambda as value, or has workaround
        */
        dynamic SayHello = Xl.InitLambda((Va) => {
            dynamic Itr = Xl.Iter(Va);
            dynamic Callback = Xl.Next(Itr);
            Console.WriteLine("hello");
            Callback.Call();
        });
        SayHello.Call(Xl.InitLambda((Va) => {
            Console.WriteLine("world");
        }));
        dynamic CreateMultiplier = Xl.InitLambda((Va) => {
            dynamic Itr = Xl.Iter(Va);
            dynamic Aa = Xl.Next(Itr);
            return Xl.InitLambda((Va) => {
                dynamic Itr = Xl.Iter(Va);
                dynamic Bb = Xl.Next(Itr);
                return Aa * Bb; 
            });
        });
        dynamic MultiplyByTwo = CreateMultiplier.Call(2);
        Console.WriteLine($"multiply_by_two(10): {MultiplyByTwo.Call(10)}");
        dynamic MultiplyByEight = CreateMultiplier.Call(8);
        Console.WriteLine($"multiply_by_eight(4): {MultiplyByEight.Call(4)}");
        Console.WriteLine($"multiply_by_two(8): {MultiplyByTwo.Call(8)}");

        /*
        2. support dynamic-typed value, or has workaround
        */
        dynamic XlList = Xl.InitList(
            null,
            true,
            false,
            "foo",
            0,
            -123,
            123.789,
            -123.789,
            Xl.InitList(1, 2, 3),
            Xl.InitDict(("foo", "bar")),
            Xl.InitLambda((Va) => {
                dynamic Itr = Xl.Iter(Va);
                dynamic Aa = Xl.Next(Itr);
                dynamic Bb = Xl.Next(Itr);
                return Aa * Bb;
            })
        );
        Console.WriteLine($"xl_list: {Xl.JsonStringify(XlList)}");
        Console.WriteLine($"xl_list: {Xl.JsonStringify(XlList, Pretty: true)}");
        dynamic XlDict = Xl.InitDict(
            ( "xl_none", null ),
            ( "xl_bool_true", true ),
            ( "xl_bool_false", false ),
            ( "xl_string", "foo" ),
            ( "xl_int_positive", 0 ),
            ( "xl_int_negative", -123 ),
            ( "xl_float_positive", 123.789 ),
            ( "xl_float_negative", -123.789 ),
            ( "xl_list", Xl.InitList(1, 2, 3) ),
            ( "xl_dict", Xl.InitDict(("foo", "bar")) ),
            ( "xl_lambda", Xl.InitLambda((Va) => {
                dynamic Itr = Xl.Iter(Va);
                dynamic Aa = Xl.Next(Itr);
                dynamic Bb = Xl.Next(Itr);
                return Aa * Bb;
            }) )
        );
        Console.WriteLine($"xl_dict: {Xl.JsonStringify(XlDict)}");
        Console.WriteLine($"xl_dict: {Xl.JsonStringify(XlDict, Pretty: true)}");
    }
}
