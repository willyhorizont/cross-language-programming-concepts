using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace WillyHorizont.Runtime
{
    public static class Xl
    {
        private static string EscapeString(dynamic S)
        {
            if (S == null) return "";
            string R = Convert.ToString(S);
            R = R.Replace("\\", "\\\\");
            R = R.Replace("\"", "\\\"");
            R = R.Replace("\n", "\\n");
            R = R.Replace("\r", "\\r");
            R = R.Replace("\t", "\\t");
            return R;
        }
        public static dynamic JsonStringify(dynamic O, dynamic Pretty = null)
        {
            bool P = Pretty != null && Convert.ToBoolean(Pretty);
            string T = string.Concat(Enumerable.Repeat(" ", 4));
            var S = new Stack<Dictionary<string, dynamic>>();
            S.Push(new Dictionary<string, dynamic> {{ "t", "v" }, { "v", O }, { "d", 0 }});
            string R = "";
            while (S.Count > 0)
            {
                var C = S.Pop();
                if (Convert.ToString(C["t"]) == "r")
                {
                    R += Convert.ToString(C["v"]);
                    continue;
                }
                dynamic V = C["v"];
                int CurD = Convert.ToInt32(C["d"]);
                if (V == null)
                {
                    R += "null";
                    continue;
                }
                Type Vt = V.GetType();
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
                if (typeof(MulticastDelegate).IsAssignableFrom(Vt) || Vt.BaseType == typeof(MulticastDelegate))
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
                    int ChildD = CurD + 1;
                    string CurT = string.Concat(Enumerable.Repeat(" ", CurD * 4));
                    string ChildT = string.Concat(Enumerable.Repeat(" ", ChildD * 4));
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
                    int ChildD = CurD + 1;
                    string CurT = string.Concat(Enumerable.Repeat(" ", CurD * 4));
                    string ChildT = string.Concat(Enumerable.Repeat(" ", ChildD * 4));
                    S.Push(new Dictionary<string, dynamic>
                    {
                        { "t", "r" },
                        { "v", P ? "\n" + CurT + "}" : "}" },
                        { "d", CurD }
                    });
                    var Dk = new List<dynamic>(((IDictionary)Vd).Keys.Cast<dynamic>());
                    var Dv = new List<dynamic>(((IDictionary)Vd).Values.Cast<dynamic>());
                    for (int i = Vd.Count - 1; i >= 0; i -= 1)
                    {
                        S.Push(new Dictionary<string, dynamic>
                        {
                            { "t", "v" },
                            { "v", Dv[i] },
                            { "d", ChildD }
                        });
                        S.Push(new Dictionary<string, dynamic>
                        {
                            { "t", "r" },
                            { "v", P ? "\"" + Convert.ToString(Dk[i]) + "\": " : "\"" + Convert.ToString(Dk[i]) + "\":" },
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
