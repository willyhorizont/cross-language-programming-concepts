use crate::willyhorizont::runtime::runtime::Xl;

pub const NONE: Xl = Xl::None;
pub const TRUE: Xl = Xl::Bool(true);
pub const FALSE: Xl = Xl::Bool(false);

#[macro_export]
macro_rules! xl_string {
    ($v:expr) => {
        $crate::willyhorizont::runtime::runtime::Xl::String(String::from($v))
    };
}
pub use xl_string as string;

#[macro_export]
macro_rules! xl_list {
    ( $( $el:expr ),* $(,)? ) => {
        $crate::willyhorizont::runtime::runtime::Xl::List(vec![ $( $el ),* ])
    };
}
pub use xl_list as list;

#[macro_export]
macro_rules! xl_dict {
    ( $( $k:expr => $v:expr ),* $(,)? ) => {{
        let mut _d = std::collections::HashMap::new();
        $(
            _d.insert(String::from($k), $v);
        )*
        $crate::willyhorizont::runtime::runtime::Xl::Dict(_d)
    }};
}
pub use xl_dict as dict;

#[macro_export]
macro_rules! xl_closure {
    ($c:expr) => {
        $crate::willyhorizont::runtime::runtime::Xl::Closure(std::rc::Rc::new($c))
    };
}
pub use xl_closure as closure;

#[macro_export]
macro_rules! xl_none {
    () => {
        $crate::willyhorizont::runtime::runtime::Xl::None
    };
}
pub use xl_none as none;

#[macro_export]
macro_rules! xl_bool {
    ($v:expr) => {
        $crate::willyhorizont::runtime::runtime::Xl::Bool($v)
    };
}
pub use xl_bool as bool;

#[macro_export]
macro_rules! xl_int {
    ($v:expr) => {
        $crate::willyhorizont::runtime::runtime::Xl::Int($v)
    };
}
pub use xl_int as int;

#[macro_export]
macro_rules! xl_float {
    ($v:expr) => {
        $crate::willyhorizont::runtime::runtime::Xl::Float($v)
    };
}
pub use xl_float as float;

enum JifyStkEl<'a> {
    V { v: &'a Xl, d: usize },
    R { v: String },
}

pub(crate) fn jify(a: &Xl, o: &Xl) -> String {
    let mut p = false;
    if let Xl::Dict(od) = o {
        if let Some(Xl::Bool(is_p)) = od.get("pretty") {
            p = *is_p;
        }
    }
    let t = " ".repeat(4);
    let mut s: Vec<JifyStkEl> = vec![JifyStkEl::V { v: a, d: 0 }];
    let mut r = String::new();
    while let Some(c) = s.pop() {
        match c {
            JifyStkEl::R { v } => {
                r.push_str(&v);
            }
            JifyStkEl::V { v, d } => {
                match v {
                    Xl::None => r.push_str("null"),
                    Xl::Bool(v) => r.push_str(if *v { "true" } else { "false" }),
                    Xl::String(v) => {
                        r.push_str("\"");
                        r.push_str(v);
                        r.push_str("\"");
                    }
                    Xl::Int(v) => r.push_str(&v.to_string()),
                    Xl::Float(v) => r.push_str(&v.to_string()),
                    Xl::Closure(_) => r.push_str("\"[object Function]\""),
                    Xl::List(v) => {
                        if v.is_empty() {
                            r.push_str("[]");
                            continue;
                        }
                        let child_d = d + 1;
                        s.push(JifyStkEl::R {
                            v: (if p {
                                    format!("\n{}]", t.repeat(d))
                                } else {
                                    "]".to_string()
                                }),
                        });
                        for i in (0..v.len()).rev() {
                            s.push(JifyStkEl::V {
                                v: &v[i],
                                d: child_d
                            });
                            if i > 0 {
                                s.push(JifyStkEl::R {
                                    v: (if p {
                                            format!(",\n{}", t.repeat(child_d))
                                        } else {
                                            ",".to_string()
                                        }),
                                });
                            }
                        }
                        s.push(JifyStkEl::R {
                            v: (if p {
                                    format!("[\n{}", t.repeat(child_d))
                                } else {
                                    "[".to_string()
                                }),
                        });
                    }
                    Xl::Dict(v) => {
                        if v.is_empty() {
                            r.push_str("{}");
                            continue;
                        }
                        let child_d = d + 1;
                        s.push(JifyStkEl::R {
                            v: (if p {
                                    format!("\n{}{}", t.repeat(d), "}")
                                } else {
                                    "}".to_string()
                                }),
                        });
                        let dp_l: Vec<(&String, &Xl)> = v.iter().collect();
                        for i in (0..dp_l.len()).rev() {
                            let (d_k, d_v) = dp_l[i];
                            s.push(JifyStkEl::V {
                                v: d_v,
                                d: child_d
                            });
                            s.push(JifyStkEl::R {
                                v: (if p {
                                        format!("\"{}\": ", d_k)
                                    } else {
                                        format!("\"{}\":", d_k)
                                    }),
                            });
                            if i > 0 {
                                s.push(JifyStkEl::R {
                                    v: (if p {
                                            format!(",\n{}", t.repeat(child_d))
                                        } else {
                                            ",".to_string()
                                        }),
                                });
                            }
                        }
                        s.push(JifyStkEl::R {
                            v: (if p {
                                    format!("{}{}\n{}", "{", "", t.repeat(child_d))
                                } else {
                                    "{".to_string()
                                }),
                        });
                    }
                }
            }
        }
    }
    r
}

#[macro_export]
macro_rules! json_stringify {
    ($v:expr) => {
        $crate::willyhorizont::runtime::xl::jify($v, &$crate::willyhorizont::runtime::xl::NONE)
    };
    ($v:expr, $o:expr) => {
        $crate::willyhorizont::runtime::xl::jify($v, &$o)
    };
}
pub use json_stringify as json_stringify;
