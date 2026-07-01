const WillyHorizont = require("willyhorizont.github.io");
const { jsonStringify } = WillyHorizont.Utils;

/*
1. support closure as value, or has workaround
*/
const sayHello = (callbackFunction) => {
    console.log("hello");
    callbackFunction();
};
sayHello(() => {
    console.log("wold");
});
const createMultiplier = (aa) => (bb) => (aa * bb);
const multiplyByTwo = createMultiplier(2);
console.log(`multiply_by_two(10): ${multiplyByTwo(10)}`);
const multiplyByEight = createMultiplier(8);
console.log(`multiply_by_eight(4): ${multiplyByEight(4)}`);
console.log(`multiply_by_two(8): ${multiplyByTwo(8)}`);

/*
2. support dynamic-typed value, or has workaround
*/
const xlList = [
    null,
    true,
    false,
    "foo",
    0,
    -123,
    123.789,
    -123.789,
    [1, 2, 3],
    { "foo": "bar" },
    (aa, bb) => (aa * bb),
];
console.log(`xl_list: ${jsonStringify(xlList)}`);
console.log(`xl_list: ${jsonStringify(xlList, { pretty: true })}`);
const xlDict = {
    "xl_none": null,
    "xl_bool_true": true,
    "xl_bool_false": false,
    "xl_string": "foo",
    "xl_int_positive": 0,
    "xl_int_negative": -123,
    "xl_float_positive": 123.789,
    "xl_float_negative": -123.789,
    "xl_list": [1, 2, 3],
    "xl_dict": { "foo": "bar" },
    "xl_closure": (aa, bb) => (aa * bb),
};
console.log(`xl_dict: ${jsonStringify(xlDict)}`);
console.log(`xl_dict: ${jsonStringify(xlDict, { pretty: true })}`);
