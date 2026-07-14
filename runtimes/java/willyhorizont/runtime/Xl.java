package willyhorizont.runtime;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Arrays;
import java.util.Map;

public class Xl {
    @FunctionalInterface
    public interface Closure {
        Xl apply(Xl... args);
    }

    public enum Type {
        NONE, BOOL, STRING, INT, FLOAT, LIST, DICT, CLOSURE, ITERATOR
    }

    public static final Xl NONE = new Xl(Type.NONE, null);

    private final Type type;
    private Object value;

    private Xl(Type t, Object v) {
        this.type = t;
        this.value = v;
    }

    public static Xl from(Boolean v) {
        return v == null ? NONE : new Xl(Type.BOOL, v);
    }

    public static Xl from(String v) {
        return v == null ? NONE : new Xl(Type.STRING, v);
    }

    public static Xl from(Integer v) {
        return v == null ? NONE : new Xl(Type.INT, v);
    }
    
    public static Xl from(Double v) {
        return v == null ? NONE : new Xl(Type.FLOAT, v);
    }

    public static Xl from(Closure v) {
        return v == null ? NONE : new Xl(Type.CLOSURE, v);
    }

    @SuppressWarnings("unchecked")
    public static Xl from(Iterator<Xl> v) {
        return v == null ? NONE : new Xl(Type.ITERATOR, v);
    }

    public static Xl iter(Xl[] array) {
        if (array == null) return NONE;
        return from(Arrays.asList(array).iterator());
    }

    @SuppressWarnings("unchecked")
    public static Xl toXl(Object a) {
        if (a == null) return NONE;
        if (a instanceof Xl) return (Xl) a;
        if (a instanceof Boolean) return from((Boolean) a);
        if (a instanceof String) return from((String) a);
        if (a instanceof Integer) return from((Integer) a);
        if (a instanceof Double) return from((Double) a);
        if (a instanceof Closure) return from((Closure) a);
        if (a instanceof Iterator) return from((Iterator<Xl>) a);
        return NONE;
    }

    public static Xl list(Object... els) {
        ArrayList<Xl> l = new ArrayList<>();
        for (Object el : els) {
            l.add(toXl(el));
        }
        return new Xl(Type.LIST, l);
    }

    public static class Pair {
        public String key;
        public Xl value;
        public Pair(String k, Object v) {
            this.key = k;
            this.value = toXl(v);
        }
    }

    public static Pair pair(String k, Object v) {
        return new Pair(k, v);
    }

    public static Xl dict(Pair... dpl) {
        HashMap<String, Xl> d = new HashMap<>();
        for (Pair dp : dpl) {
            d.put(dp.key, dp.value);
        }
        return new Xl(Type.DICT, d);
    }

    public Xl call(Xl... args) {
        if (this.type == Type.CLOSURE) {
            return ((Closure) this.value).apply(args);
        }
        return NONE;
    }

    @SuppressWarnings("unchecked")
    public boolean hasNext() {
        if (this.type == Type.ITERATOR) {
            return ((Iterator<Xl>) this.value).hasNext();
        }
        throw new RuntimeException("XlRuntimeError: Expected Iterator.");
    }

    @SuppressWarnings("unchecked")
    public Xl next() {
        if (this.type == Type.ITERATOR) {
            Iterator<Xl> itr = (Iterator<Xl>) this.value;
            if (itr.hasNext()) {
                return itr.next();
            }
            throw new RuntimeException("XlRuntimeSentinelNotRuntimeError: Expected to error to stop Iterator.");
        }
        throw new RuntimeException("XlRuntimeError: Expected Iterator.");
    }

    public Type getType() {
        return this.type;
    }

    @SuppressWarnings("unchecked")
    public Xl get(String k) {
        if (this.type == Type.DICT) {
            Xl d = ((HashMap<String, Xl>) this.value).get(k);
            return d == null ? NONE : d;
        }
        throw new RuntimeException("XlRuntimeError: Expected Dict.");
    }

    public boolean toBool() {
        if (this.type == Type.BOOL) return (Boolean) this.value;
        throw new RuntimeException("XlRuntimeError: Expected Bool.");
    }

    public int toInt() {
        if (this.type == Type.INT) return (Integer) this.value;
        if (this.type == Type.FLOAT) return ((Double) this.value).intValue();
        throw new RuntimeException("XlRuntimeError: Expected Int.");
    }

    public double toDouble() {
        if (this.type == Type.FLOAT) return (Double) this.value;
        if (this.type == Type.INT) return ((Integer) this.value).doubleValue();
        throw new RuntimeException("XlRuntimeError: Expected Float.");
    }

    @SuppressWarnings("unchecked")
    public ArrayList<Xl> toList() {
        if (this.type == Type.LIST) return (ArrayList<Xl>) this.value;
        throw new RuntimeException("XlRuntimeError: Expected List.");
    }

    @SuppressWarnings("unchecked")
    public HashMap<String, Xl> toDict() {
        if (this.type == Type.DICT) return (HashMap<String, Xl>) this.value;
        throw new RuntimeException("XlRuntimeError: Expected Dict.");
    }

    public static String escapeString(String s) {
        if (s == null) return "";
        String r = s;
        r = r.replace("\\", "\\\\");
        r = r.replace("\"", "\\\"");
        r = r.replace("\n", "\\n");
        r = r.replace("\r", "\\r");
        r = r.replace("\t", "\\t");
        return r;
    }

    public static String jsonStringify(Xl a) {
        return jsonStringify(a, NONE);
    }

    public static String jsonStringify(Xl a, Pair... p) {
        return jsonStringify(a, dict(p));
    }

    private static String jsonStringify(Xl a, Xl o) {
        boolean p = false;
        if (o.getType() == Type.DICT) {
            try {
                p = o.get("pretty").toBool();
            } catch (Exception e) {
                p = false;
            }
        }
        String t = " ".repeat(4);
        ArrayList<Xl> s = new ArrayList<>();
        s.add(dict(pair("t", "v"), pair("v", a), pair("d", 0)));
        StringBuilder r = new StringBuilder();
        while (s.size() > 0) {
            Xl c = s.remove(s.size() - 1);
            if (c.get("t").toString().equals("r")) {
                r.append(c.get("v").toString());
                continue;
            }
            Xl v = c.get("v");
            int curD = c.get("d").toInt();
            if (v.getType() == Type.NONE) {
                r.append("null");
                continue;
            }
            if (v.getType() == Type.BOOL) {
                r.append(v.toBool() ? "true" : "false");
                continue;
            }
            if (v.getType() == Type.STRING) {
                r.append("\"").append(escapeString(v.toString())).append("\"");
                continue;
            }
            if (v.getType() == Type.INT || v.getType() == Type.FLOAT) {
                r.append(v.toString());
                continue;
            }
            if (v.getType() == Type.CLOSURE) {
                r.append("\"[object Function]\"");
                continue;
            }
            if (v.getType() == Type.LIST) {
                ArrayList<Xl> l = v.toList();
                if (l.isEmpty()) {
                    r.append("[]");
                    continue;
                }
                int childD = curD + 1;
                s.add(dict(
                    pair("t", "r"),
                    pair("v", p ? "\n" + t.repeat(curD) + "]" : "]"),
                    pair("d", curD)
                ));
                for (int i = l.size() - 1; i >= 0; i -= 1) {
                    s.add(dict(
                        pair("t", "v"),
                        pair("v", l.get(i)),
                        pair("d", childD)
                    ));
                    if (i > 0) {
                        s.add(dict(
                            pair("t", "r"),
                            pair("v", p ? ",\n" + t.repeat(childD) : ","),
                            pair("d", childD)
                        ));
                    }
                }
                s.add(dict(
                    pair("t", "r"),
                    pair("v", p ? "[\n" + t.repeat(childD) : "["),
                    pair("d", childD)
                ));
                continue;
            }
            if (v.getType() == Type.DICT) {
                HashMap<String, Xl> d = v.toDict();
                if (d.isEmpty()) {
                    r.append("{}");
                    continue;
                }
                int childD = curD + 1;
                s.add(dict(
                    pair("t", "r"),
                    pair("v", p ? "\n" + t.repeat(curD) + "}" : "}"),
                    pair("d", curD)
                ));
                Object[] dkl = d.keySet().toArray();
                for (int i = dkl.length - 1; i >= 0; i -= 1) {
                    String dK = (String) dkl[i];
                    Xl dV = d.get(dK);
                    s.add(dict(
                        pair("t", "v"),
                        pair("v", dV),
                        pair("d", childD)
                    ));
                    s.add(dict(
                        pair("t", "r"),
                        pair("v", p ? "\"" + dK + "\": " : "\"" + dK + "\":"),
                        pair("d", childD)
                    ));
                    if (i > 0) {
                        s.add(dict(
                            pair("t", "r"),
                            pair("v", p ? ",\n" + t.repeat(childD) : ","),
                            pair("d", childD)
                        ));
                    }
                }
                s.add(dict(
                    pair("t", "r"),
                    pair("v", p ? "{\n" + t.repeat(childD) : "{"),
                    pair("d", childD)
                ));
                continue;
            }
            r.append("\"").append(v.getType().toString()).append("\"");
        }
        return r.toString();
    }

    @Override
    public String toString() {
        if (this.type == Type.NONE) return "null";
        return String.valueOf(this.value);
    }
}
