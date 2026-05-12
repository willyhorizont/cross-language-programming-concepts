package willyhorizont.runtime;

import java.util.ArrayList;

@SuppressWarnings("unchecked")
public class JsLikeArray extends Any {

    private JavaJsLikeArray anyJsLikeArray;

    public int length;

    public JsLikeArray(Object... restArguments) {
        super(null);

        anyJsLikeArray = new JavaJsLikeArray();

        for (Object anyJsLikeArrayItem : restArguments) {
            anyJsLikeArray.add(anyJsLikeArrayItem);
        }

        length = anyJsLikeArray.size();

        value = anyJsLikeArray;
    }

    @Override
    public Any push(Object jsLikeArrayNewValue) {
        anyJsLikeArray.add(jsLikeArrayNewValue);
        length = anyJsLikeArray.size();
        return this;
    }

    @Override
    public Any at(Object jsLikeArrayItemIndex) {
        return new Any(anyJsLikeArray.get((int) jsLikeArrayItemIndex));
    }

    @Override
    public Any squareBracket(Object jsLikeArrayItemIndex) {
        return at((int) jsLikeArrayItemIndex);
    }
}
