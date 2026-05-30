const WillyHorizont = require("willyhorizont.github.io");
const { jsonStringify } = WillyHorizont.Utils;

/*
1. support function as value
*/
const sayHello = (callbackFunction) => {
    console.log("hello");
    callbackFunction();
};
sayHello(() => {
    console.log("wold");
});
const multiply = (a) => (b) => (a * b);
const multiplyByTwo = multiply(2);
console.log(`multiplyByTwo(10): ${multiplyByTwo(10)}`);
const multiplyByEight = multiply(8);
console.log(`multiplyByEight(4): ${multiplyByEight(4)}`);
console.log(`multiplyByTwo(8): ${multiplyByTwo(8)}`);

/*
2. support dynamic-typed value, or has workaround
*/
const somePythonLikeList = [
    null,
    true,
    false,
    "foo",
    123,
    -123,
    123.789,
    -123.789,
    [1, 2, 3],
    { "foo": "bar" },
    (a, b) => (a * b),
];
console.log(`somePythonLikeList: ${jsonStringify(somePythonLikeList, { pretty: true })}`);
const somePythonLikeDict = {
    "some_null": null,
    "some_boolean_true": true,
    "some_boolean_false": false,
    "some_string": "foo",
    "some_int_positive": 123,
    "some_int_negative": -123,
    "some_float_positive": 123.789,
    "some_float_negative": -123.789,
    "some_python_like_list": [1, 2, 3],
    "some_python_like_dict": { "foo": "bar" },
    "some_function": (a, b) => (a * b),
};
console.log(`somePythonLikeDict: ${jsonStringify(somePythonLikeDict, { pretty: true })}`);
