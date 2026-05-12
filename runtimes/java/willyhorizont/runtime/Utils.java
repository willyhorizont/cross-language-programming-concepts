package willyhorizont.runtime;

import java.util.HashMap;
import java.util.ArrayList;

@SuppressWarnings("unchecked")
public class Utils {
    public static boolean checkIsLikeJsNull(Object anything) {
        return (anything == null);
    }
    public static boolean checkIsLikeJsBoolean(Object anything) {
        if (checkIsLikeJsNull(anything) == true) return false;
        return (anything instanceof Boolean);
    }
    public static boolean checkIsLikeJsString(Object anything) {
        if (checkIsLikeJsNull(anything) == true) return false;
        return (anything instanceof String);
    }
    public static boolean checkIsLikeJsInt(Object anything) {
        if (!(anything instanceof Number)) return false;
        double n = ((Number) anything).doubleValue();
        if (!Double.isFinite(n)) return false;
        return ((n % 1) == 0);
    }
    public static boolean checkIsLikeJsFloat(Object anything) {
        if (!(anything instanceof Number)) return false;
        double n = ((Number) anything).doubleValue();
        if (!Double.isFinite(n)) return false;
        return ((n % 1) != 0);
    }
    public static boolean checkIsLikeJsObject(Object anything) {
        if ((anything instanceof HashMap) == false) return false;
        for (Object objectKey : ((HashMap<?, ?>) anything).keySet()) {
            if ((objectKey instanceof String) == false) return false;
        }
        for (Object objectValue : ((HashMap<?, ?>) anything).values()) {
            if ((objectValue instanceof Object) == false) return false;
        }
        return true;
    }
    public static boolean checkIsLikeJsArray(Object anything) {
        if ((anything instanceof ArrayList) == false) return false;
        for (Object arrayItem : ((ArrayList<?>) anything)) {
            if ((arrayItem instanceof Object) == false) return false;
        }
        return true;
    }
    public static boolean checkIsLikeJsFunction(Object anything) {
        if (checkIsLikeJsNull(anything) == true) return false;
        return (anything instanceof JavaJsLikeFunction);
    }
    // public static boolean checkIsLikeJsError(Object anything) {
    //     if (checkIsLikeJsNull(anything) == true) return false;
    //     // TODO
    //     return (anything instanceof JavaJsLikeFunction);
    // }
    // public static boolean checkIsLikeJsDate(Object anything) {
    //     if (checkIsLikeJsNull(anything) == true) return false;
    //     // TODO
    //     return (anything instanceof JavaJsLikeFunction);
    // }
    public static Any JsLikeAnyType = new JsLikeObject(
        new JsLikeArray("Null", "Null"),
        new JsLikeArray("Boolean", "Boolean"),
        new JsLikeArray("String", "String"),
        new JsLikeArray("Int", "Int"),
        new JsLikeArray("Float", "Float"),
        new JsLikeArray("Object", "Object"),
        new JsLikeArray("Array", "Array"),
        new JsLikeArray("Function", "Function")
        // new JsLikeArray("Error", "Error"), // TODO
        // new JsLikeArray("Date", "Date") // TODO
    );
    public static Any getType(Object anything) {
        if (checkIsLikeJsNull(anything) == true) return (JsLikeAnyType.get("Null"));
        if (checkIsLikeJsBoolean(anything) == true) return (JsLikeAnyType.get("Boolean"));
        if (checkIsLikeJsString(anything) == true) return (JsLikeAnyType.get("String"));
        if (checkIsLikeJsInt(anything) == true) return (JsLikeAnyType.get("Int"));
        if (checkIsLikeJsFloat(anything) == true) return (JsLikeAnyType.get("Float"));
        if (checkIsLikeJsObject(anything) == true) return (JsLikeAnyType.get("Object"));
        if (checkIsLikeJsArray(anything) == true) return (JsLikeAnyType.get("Array"));
        if (checkIsLikeJsFunction(anything) == true) return (JsLikeAnyType.get("Function"));
        // if (checkIsLikeJsError(anything) == true) return (JsLikeAnyType.get("Error")); // TODO
        // if (checkIsLikeJsDate(anything) == true) return (JsLikeAnyType.get("Date")); // TODO
        return new Any(anything.getClass().getName());
    }
}
