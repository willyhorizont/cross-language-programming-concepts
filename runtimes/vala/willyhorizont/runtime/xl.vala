namespace Willyhorizont.Runtime.Xl {
    namespace Xl {
        public static void welcome () {
            print (GLib.Environment.get_variable ("SEP") ?? "");
        }
        public enum Types {
            XL_NONE,
            XL_BASE,
            XL_LIST,
            XL_DICT,
            XL_LAMBDA,
        }
        public class Type : GLib.Object {
            public Type () {}
            public static Type NONE;
            public static Type TRUE;
            public static Type FALSE;
            static construct {
                welcome();
                NONE = from_none ();
                TRUE = from_bool (true);
                FALSE = from_bool (false);
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
                if (this.data_type == Types.XL_LAMBDA && this._c != null) return this._c (init_list (args));
                return NONE;
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
                    return NONE;
                }
            }
            public Iterator iter () {
                if (this.data_type == Types.XL_LIST && this.list != null) return new Iterator (this.list);
                error ("XlRuntimeError: Expected List.\n");
            }
            public bool to_bool () {
                return (this.value != null && this.value.holds (typeof (bool))) ? this.value.get_boolean () : false;
            }
            public string to_string () {
                return (this.value != null && this.value.holds (typeof (string))) ? this.value.get_string () : "";
            }
            public int to_int () {
                return (this.value != null && this.value.holds (typeof (int))) ? this.value.get_int () : 0;
            }
            public double to_float () {
                return (this.value != null && this.value.holds (typeof (double))) ? this.value.get_double () : 0.0;
            }
            public Type? at (int i) {
                if (this.data_type == Types.XL_LIST && this.list != null) {
                    if (i >= 0 && i < this.list.size) return this.list.get (i);
                    return NONE;
                }
                error ("XlRuntimeError: Expected List.\n");
            }
            public void push (Type el) {
                if (this.data_type == Types.XL_LIST && this.list != null) {
                    this.list.add (el);
                    return;
                }
                error ("XlRuntimeError: Expected List.\n");
            }
            public Type? pop () {
                if (this.data_type == Types.XL_LIST && this.list != null) {
                    if (this.list.size > 0) {
                        return this.list.remove_at (this.list.size - 1);
                    }
                    return NONE;
                }
                error ("XlRuntimeError: Expected List.\n");
            }
            public new Type? get_item (string key) {
                if (this.data_type == Types.XL_DICT && this.dict != null) {
                    if (this.dict.has_key (key)) return this.dict.get (key);
                    return NONE;
                }
                error ("XlRuntimeError: Expected Dictionary.\n");
            }
            public Type repeat (int n) {
                string s = this.to_string(); 
                if (n <= 0) return from_string ("");
                var sb = new StringBuilder ();
                for (var i = 0; i < n; i += 1) {
                    sb.append (s);
                }
                return from_string (sb.str);
            }
        }
        public static Type from_none () {
            var t = new Type ();
            t.data_type = Types.XL_NONE;
            GLib.Value v = GLib.Value (typeof (GLib.Object));
            v.set_object (null);
            t.value = v;
            return t;
        }
        public static Type from_bool (bool a) {
            var t = new Type ();
            t.data_type = Types.XL_BASE;
            GLib.Value v = GLib.Value (typeof (bool));
            v.set_boolean (a);
            t.value = v;
            return t;
        }
        public static Type from_string (string a) {
            var t = new Type ();
            t.data_type = Types.XL_BASE;
            GLib.Value v = GLib.Value (typeof (string));
            v.set_string (a);
            t.value = v;
            return t;
        }
        public static Type from_int (int a) {
            var t = new Type ();
            t.data_type = Types.XL_BASE;
            GLib.Value v = GLib.Value (typeof (int));
            v.set_int (a);
            t.value = v;
            return t;
        }
        public static Type from_float (double a) {
            var t = new Type ();
            t.data_type = Types.XL_BASE;
            GLib.Value v = GLib.Value (typeof (double));
            v.set_double (a);
            t.value = v;
            return t;
        }
        public static Type from_list () {
            var t = new Type ();
            t.data_type = Types.XL_LIST;
            t.list = new Gee.ArrayList<Type> ();
            return t;
        }
        public static Type from_dict () {
            var t = new Type ();
            t.data_type = Types.XL_DICT;
            t.dict = new Gee.HashMap<string, Type> ();
            return t;
        }
        public static Type from_lambda (owned Type.Lambda c) {
            var t = new Type ();
            t.data_type = Types.XL_LAMBDA;
            t.set_lambda ((owned) c);
            return t;
        }
        public static Type from_value (GLib.Value a) {
            var t = new Type ();
            t.data_type = Types.XL_BASE;
            t.value = a;
            return t;
        }
        public static Type init_none () {
            return Type.NONE;
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
            if (a.data_type == Types.XL_NONE) return true;
            if (a.value != null && a.value.holds (typeof (GLib.Object)) && a.value.get_object () == null) return true;
            return false;
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
        public static string json_stringify (Type a, Type.Pair? o = null) {
            var p = (o != null && o.key == "pretty") ? o.value.to_bool () : false;
            var t = init_string(" ").repeat(4);
            var s = init_list ({ init_dict ({ init_pair ("t", init_string ("v")), init_pair ("v", a), init_pair ("r", init_string ("")), init_pair ("d", init_int (0)) }) });
            var r = "";
            while (s.list.size > 0) {
                var c = s.pop ();
                if (c.get_item ("t").to_string () == "r") {
                    r += c.get_item ("r").to_string ();
                    continue;
                }
                var v = c.get_item ("v");
                var cur_d = c.get_item ("d").to_int ();
                if (v == null || is_none (v)) {
                    r += "null";
                    continue;
                }
                if (v.data_type == Types.XL_BASE && v.value != null) {
                    var v_t = v.value.type ();
                    if (v_t == typeof (bool)) {
                        r += v.to_bool () ? "true" : "false";
                        continue;
                    }
                    if (v_t == typeof (string)) {
                        r += "\"" + escape_string (v.to_string ()) + "\"";
                        continue;
                    }
                    if (v_t == typeof (int)) {
                        r += v.to_int ().to_string ();
                        continue;
                    }
                    if (v_t == typeof (double)) {
                        r += v.to_float ().to_string ();
                        continue;
                    }
                }
                if (v.data_type == Types.XL_LAMBDA) {
                    r += "\"[object Function]\"";
                    continue;
                }
                if (v.data_type == Types.XL_LIST && v.list != null) {
                    if (v.list.size == 0) {
                        r += "[]";
                        continue;
                    }
                    var child_d = cur_d + 1;
                    s.push (init_dict ({
                        init_pair ("t", init_string ("r")),
                        init_pair ("v", init_none ()),
                        init_pair ("r", init_string (p ? "\n" + t.repeat (cur_d).to_string () + "]" : "]")),
                        init_pair ("d", init_int (cur_d)),
                    }));
                    for (var i = v.list.size - 1; i >= 0; i -= 1) {
                        s.push (init_dict ({
                            init_pair ("t", init_string ("v")),
                            init_pair ("v", v.list.get (i)),
                            init_pair ("r", init_string ("")),
                            init_pair ("d", init_int (child_d)),
                        }));
                        if (i > 0) {
                            s.push (init_dict ({
                                init_pair ("t", init_string ("r")),
                                init_pair ("v", init_none ()),
                                init_pair ("r", init_string (p ? ",\n" + t.repeat (child_d).to_string () : ",")),
                                init_pair ("d", init_int (child_d)),
                            }));
                        }
                    }
                    s.push (init_dict ({
                        init_pair ("t", init_string ("r")),
                        init_pair ("v", init_none ()),
                        init_pair ("r", init_string (p ? "[\n" + t.repeat (child_d).to_string () : "[")),
                        init_pair ("d", init_int (child_d)),
                    }));
                    continue;
                }
                if (v.data_type == Types.XL_DICT && v.dict != null) {
                    if (v.dict.size == 0) {
                        r += "{}";
                        continue;
                    }
                    var child_d = cur_d + 1;
                    s.push (init_dict ({
                        init_pair ("t", init_string ("r")),
                        init_pair ("v", init_none ()),
                        init_pair ("r", init_string (p ? "\n" + t.repeat (cur_d).to_string () + "}" : "}")),
                        init_pair ("d", init_int (cur_d)),
                    }));
                    var dk_l = new Gee.ArrayList<string> ();
                    foreach (var pk in v.dict.keys) {
                        dk_l.add (pk);
                    }
                    for (var i = dk_l.size - 1; i >= 0; i -= 1) {
                        var pk = dk_l.get (i);
                        var pv = v.dict.get (pk);
                        s.push (init_dict ({
                            init_pair ("t", init_string ("v")),
                            init_pair ("v", pv),
                            init_pair ("r", init_string ("")),
                            init_pair ("d", init_int (child_d)),
                        }));
                        s.push (init_dict ({
                            init_pair ("t", init_string ("r")),
                            init_pair ("v", init_none ()),
                            init_pair ("r", init_string (p ? "\"" + pk + "\": " : "\"" + pk + "\":")),
                            init_pair ("d", init_int (child_d)),
                        }));
                        if (i > 0) {
                            s.push (init_dict ({
                                init_pair ("t", init_string ("r")),
                                init_pair ("v", init_none ()),
                                init_pair ("r", init_string (p ? ",\n" + t.repeat (child_d).to_string () : ",")),
                                init_pair ("d", init_int (child_d)),
                            }));
                        }
                    }
                    s.push (init_dict ({
                        init_pair ("t", init_string ("r")),
                        init_pair ("v", init_none ()),
                        init_pair ("r", init_string (p ? "{\n" + t.repeat (child_d).to_string () : "{")),
                        init_pair ("d", init_int (child_d)),
                    }));
                    continue;
                }
                r += "\"[object Object]\"";
            }
            return r;
        }
    }
}
