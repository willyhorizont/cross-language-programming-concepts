using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace WillyHorizont.Runtime.Xl
{
    public static class Xl
    {
        public class List : List<dynamic>
        {
            public List() : base()
            {
            }
            public List(IEnumerable<dynamic> l) : base(l)
            {
            }
        }
        public class Dict : Dictionary<string, dynamic>
        {
            public Dict() : base()
            {
            }
        }
        public class Lambda
        {
            private readonly Func<dynamic[], dynamic> value;
            public Lambda(Func<dynamic[], dynamic> c)
            {
                this.value = c;
            }
            public static implicit operator Lambda(Func<dynamic[], dynamic> c)
            {
                return new Lambda(c);
            }
            public static implicit operator Lambda(Action<dynamic[]> c)
            {
                return new Lambda(delegate (dynamic[] Va)
                {
                    c(Va);
                    return null;
                });
            }
            public dynamic Call(params dynamic[] Va)
            {
                if (Va == null)
                {
                    return this.value(new dynamic[] { null });
                }
                return this.value(Va);
            }
        }
        public static List InitList(params dynamic[] el)
        {
            var l = new List();
            if (el != null) l.AddRange(el);
            return l;
        }
        public static Dict InitDict(params (string Key, dynamic Value)[] el)
        {
            var d = new Dict();
            if (el != null)
            {
                foreach (var p in el) d[p.Key] = p.Value;
            }
            return d;
        }
        public static Lambda InitLambda(Func<dynamic[], dynamic> c)
        {
            return new Lambda(c);
        }
        public static Lambda InitLambda(Action<dynamic[]> c)
        {
            return new Lambda(delegate (dynamic[] Va)
            {
                c(Va);
                return null;
            });
        }
        public static dynamic Iter(dynamic[] Va)
        {
            return Va.GetEnumerator();
        }
        public static dynamic Next(System.Collections.IEnumerator Itr)
        {
            Itr.MoveNext();
            return Itr.Current;
        }
        private static dynamic EscapeString(dynamic S)
        {
            if (S == null) return "";
            dynamic R = Convert.ToString(S);
            R = R.Replace("\\", "\\\\");
            R = R.Replace("\"", "\\\"");
            R = R.Replace("\n", "\\n");
            R = R.Replace("\r", "\\r");
            R = R.Replace("\t", "\\t");
            return R;
        }
        public static dynamic JsonStringify(dynamic A, dynamic Pretty = null)
        {
            dynamic P = Pretty != null && Convert.ToBoolean(Pretty);
            dynamic T = string.Concat(Enumerable.Repeat(" ", 4));
            dynamic S = new Stack<Dictionary<string, dynamic>>(new Dictionary<string, dynamic>[]{new Dictionary<string, dynamic> { { "t", "v" }, { "v", A }, { "d", 0 } }});
            dynamic R = "";
            while (S.Count > 0)
            {
                dynamic C = S.Pop();
                if (Convert.ToString(C["t"]) == "r")
                {
                    R += Convert.ToString(C["v"]);
                    continue;
                }
                dynamic V = C["v"];
                dynamic CurD = Convert.ToInt32(C["d"]);
                if (V == null)
                {
                    R += "null";
                    continue;
                }
                dynamic Vt = V.GetType();
                if (Vt == typeof(bool))
                {
                    R += V ? "true" : "false";
                    continue;
                }
                if (Vt == typeof(string))
                {
                    R += "\"" + EscapeString(V) + "\"";
                    continue;
                }
                if (Vt == typeof(int) || Vt == typeof(double) || Vt == typeof(decimal) || Vt == typeof(long))
                {
                    R += V.ToString();
                    continue;
                }
                if ((typeof(MulticastDelegate).IsAssignableFrom(Vt) || Vt.BaseType == typeof(MulticastDelegate)) || (typeof(Lambda).IsAssignableFrom(Vt) || Vt.BaseType == typeof(Lambda)))
                {
                    R += "\"[object Function]\"";
                    continue;
                }
                if (V is IList Vl)
                {
                    if (Vl.Count == 0)
                    {
                        R += "[]";
                        continue;
                    }
                    dynamic ChildD = CurD + 1;
                    dynamic CurT = string.Concat(Enumerable.Repeat(" ", CurD * 4));
                    dynamic ChildT = string.Concat(Enumerable.Repeat(" ", ChildD * 4));
                    S.Push(new Dictionary<string, dynamic>
                    {
                        { "t", "r" },
                        { "v", P ? "\n" + CurT + "]" : "]" },
                        { "d", CurD }
                    });
                    for (int i = Vl.Count - 1; i >= 0; i -= 1)
                    {
                        S.Push(new Dictionary<string, dynamic>
                        {
                            { "t", "v" },
                            { "v", Vl[i] },
                            { "d", ChildD }
                        });
                        if (i > 0)
                        {
                            S.Push(new Dictionary<string, dynamic>
                            {
                                { "t", "r" },
                                { "v", P ? ",\n" + ChildT : "," },
                                { "d", ChildD }
                            });
                        }
                    }
                    S.Push(new Dictionary<string, dynamic>
                    {
                        { "t", "r" },
                        { "v", P ? "[\n" + ChildT : "[" },
                        { "d", ChildD }
                    });
                    continue;
                }
                if (V is IDictionary Vd)
                {
                    if (Vd.Count == 0)
                    {
                        R += "{}";
                        continue;
                    }
                    dynamic ChildD = CurD + 1;
                    dynamic CurT = string.Concat(Enumerable.Repeat(" ", CurD * 4));
                    dynamic ChildT = string.Concat(Enumerable.Repeat(" ", ChildD * 4));
                    S.Push(new Dictionary<string, dynamic>
                    {
                        { "t", "r" },
                        { "v", P ? "\n" + CurT + "}" : "}" },
                        { "d", CurD }
                    });
                    dynamic Pk = new List<dynamic>(((IDictionary)Vd).Keys.Cast<dynamic>());
                    dynamic Pv = new List<dynamic>(((IDictionary)Vd).Values.Cast<dynamic>());
                    for (int i = Vd.Count - 1; i >= 0; i -= 1)
                    {
                        S.Push(new Dictionary<string, dynamic>
                        {
                            { "t", "v" },
                            { "v", Pv[i] },
                            { "d", ChildD }
                        });
                        S.Push(new Dictionary<string, dynamic>
                        {
                            { "t", "r" },
                            { "v", P ? "\"" + Convert.ToString(Pk[i]) + "\": " : "\"" + Convert.ToString(Pk[i]) + "\":" },
                            { "d", ChildD }
                        });
                        if (i > 0)
                        {
                            S.Push(new Dictionary<string, dynamic>
                            {
                                { "t", "r" },
                                { "v", P ? ",\n" + ChildT : "," },
                                { "d", ChildD }
                            });
                        }
                    }
                    S.Push(new Dictionary<string, dynamic>
                    {
                        { "t", "r" },
                        { "v", P ? "{\n" + ChildT : "{" },
                        { "d", ChildD }
                    });
                    continue;
                }
                R += "\"" + Vt.Name + "\"";
            }
            return R;
        }
    }
}
