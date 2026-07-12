use std::collections::HashMap;
use std::rc::Rc;
pub mod willyhorizont;
use crate::willyhorizont::runtime::Xl;
// use crate::willyhorizont::runtime::xl;

fn main() {
    /*
    1. support closure as value, or has workaround
    */
    let say_hello = Xl::Closure(Rc::new(|va| {
        println!("hello");
        match va.as_slice() {
            [Xl::Closure(callback), ..] => {
                callback(vec![]);
            }
            _ => println!("XlError: Expected Closure."),
        }
        Xl::None
    }));
    say_hello.clone().call(vec![Xl::Closure(Rc::new(|_| {
        println!("world");
        Xl::None
    }))]);
    let create_multiplier = Xl::Closure(Rc::new(|va| {
        match va.as_slice() {
            [Xl::Int(aa), ..] => {
                let aa_v = *aa;
                Xl::Closure(Rc::new(move |va| {
                    match va.as_slice() {
                        [Xl::Int(bb), ..] => Xl::Int(aa_v * bb),
                        _ => Xl::None,
                    }
                }))
            },
            _ => Xl::None,
        }
    }));
    let multiply_by_two = create_multiplier.call(vec![Xl::Int(2)]);
    println!("multiply_by_two(10): {}", multiply_by_two.clone().call(vec![Xl::Int(10)]).to_int());
    let multiply_by_eight = create_multiplier.call(vec![Xl::Int(8)]);
    println!("multiply_by_eight(4): {}", multiply_by_eight.clone().call(vec![Xl::Int(4)]).to_int());
    println!("multiply_by_two(8): {}", multiply_by_two.clone().call(vec![Xl::Int(8)]).to_int());

    /*
    2. support dynamic-typed value, or has workaround
    */
    let xl_list = Xl::List(vec![
        Xl::None,
        Xl::Bool(true),
        Xl::Bool(false),
        Xl::String(String::from("foo")),
        Xl::Int(0),
        Xl::Int(-123),
        Xl::Float(123.789),
        Xl::Float(-123.789),
        Xl::List(vec![Xl::Int(1), Xl::Int(2), Xl::Int(3)]),
        Xl::Dict(HashMap::from([(String::from("foo"), Xl::String(String::from("bar")))])),
        Xl::Closure(Rc::new(|va| {
            match va.as_slice() {
                [Xl::Int(aa), Xl::Int(bb), ..] => Xl::Int(aa * bb),
                _ => Xl::None,
            }
        })),
    ]);
    println!("xl_list: {:?}", xl_list);
    let xl_dict = Xl::Dict(HashMap::from([
        (String::from("xl_null"), Xl::None),
        (String::from("xl_bool_true"), Xl::Bool(true)),
        (String::from("xl_bool_false"), Xl::Bool(false)),
        (String::from("xl_string"), Xl::String(String::from("foo"))),
        (String::from("xl_int_positive"), Xl::Int(0)),
        (String::from("xl_int_negative"), Xl::Int(-123)),
        (String::from("xl_float_positive"), Xl::Float(123.789)),
        (String::from("xl_float_negative"), Xl::Float(-123.789)),
        (String::from("xl_list"), Xl::List(vec![Xl::Int(1), Xl::Int(2), Xl::Int(3)])),
        (String::from("xl_dict"), Xl::Dict(HashMap::from([(String::from("foo"), Xl::String(String::from("bar")))]))),
        (String::from("xl_closure"), Xl::Closure(Rc::new(|va| {
            match va.as_slice() {
                [Xl::Int(aa), Xl::Int(bb), ..] => Xl::Int(aa * bb),
                _ => Xl::None,
            }
        }))),
    ]));
    println!("xl_dict: {:?}", xl_dict);
}
