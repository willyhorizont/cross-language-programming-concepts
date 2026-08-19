module demo;

import std.stdio;
import std.conv : text;
import willyhorizont.runtime.xl;

void main() {
    /*
    1. support lambda as value, or has workaround
    */
    Xl sayHello = xl.lambda(delegate(Xl va) {
        Xl itr = xl.iter(va);
        Xl callback = xl.next(itr);
        writeln("hello");
        callback.call();
    });
    sayHello.call(xl.lambda(delegate(Xl va) {
        writeln("world");
    }));
    Xl createMultiplier = xl.lambda(delegate(Xl va) {
        Xl itr = xl.iter(va); 
        Xl aa = xl.next(itr);
        return xl.lambda(delegate(Xl va) {
            Xl itr = xl.iter(va);
            Xl bb = xl.next(itr);
            return xl.from(aa.toInt() * bb.toInt());
        });
    });
    Xl multiplyByTwo = createMultiplier.call(2);
    writeln(i"multiply_by_two(10): $(multiplyByTwo.call(10))".text);
    Xl multiplyByEight = createMultiplier.call(8);
    writeln(i"multiply_by_eight(4): $(multiplyByEight.call(4))".text);
    writeln(i"multiply_by_two(8): $(multiplyByTwo.call(8))".text);
    
    /*
    2. support dynamic-typed value, or has workaround
    */
    Xl xlList = xl.list(
        xl.None,
        true,
        false,
        "foo",
        0,
        -123,
        123.789,
        -123.789,
        xl.list(1, 2, 3),
        xl.dict(xl.pair("foo", "bar")),
        xl.lambda(delegate(Xl va) {
            Xl itr = xl.iter(va);
            Xl aa = xl.next(itr);
            Xl bb = xl.next(itr);
            return xl.from(aa.toInt() * bb.toInt());
        }),
    );
    writeln(i"xl_list: $(xl.jsonStringify(xlList))".text);
    writeln(i"xl_list: $(xl.jsonStringify(xlList, pretty: true))".text);
    Xl xlDict = xl.dict(
        xl.pair("xl_none", xl.None),
        xl.pair("xl_bool_true", true),
        xl.pair("xl_bool_false", false),
        xl.pair("xl_string", "foo"),
        xl.pair("xl_int_positive", 0),
        xl.pair("xl_int_negative", -123),
        xl.pair("xl_float_positive", 123.789),
        xl.pair("xl_float_negative", -123.789),
        xl.pair("xl_list", xl.list(1, 2, 3)),
        xl.pair("xl_dict", xl.dict(xl.pair("foo", "bar"))),
        xl.pair("xl_lambda", xl.lambda(delegate(Xl va) {
            Xl itr = xl.iter(va);
            Xl aa = xl.next(itr);
            Xl bb = xl.next(itr);
            return xl.from(aa.toInt() * bb.toInt());
        })),
    );
    writeln(i"xl_dict: $(xl.jsonStringify(xlDict))".text);
    writeln(i"xl_dict: $(xl.jsonStringify(xlDict, pretty: true))".text);
}
