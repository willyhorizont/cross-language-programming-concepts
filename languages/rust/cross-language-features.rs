pub mod willyhorizont;
use crate::willyhorizont::runtime::Xl;
use crate::willyhorizont::runtime::xl;

fn main() {
    /*
    1. support closure as value, or has workaround
    */
    let say_hello = xl::closure!(|va| {
        println!("hello");
        match va.as_slice() {
            [Xl::Closure(callback), ..] => {
                callback(vec![]);
            }
            _ => println!("XlError: Expected Xl::Closure."),
        }
        xl::NONE
    });
    say_hello.clone().call(vec![xl::closure!(|_| {
        println!("world");
        xl::NONE
    })]);
    let create_multiplier = xl::closure!(|va| {
        match va.as_slice() {
            [Xl::Int(aa), ..] => {
                let aa_ctx = *aa;
                xl::closure!(move |va| {
                    match va.as_slice() {
                        [Xl::Int(bb), ..] => xl::int!(aa_ctx * bb),
                        _ => xl::NONE,
                    }
                })
            },
            _ => xl::NONE,
        }
    });
    let multiply_by_two = create_multiplier.call(vec![xl::int!(2)]);
    println!("multiply_by_two(10): {}", multiply_by_two.clone().call(vec![xl::int!(10)]).to_int());
    let multiply_by_eight = create_multiplier.call(vec![xl::int!(8)]);
    println!("multiply_by_eight(4): {}", multiply_by_eight.clone().call(vec![xl::int!(4)]).to_int());
    println!("multiply_by_two(8): {}", multiply_by_two.clone().call(vec![xl::int!(8)]).to_int());

    /*
    2. support dynamic-typed value, or has workaround
    */
    let xl_list = xl::list![
        xl::NONE,
        xl::TRUE,
        xl::FALSE,
        xl::string!("foo"),
        xl::int!(0),
        xl::int!(-123),
        xl::float!(123.789),
        xl::float!(-123.789),
        xl::list![xl::int!(1), xl::int!(2), xl::int!(3)],
        xl::dict! { "foo" => xl::string!("bar") },
        xl::closure!(|va| {
            match va.as_slice() {
                [Xl::Int(aa), Xl::Int(bb), ..] => xl::int!(aa * bb),
                _ => xl::NONE,
            }
        }),
    ];
    println!("xl_list: {}", xl::json_stringify!(&xl_list));
    println!("xl_list: {}", xl::json_stringify!(&xl_list, xl::dict! { "pretty" => xl::TRUE }));
    let xl_dict = xl::dict! {
        "xl_null" => xl::NONE,
        "xl_bool_true" => xl::TRUE,
        "xl_bool_false" => xl::FALSE,
        "xl_string" => xl::string!("foo"),
        "xl_int_positive" => xl::int!(0),
        "xl_int_negative" => xl::int!(-123),
        "xl_float_positive" => xl::float!(123.789),
        "xl_float_negative" => xl::float!(-123.789),
        "xl_list" => xl::list![xl::int!(1), xl::int!(2), xl::int!(3)],
        "xl_dict" => xl::dict! { "foo" => xl::string!("bar") },
        "xl_closure" => xl::closure!(|va| {
            match va.as_slice() {
                [Xl::Int(aa), Xl::Int(bb), ..] => xl::int!(aa * bb),
                _ => xl::NONE,
            }
        }),
    };
    println!("xl_dict: {}", xl::json_stringify!(&xl_dict));
    println!("xl_dict: {}", xl::json_stringify!(&xl_dict, xl::dict! { "pretty" => xl::TRUE }));
}
