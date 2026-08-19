pub mod willyhorizont;
use crate::willyhorizont::runtime::Xl;
use crate::willyhorizont::runtime::xl;

fn main() {
    /*
    1. support lambda as value, or has workaround
    */
    let say_hello = xl::init_lambda!(|va| {
        println!("hello");
        match va.as_slice() {
            [Xl::Lambda(callback), ..] => {
                callback(vec![]);
            }
            _ => panic!("Error: Invalid arguments."),
        }
        xl::NONE
    });
    say_hello.clone().call(vec![xl::init_lambda!(|_| {
        println!("world");
        xl::NONE
    })]);
    let create_multiplier = xl::init_lambda!(|va| {
        match va.as_slice() {
            [Xl::Int(aa), ..] => {
                let aa_ctx = *aa;
                xl::init_lambda!(move |va| {
                    match va.as_slice() {
                        [Xl::Int(bb), ..] => xl::init_int!(aa_ctx * bb),
                        _ => panic!("Error: Invalid arguments."),
                    }
                })
            },
            _ => panic!("Error: Invalid arguments."),
        }
    });
    let multiply_by_two = create_multiplier.call(vec![xl::init_int!(2)]);
    println!("multiply_by_two(10): {}", multiply_by_two.clone().call(vec![xl::init_int!(10)]).to_int());
    let multiply_by_eight = create_multiplier.call(vec![xl::init_int!(8)]);
    println!("multiply_by_eight(4): {}", multiply_by_eight.clone().call(vec![xl::init_int!(4)]).to_int());
    println!("multiply_by_two(8): {}", multiply_by_two.clone().call(vec![xl::init_int!(8)]).to_int());

    /*
    2. support dynamic-typed value, or has workaround
    */
    let xl_list = xl::init_list![
        xl::NONE,
        xl::TRUE,
        xl::FALSE,
        xl::init_string!("foo"),
        xl::init_int!(0),
        xl::init_int!(-123),
        xl::init_float!(123.789),
        xl::init_float!(-123.789),
        xl::init_list![xl::init_int!(1), xl::init_int!(2), xl::init_int!(3)],
        xl::init_dict! { "foo" => xl::init_string!("bar") },
        xl::init_lambda!(|va| {
            match va.as_slice() {
                [Xl::Int(aa), Xl::Int(bb), ..] => xl::init_int!(aa * bb),
                _ => panic!("Error: Invalid arguments."),
            }
        }),
    ];
    println!("xl_list: {}", xl::json_stringify!(&xl_list));
    println!("xl_list: {}", xl::json_stringify!(&xl_list, xl::init_dict! { "pretty" => xl::TRUE }));
    let xl_dict = xl::init_dict! {
        "xl_null" => xl::NONE,
        "xl_bool_true" => xl::TRUE,
        "xl_bool_false" => xl::FALSE,
        "xl_string" => xl::init_string!("foo"),
        "xl_int_positive" => xl::init_int!(0),
        "xl_int_negative" => xl::init_int!(-123),
        "xl_float_positive" => xl::init_float!(123.789),
        "xl_float_negative" => xl::init_float!(-123.789),
        "xl_list" => xl::init_list![xl::init_int!(1), xl::init_int!(2), xl::init_int!(3)],
        "xl_dict" => xl::init_dict! { "foo" => xl::init_string!("bar") },
        "xl_lambda" => xl::init_lambda!(|va| {
            match va.as_slice() {
                [Xl::Int(aa), Xl::Int(bb), ..] => xl::init_int!(aa * bb),
                _ => panic!("Error: Invalid arguments."),
            }
        }),
    };
    println!("xl_dict: {}", xl::json_stringify!(&xl_dict));
    println!("xl_dict: {}", xl::json_stringify!(&xl_dict, xl::init_dict! { "pretty" => xl::TRUE }));
}
