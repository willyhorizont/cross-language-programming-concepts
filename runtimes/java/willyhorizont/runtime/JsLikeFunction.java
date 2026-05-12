package willyhorizont.runtime;

public class JsLikeFunction {
    @FunctionalInterface
    interface VariadicFunctionExpression<Result> {
        Result apply(Object... args);
    }
}