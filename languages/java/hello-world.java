import willyhorizont.runtime.Any;
import willyhorizont.runtime.JsLikeArray;
import willyhorizont.runtime.Utils;

@SuppressWarnings("unchecked")
public class Main {
    public static void main(String[] args) {
        System.out.println("Hello, World!");

        Any something;
        something = new JsLikeArray(1, 2, 3);

        System.out.println(something);
        System.out.println(something.at(0));
        System.out.println(something.squareBracket(2));
        System.out.println(((JsLikeArray) something).length);
        System.out.println(Utils.getType(something));
    }
}