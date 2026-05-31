import sys, json;

asd='''[
    null,
    true,
    false,
    "foo",
    123,
    -123,
    123.789,    
    -123.789,
    [1, 2, 3],
    { "foo": "bar" }
]'''
print(json.dumps(json.loads(asd), indent=4))

s = '''[
        null,
        true,
        false,
        "foo"
    ]'''
d = json.loads(s)
print(d)