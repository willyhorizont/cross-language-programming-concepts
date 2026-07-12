use crate::willyhorizont::runtime::runtime::Xl;

pub fn json_stringify(value: &Xl) -> String {
    match value {
        Xl::None => "null".to_string(),
        Xl::Bool(v) => v.to_string(),
        Xl::Int(v) => v.to_string(),
        Xl::Float(v) => v.to_string(),
        Xl::String(v) => format!("\"{}\"", v),
        Xl::List(v) => {
            let elemen: Vec<String> = v.iter().map(|x| json_stringify(x)).collect();
            format!("[{}]", elemen.join(","))
        },
        Xl::Dict(v) => {
            let pasang: Vec<String> = v.iter()
                .map(|(k, val)| format!("\"{}\":{}", k, json_stringify(val)))
                .collect();
            format!("{{{}}}", pasang.join(","))
        },
        Xl::Closure(_) => "\"<function>\"".to_string(),
    }
}
