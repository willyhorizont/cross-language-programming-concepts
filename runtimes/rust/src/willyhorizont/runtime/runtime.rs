use std::fmt;
use std::collections::HashMap;
use std::rc::Rc;

#[derive(Clone)]
pub enum Xl {
    None,
    Bool(bool),
    String(String),
    Int(i128),
    Float(f64),
    List(Vec<Xl>),
    Dict(HashMap<String, Xl>),
    Lambda(Rc<dyn Fn(Vec<Xl>) -> Xl>),
}

impl Xl {
    pub fn call(&self, va: Vec<Xl>) -> Xl {
        match self {
            Xl::Lambda(f) => f(va),
            _ => panic!("XlError: Expected Xl::Lambda."),
        }
    }
    pub fn to_bool(&self) -> bool {
        match self {
            Xl::Bool(v) => *v,
            _ => panic!("XlError: Expected Xl::Bool."),
        }
    }
    pub fn to_string(&self) -> String {
        match self {
            Xl::String(v) => v.clone(),
            _ => panic!("XlError: Expected Xl::String."),
        }
    }
    pub fn to_int(&self) -> i128 {
        match self {
            Xl::Int(v) => *v,
            _ => panic!("XlError: Expected Xl::Int."),
        }
    }
    pub fn to_float(&self) -> f64 {
        match self {
            Xl::Float(v) => *v,
            _ => panic!("XlError: Expected Xl::Float."),
        }
    }
    pub fn to_list(&self) -> Vec<Xl> {
        match self {
            Xl::List(v) => v.clone(),
            _ => panic!("XlError: Expected Xl::List."),
        }
    }
    pub fn to_dict(&self) -> HashMap<String, Xl> {
        match self {
            Xl::Dict(v) => v.clone(),
            _ => panic!("XlError: Expected Xl::Dict."),
        }
    }
    pub fn is_none(&self) -> bool {
        matches!(self, Xl::None)
    }
}

impl fmt::Debug for Xl {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Xl::None => write!(f, "None"),
            Xl::Bool(v) => write!(f, "Bool({})", v),
            Xl::String(v) => write!(f, "String({:?})", v),
            Xl::Int(v) => write!(f, "Int({})", v),
            Xl::Float(v) => write!(f, "Float({})", v),
            Xl::List(v) => write!(f, "List({:?})", v),
            Xl::Dict(v) => write!(f, "Dict({:?})", v),
            Xl::Lambda(_) => write!(f, "Lambda(<fn>)"),
        }
    }
}
