import willyhorizont.runtime.Xl;

public class Main {
    public static void main(String[] args) {
        /*
        1. support lambda as value, or has workaround
        */
        Xl sayHello = Xl.from((Xl... va) -> {
            Xl itr = Xl.iter(va);
            Xl callbackFunction = itr.next();
            System.out.println("hello");
            callbackFunction.call();
            return Xl.NONE;
        });
        sayHello.call(Xl.from((Xl... genericArgs) -> {
            System.out.println("world");
            return Xl.NONE;
        }));
        Xl createMultiplier = Xl.from((Xl... vaAa) -> {
            Xl itrAa = Xl.iter(vaAa);
            Xl aa = itrAa.next();
            return Xl.from((Xl... vaBb) -> {
                Xl itrBb = Xl.iter(vaBb);
                Xl bb = itrBb.next();
                return Xl.from(aa.toInt() * bb.toInt());
            });
        });
        Xl multiplyByTwo = createMultiplier.call(Xl.from(2));
        System.out.println("multiply_by_two(10): " + multiplyByTwo.call(Xl.from(10)));
        Xl multiplyByEight = createMultiplier.call(Xl.from(8));
        System.out.println("multiply_by_eight(4): " + multiplyByEight.call(Xl.from(4)));
        System.out.println("multiply_by_two(8): " + multiplyByTwo.call(Xl.from(8)));

        /*
        2. support dynamic-typed value, or has workaround
        */
        Xl xlList = Xl.list(
            Xl.NONE,
            true,
            false,
            "foo",
            0,
            -123,
            123.789,
            -123.789,
            Xl.list(1, 2, 3),
            Xl.dict(Xl.pair("foo", "bar")),
            Xl.from((Xl... va) -> {
                Xl itr = Xl.iter(va);
                Xl aa = itr.next();
                Xl bb = itr.next();
                return Xl.from(aa.toInt() * bb.toInt());
            })
        );
        System.out.println(Xl.jsonStringify(xlList));
        System.out.println(Xl.jsonStringify(xlList, Xl.pair("pretty", true)));
        Xl xlDict = Xl.dict(
            Xl.pair("xl_none", Xl.NONE),
            Xl.pair("xl_bool_true", true),
            Xl.pair("xl_bool_false", false),
            Xl.pair("xl_string", "foo"),
            Xl.pair("xl_int_positive", 0),
            Xl.pair("xl_int_negative", -123),
            Xl.pair("xl_float_positive", 123.789),
            Xl.pair("xl_float_negative", -123.789),
            Xl.pair("xl_list", Xl.list(1, 2, 3)),
            Xl.pair("xl_dict", Xl.dict(Xl.pair("foo", "bar"))),
            Xl.pair("xl_lambda", Xl.from((Xl... va) -> {
                Xl itr = Xl.iter(va);
                Xl aa = itr.next();
                Xl bb = itr.next();
                return Xl.from(aa.toInt() * bb.toInt());
            }))
        );
        System.out.println(Xl.jsonStringify(xlDict));
        System.out.println(Xl.jsonStringify(xlDict, Xl.pair("pretty", true)));
    }
}
