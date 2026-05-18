const WillyHorizont = require("willyhorizont.github.io");
const { jsonStringify } = WillyHorizont.Utils;

const somePythonLikeDict = {
    "some_undefined": undefined,
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
console.log(`somePythonLikeDict["some_string"]: ${jsonStringify(somePythonLikeDict["some_string"], { pretty: true })}`);

const somePythonLikeDictWorkaroundAa = (key) => {
    if (key === "some_undefined") return undefined;
    if (key === "some_null") return null;
    if (key === "some_boolean_true") return true;
    if (key === "some_boolean_false") return false;
    if (key === "some_string") return "foo";
    if (key === "some_int_positive") return 123;
    if (key === "some_int_negative") return -123;
    if (key === "some_float_positive") return 123.789;
    if (key === "some_float_negative") return -123.789;
    if (key === "some_python_like_list") return [1, 2, 3];
    if (key === "some_python_like_dict") return { "foo": "bar" };
    if (key === "some_function") return (a, b) => (a * b);
    return undefined;
};
console.log(`somePythonLikeDictWorkaroundAa: ${jsonStringify(somePythonLikeDictWorkaroundAa, { pretty: true })}`);
console.log(`somePythonLikeDictWorkaroundAa("some_string"): ${jsonStringify(somePythonLikeDictWorkaroundAa("some_string"), { pretty: true })}`);

const somePythonLikeDictWorkaroundBb = (key) => {
    switch (key) {
        case "some_undefined":
            return undefined;
        case "some_null":
            return null;
        case "some_boolean_true":
            return true;
        case "some_boolean_false":
            return false;
        case "some_string":
            return "foo";
        case "some_int_positive":
            return 123;
        case "some_int_negative":
            return -123;
        case "some_float_positive":
            return 123.789;
        case "some_float_negative":
            return -123.789;
        case "some_python_like_list":
            return [1, 2, 3];
        case "some_python_like_dict":
            return { "foo": "bar" };
        case "some_function":
            return (a, b) => (a * b);
        default:
            return undefined;
    }
};
console.log(`somePythonLikeDictWorkaroundBb: ${jsonStringify(somePythonLikeDictWorkaroundBb, { pretty: true })}`);
console.log(`somePythonLikeDictWorkaroundBb("some_string"): ${jsonStringify(somePythonLikeDictWorkaroundBb("some_string"), { pretty: true })}`);

const somePythonLikeDictWorkaroundCc = (key) => (
    (key === "some_undefined") ? undefined :
    (key === "some_null") ? null :
    (key === "some_boolean_true") ? true :
    (key === "some_boolean_false") ? false :
    (key === "some_string") ? "foo" :
    (key === "some_int_positive") ? 123 :
    (key === "some_int_negative") ? -123 :
    (key === "some_float_positive") ? 123.789 :
    (key === "some_float_negative") ? -123.789 :
    (key === "some_python_like_list") ? [1, 2, 3] :
    (key === "some_python_like_dict") ? { "foo": "bar" } :
    (key === "some_function") ? (a, b) => (a * b) :
    undefined);
console.log(`somePythonLikeDictWorkaroundCc: ${jsonStringify(somePythonLikeDictWorkaroundCc, { pretty: true })}`);
console.log(`somePythonLikeDictWorkaroundCc("some_string"): ${jsonStringify(somePythonLikeDictWorkaroundCc("some_string"), { pretty: true })}`);
