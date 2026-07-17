using System;
using System.Collections.Generic;
using System.Linq;
using Xl = WillyHorizont.Runtime.Xl;

class Program
{
    static void Main()
    {
        /*
        1. support closure as value, or has workaround
        */
        dynamic SayHello = (Func<dynamic[], dynamic>)((Va) => {
            var Itr = Va.GetEnumerator();
            dynamic CallbackFunction = new dynamic[] { Itr.MoveNext(), Itr.Current }.Last();
            Console.WriteLine("hello");
            CallbackFunction(new dynamic[] { });
            return null;
        });
        SayHello(new dynamic[] {
            (Func<dynamic[], dynamic>)((Va) => {
                Console.WriteLine("world");
                return null;
            })
        });
        dynamic CreateMultiplier = (Func<dynamic[], dynamic>)((VaAa) => {
            var ItrAa = VaAa.GetEnumerator();
            dynamic Aa = new dynamic[] { ItrAa.MoveNext(), ItrAa.Current }.Last();
            return (Func<dynamic[], dynamic>)((VaBb) => {
                var ItrBb = VaBb.GetEnumerator();
                dynamic Bb = new dynamic[] { ItrBb.MoveNext(), ItrBb.Current }.Last();
                return Aa * Bb; 
            });
        });
        dynamic MultiplyByTwo = CreateMultiplier(new dynamic[] { 2 });
        Console.WriteLine($"multiply_by_two(10): {MultiplyByTwo(new dynamic[] { 10 })}");
        dynamic MultiplyByEight = CreateMultiplier(new dynamic[] { 8 });
        Console.WriteLine($"multiply_by_eight(4): {MultiplyByEight(new dynamic[] { 4 })}");
        Console.WriteLine($"multiply_by_two(8): {MultiplyByTwo(new dynamic[] { 8 })}");

        /*
        2. support dynamic-typed value, or has workaround
        */
        dynamic XlList = new List<dynamic> {
            null,
            true,
            false,
            "foo",
            0,
            -123,
            123.789,
            -123.789,
            new List<dynamic> {1, 2, 3},
            new Dictionary<string, dynamic> {{"foo", "bar"}},
            (Func<dynamic[], dynamic>)((Va) => {
                var Itr = Va.GetEnumerator();
                dynamic Aa = new dynamic[] { Itr.MoveNext(), Itr.Current }.Last();
                dynamic Bb = new dynamic[] { Itr.MoveNext(), Itr.Current }.Last();
                return Aa * Bb;
            })
        };
        Console.WriteLine($"xl_list: {Xl.JsonStringify(XlList)}");
        Console.WriteLine($"xl_list: {Xl.JsonStringify(XlList, Pretty: true)}");
        dynamic XlDict = new Dictionary<string, dynamic> {
            {"xl_none", null},
            {"xl_bool_true", true},
            {"xl_bool_false", false},
            {"xl_string", "foo"},
            {"xl_int_positive", 0},
            {"xl_int_negative", -123},
            {"xl_float_positive", 123.789},
            {"xl_float_negative", -123.789},
            {"xl_list", new List<dynamic> {1, 2, 3}},
            {"xl_dict", new Dictionary<string, dynamic> {{"foo", "bar"}}},
            {"xl_closure", (Func<dynamic[], dynamic>)((Va) => {
                var Itr = Va.GetEnumerator();
                dynamic Aa = new dynamic[] { Itr.MoveNext(), Itr.Current }.Last();
                dynamic Bb = new dynamic[] { Itr.MoveNext(), Itr.Current }.Last();
                return Aa * Bb;
            })}
        };
        Console.WriteLine($"xl_dict: {Xl.JsonStringify(XlDict)}");
        Console.WriteLine($"xl_dict: {Xl.JsonStringify(XlDict, Pretty: true)}");
    }
}
