const WillyHorizont = require("willyhorizont.github.io");
const { createRecursiveFunctionNoCallStackLimit, getIsInt } = WillyHorizont.Utils;

// const factorial = (num) => ((
//     (fn) => ((self) => (fn((args) => (self(self)(args)))))((self) => (fn((args) => (self(self)(args)))))
// )(
//     (factorialFn) => ((args) => (((args[0] === 0) ? (args[1]) : (factorialFn([(args[0] - 1), (args[1] * args[0])])))))
// ))([num, 1]);

// console.log(factorial(5));

// factorial(100000) is fine:
// Scheme
// OCaml
// Erlang
// Elixir
// Haskell
// Scala
// F#

const factorialV6 = (() => {
    const factorialInternal = createRecursiveFunctionNoCallStackLimit((self) => ((anyInt, accumulator) => {
        if (anyInt === 0) return accumulator;
        return self((anyInt - 1), (anyInt * accumulator));
    }));

    return (anything) => {
        if (getIsInt(anything) === false) return "Error: Argument should be any non-negative integer";
        if (anything < 0) return "Error: Argument should be >= 0";
        if (anything === 0) return 1;
        return factorialInternal(anything, 1);
    };
})();

console.log(factorialV6(5));
// console.log(getIsInt(5));
const factorial = (anything) => ((getIsInt(anything) === false) ? ["Error: Argument should be any non-negative integer", null] : (anything < 0) ? ["Error: Argument should be >= 0", null] : (anything === 0) ? [null, 1] : [null, (createRecursiveFunctionNoCallStackLimit((self) => ((anyInt, accumulator) => ((anyInt === 0) ? accumulator : self((anyInt - 1), (anyInt * accumulator))))))(anything, 1)]);
const [factorialErrorMessage, factorialResult] = factorial(new Number(5));
console.log(factorialResult);