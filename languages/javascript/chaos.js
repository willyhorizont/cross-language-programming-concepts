globalThis.WillyHorizont = require("willyhorizont.github.io");
globalThis.WillyHorizont.Utils = require("willyhorizont.github.io/utils.js");

console.log("hello, world");

{
    let i = 0;
    WillyHorizont.Utils.forEach(Array.from(WillyHorizont.Utils.rangeInclusive(1, 10)), ((anyArrayItem, anyArrayItemIndex, anyArray) => {
        if (anyArrayItem > 5) return true;
        console.log(anyArrayItem);
        i += 10;
    }));
    console.log(i);
}
const factorialV4 = (anyNumber) => {
    if (typeof anyNumber !== "number") throw new Error("Argument should be a number");
    if (anyNumber < 0) throw new Error("Argument should be >= 0");
    if (anyNumber === 0) return 1;
    return (anyNumber * factorialV4(anyNumber - 1));
};
console.log(factorialV4(5));
const factorialV5 = WillyHorizont.Utils.createRecursiveFunctionNoCallStackLimit((self) => (anyNumber, accumulator = 1) => {
    if (typeof anyNumber !== "number") throw new Error("Argument should be a number");
    if (anyNumber < 0) throw new Error("Argument should be >= 0");
    if (anyNumber === 0) return accumulator;
    return self((anyNumber - 1), (anyNumber * accumulator));
});
console.log(factorialV5(5));