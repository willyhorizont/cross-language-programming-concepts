package willyhorizont.runtime;

import java.util.HashMap;
import java.util.ArrayList;

@SuppressWarnings("unchecked")
public class JsLikeObject extends Any {
    private JavaJsLikeObject anyJsLikeObject;

    public JsLikeObject(Object... restArguments) {
        super(null);

        anyJsLikeObject = new JavaJsLikeObject();

        for (int arrayItemIndex = 0; arrayItemIndex < restArguments.length; arrayItemIndex += 1) {
            Object currentArgument = ((JsLikeArray) restArguments[arrayItemIndex]);
            Object objectKey = ((JavaJsLikeArray) ((JavaJsLikeArray) ((JsLikeArray) currentArgument).value)).get(0);
            Object objectValue = ((JavaJsLikeArray) ((JavaJsLikeArray) ((JsLikeArray) currentArgument).value)).get(1);
            anyJsLikeObject.put(((String) objectKey), objectValue);
        }

        value = anyJsLikeObject;
    }

    @Override
    public Any set(Object jsLikeObjectNewValue) {
        Object objectKey = ((JavaJsLikeArray) jsLikeObjectNewValue).get(0);
        Object objectValue = ((JavaJsLikeArray) jsLikeObjectNewValue).get(1);
        anyJsLikeObject.put((String) objectKey, objectValue);
        return this;
    }

    @Override
    public Any assign(Object jsLikeObjectNewValue) {
        return set(jsLikeObjectNewValue);
    }

    @Override
    public Any get(Object jsLikeObjectKey) {
        return new Any(anyJsLikeObject.get(jsLikeObjectKey));
    }

    @Override
    public Any squareBracket(Object jsLikeObjectKey) {
        return get(jsLikeObjectKey);
    }
}
