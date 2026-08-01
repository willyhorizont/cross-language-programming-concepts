namespace Willyhorizont.Runtime.Xl {
    namespace Xl {
        public enum Types {
            NONE,
            PRIMITIVE,
            LIST,
            DICTIONARY,
            LAMBDA,
        }
        public class Type : GLib.Object {
            public Type () {}
            public static Type None;
            static construct {
                None = from_none ();
            }
            public Types data_type {
                get;
                set;
            }
            public GLib.Value? value {
                get;
                set;
            }
            public Gee.ArrayList<Type>? list {
                get;
                set;
            }
            public struct Pair {
                public string key;
                public Type value;
                public Pair (string pk, Type pv) {
                    this.key = pk;
                    this.value = pv;
                }
            }
            public Gee.HashMap<string, Type>? dict {
                get;
                set;
            }
            public delegate Type? Lambda (Type args);
            private Lambda? _c;
            public unowned Lambda? to_lambda () {
                return this._c;
            }
            public void set_lambda (owned Lambda c) {
                this._c = (owned) c;
            }
            public Type? call (Type[] args) {
                if (this.data_type == Types.LAMBDA && this._c != null) {
                    return this._c (init_list (args));
                }
                return None;
            }
            public class Iterator : GLib.Object {
                private Gee.ArrayList<Type> _l;
                private int _i;
                public Iterator (Gee.ArrayList<Type> a) {
                    this._l = a;
                    this._i = 0;
                }
                public Type? next () {
                    if (this._i < this._l.size) {
                        var cur_el = this._l.get (this._i);
                        this._i += 1;
                        return cur_el;
                    }
                    return None;
                }
            }
            public Iterator iter () {
                if (this.data_type == Types.LIST && this.list != null) {
                    return new Iterator (this.list);
                }
                error ("XlRuntimeError: Expected List.\n");
            }
            public bool get_bool () {
                return (this.value != null) ? this.value.get_boolean () : false;
            }
            public string get_string () {
                return (this.value != null) ? this.value.get_string () : "";
            }
            public int get_int () {
                return (this.value != null) ? this.value.get_int () : 0;
            }
            public double get_float () {
                return (this.value != null) ? this.value.get_double () : 0.0;
            }
            public static Type repeat (string s, int n) {
                if (n <= 0) {
                    return from_string ("");
                }
                var sb = new StringBuilder ();
                for (int i = 0; i < n; i += 1) {
                    sb.append (s);
                }
                return from_string (sb.str);
            }
        }
        public static Type from_none () {
            var t = new Type ();
            t.data_type = Types.NONE;
            GLib.Value v = GLib.Value (typeof (GLib.Object));
            v.set_object (null);
            t.value = v;
            return t;
        }
        public static Type from_bool (bool a) {
            var t = new Type ();
            t.data_type = Types.PRIMITIVE;
            GLib.Value v = GLib.Value (typeof (bool));
            v.set_boolean (a);
            t.value = v;
            return t;
        }
        public static Type from_string (string a) {
            var t = new Type ();
            t.data_type = Types.PRIMITIVE;
            GLib.Value v = GLib.Value (typeof (string));
            v.set_string (a);
            t.value = v;
            return t;
        }
        public static Type from_int (int a) {
            var t = new Type ();
            t.data_type = Types.PRIMITIVE;
            GLib.Value v = GLib.Value (typeof (int));
            v.set_int (a);
            t.value = v;
            return t;
        }
        public static Type from_float (double a) {
            var t = new Type ();
            t.data_type = Types.PRIMITIVE;
            GLib.Value v = GLib.Value (typeof (double));
            v.set_double (a);
            t.value = v;
            return t;
        }
        public static Type from_list () {
            var t = new Type ();
            t.data_type = Types.LIST;
            t.list = new Gee.ArrayList<Type> ();
            return t;
        }
        public static Type from_dict () {
            var t = new Type ();
            t.data_type = Types.DICTIONARY;
            t.dict = new Gee.HashMap<string, Type> ();
            return t;
        }
        public static Type from_lambda (owned Type.Lambda c) {
            var t = new Type ();
            t.data_type = Types.LAMBDA;
            t.set_lambda ((owned) c);
            return t;
        }
        public static Type from_value (GLib.Value value_data) {
            var t = new Type ();
            t.data_type = Types.PRIMITIVE;
            t.value = value_data;
            return t;
        }
        public static Type init_none () {
            return Type.None;
        }
        public static Type init_bool (bool a) {
            return from_bool (a);
        }
        public static Type init_string (string a) {
            return from_string (a);
        }
        public static Type init_int (int a) {
            return from_int (a);
        }
        public static Type init_float (double a) {
            return from_float (a);
        }
        public static Type init_list (Type[] a) {
            var l = from_list ();
            foreach (var el in a) {
                l.list.add (el);
            }
            return l;
        }
        public static Type.Pair init_pair (string pk, Type pv) {
            return Type.Pair (pk, pv);
        }
        public static Type init_dict (Type.Pair[] a) {
            var d = from_dict ();
            foreach (var p in a) {
                d.dict.set (p.key, p.value);
            }
            return d;
        }
        public static Type init_lambda (owned Type.Lambda c) {
            return from_lambda ((owned) c);
        }
        public static bool is_none (Type a) {
            if (a.data_type == Types.NONE) {
                return true;
            }
            if (a.value != null && a.value.holds (typeof (GLib.Object)) && a.value.get_object () == null) {
                return true;
            }
            return false;
        }
        public static void greet_girl (string gn, bool pretty = false) {
            if (pretty) {
                print (@"Hi pretty, $(gn)!\n");
            } else {
                print (@"Hi $(gn)!\n");
            }
        }
        public static string escape_string (string s) {
            var r = s;
            r = r.replace ("\\", "\\\\");
            r = r.replace ("\"", "\\\"");
            r = r.replace ("\n", "\\n");
            r = r.replace ("\r", "\\r");
            r = r.replace ("\t", "\\t");
            return r;
        }
        private class JifyStkEl : GLib.Object {
            public string t {
                get;
                set;
            }
            public Type? v {
                get;
                set;
            }
            public string r {
                get;
                set;
            }
            public int d {
                get;
                set;
            }
            public JifyStkEl (string t, Type? v, string r, int d) {
                this.t = t;
                this.v = v;
                this.r = r;
                this.d = d;
            }
        }
        public static string json_stringify (Type a, Type.Pair? o = null) {
            var p = (o != null && o.key == "pretty") ? o.value.get_bool () : false;
            var t = Type.repeat (" ", 4).get_string ();
            var s = new Gee.ArrayList<JifyStkEl> ();
            s.add (new JifyStkEl ("v", a, "", 0));
            var r = "";
            while (s.size > 0) {
                var c = s.remove_at (s.size - 1);
                if (c.t == "r") {
                    r += c.r;
                    continue;
                }
                var v = c.v;
                var cur_d = c.d;
                if (v == null || is_none (v)) {
                    r += "null";
                    continue;
                }
                if (v.data_type == Types.PRIMITIVE && v.value != null) {
                    var v_t = v.value.type ();
                    if (v_t == typeof (bool)) {
                        r += v.get_bool () ? "true" : "false";
                        continue;
                    }
                    if (v_t == typeof (string)) {
                        r += "\"" + escape_string (v.get_string ()) + "\"";
                        continue;
                    }
                    if (v_t == typeof (int)) {
                        r += v.get_int ().to_string ();
                        continue;
                    }
                    if (v_t == typeof (double)) {
                        r += v.get_float ().to_string ();
                        continue;
                    }
                }
                if (v.data_type == Types.LAMBDA) {
                    r += "\"[object Function]\"";
                    continue;
                }
                if (v.data_type == Types.LIST && v.list != null) {
                    if (v.list.size == 0) {
                        r += "[]";
                        continue;
                    }
                    var child_d = cur_d + 1;
                    s.add (new JifyStkEl ("r", null, p ? "\n" + Type.repeat (t, cur_d).get_string () + "]" : "]", cur_d));
                    for (int i = v.list.size - 1; i >= 0; i -= 1) {
                        s.add (new JifyStkEl ("v", v.list.get (i), "", child_d));
                        if (i > 0) {
                            s.add (new JifyStkEl ("r", null, p ? ",\n" + Type.repeat (t, child_d).get_string () : ",", child_d));
                        }
                    }
                    s.add (new JifyStkEl ("r", null, p ? "[\n" + Type.repeat (t, child_d).get_string () : "[", child_d));
                    continue;
                }
                if (v.data_type == Types.DICTIONARY && v.dict != null) {
                    if (v.dict.size == 0) {
                        r += "{}";
                        continue;
                    }
                    var child_d = cur_d + 1;
                    s.add (new JifyStkEl ("r", null, p ? "\n" + Type.repeat (t, cur_d).get_string () + "}" : "}", cur_d));
                    var dk_l = new Gee.ArrayList<string> ();
                    foreach (var pk in v.dict.keys) {
                        dk_l.add (pk);
                    }
                    for (int i = dk_l.size - 1; i >= 0; i -= 1) {
                        var pk = dk_l.get (i);
                        var pv = v.dict.get (pk);
                        s.add (new JifyStkEl ("v", pv, "", child_d));
                        s.add (new JifyStkEl ("r", null, p ? "\"" + pk + "\": " : "\"" + pk + "\":", child_d));
                        if (i > 0) {
                            s.add (new JifyStkEl ("r", null, p ? ",\n" + Type.repeat (t, child_d).get_string () : ",", child_d));
                        }
                    }
                    s.add (new JifyStkEl ("r", null, p ? "{\n" + Type.repeat (t, child_d).get_string () : "{", child_d));
                    continue;
                }
                r += "\"[object Object]\"";
            }
            return r;
        }
    }
}
