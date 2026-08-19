import willyhorizont.runtime.Xl;

public class Main {
    public static void main(String[] args) {
        /*
        1. support lambda as value, or has workaround
        */
        Xl sayHello = Xl.initLambda((Xl... va) -> {
            Xl itr = Xl.iter(va);
            Xl callback = itr.next();
            System.out.println("hello");
            callback.call();
            return Xl.NONE;
        });
        sayHello.call(Xl.initLambda((Xl... va) -> {
            System.out.println("world");
            return Xl.NONE;
        }));
        Xl createMultiplier = Xl.initLambda((Xl... vaAa) -> {
            Xl itrAa = Xl.iter(vaAa);
            Xl aa = itrAa.next();
            return Xl.initLambda((Xl... vaBb) -> {
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
        Xl xlList = Xl.initList(
            Xl.NONE,
            true,
            false,
            "foo",
            0,
            -123,
            123.789,
            -123.789,
            Xl.initList(1, 2, 3),
            Xl.initDict(Xl.initPair("foo", "bar")),
            Xl.initLambda((Xl... va) -> {
                Xl itr = Xl.iter(va);
                Xl aa = itr.next();
                Xl bb = itr.next();
                return Xl.from(aa.toInt() * bb.toInt());
            })
        );
        System.out.println(Xl.jsonStringify(xlList));
        System.out.println(Xl.jsonStringify(xlList, Xl.initPair("pretty", true)));
        Xl xlDict = Xl.initDict(
            Xl.initPair("xl_none", Xl.NONE),
            Xl.initPair("xl_bool_true", true),
            Xl.initPair("xl_bool_false", false),
            Xl.initPair("xl_string", "foo"),
            Xl.initPair("xl_int_positive", 0),
            Xl.initPair("xl_int_negative", -123),
            Xl.initPair("xl_float_positive", 123.789),
            Xl.initPair("xl_float_negative", -123.789),
            Xl.initPair("xl_list", Xl.initList(1, 2, 3)),
            Xl.initPair("xl_dict", Xl.initDict(Xl.initPair("foo", "bar"))),
            Xl.initPair("xl_lambda", Xl.initLambda((Xl... va) -> {
                Xl itr = Xl.iter(va);
                Xl aa = itr.next();
                Xl bb = itr.next();
                return Xl.from(aa.toInt() * bb.toInt());
            }))
        );
        System.out.println(Xl.jsonStringify(xlDict));
        System.out.println(Xl.jsonStringify(xlDict, Xl.initPair("pretty", true)));
    }
}
