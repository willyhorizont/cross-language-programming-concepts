package willyhorizont.runtime;

@SuppressWarnings("unchecked")
public class Any {
    protected Object value;

    public int length;

    public Any(Object value) {
        this.value = value;
    }

    public Any push(Object anything) {
        throw new RuntimeException("push() not supported");
    }

    public Any at(Object index) {
        throw new RuntimeException("at() not supported");
    }

    public Any get(Object anything) {
        throw new RuntimeException("get() not supported");
    }

    public Any squareBracket(Object anything) {
        throw new RuntimeException("squareBracket() not supported");
    }

    public Any set(Object anything) {
        throw new RuntimeException("set() not supported");
    }

    public Any assign(Object anything) {
        throw new RuntimeException("assign() not supported");
    }

    @Override
    public String toString() {
        return String.valueOf(value);
    }
}
