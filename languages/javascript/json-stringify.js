const WillyHorizont = require("willyhorizont.github.io");
const { jsonStringify } = WillyHorizont.Utils;

const somePythonLikeList = [
    null,
    true,
    false,
    "foo",
    123,
    -123,
    123.789,
    -123.789,
    [1, 2, 3],
    { "foo": "bar" },
    (a, b) => (a * b),
];
console.log(`somePythonLikeList: ${jsonStringify(somePythonLikeList)}`);
console.log(`somePythonLikeList: ${jsonStringify(somePythonLikeList, { pretty: true })}`);
const somePythonLikeDict = {
    "some_null": null,
    "some_boolean_true": true,
    "some_boolean_false": false,
    "some_string": "foo",
    "some_int_positive": 123,
    "some_int_negative": -123,
    "some_float_positive": 123.789,
    "some_float_negative": -123.789,
    "some_python_like_list": [1, 2, 3],
    "some_python_like_dict": { "foo": "bar" },
    "some_function": (a, b) => (a * b),
};
console.log(`somePythonLikeDict: ${jsonStringify(somePythonLikeDict)}`);
console.log(`somePythonLikeDict: ${jsonStringify(somePythonLikeDict, { pretty: true })}`);

const deeplyNestedPythonLikeDict = {
    "name": "Alice",
    "details": {
        "age": 30,
        "address": {
            "street": "123 Main St",
            "city": "Wonderland",
            "coordinates": {
                "lat": 51.5074,
                "long": -0.1278
            }
        },
        "phones": [
            "+1234567890",
            "+0987654321"
        ]
    },
    "preferences": {
        "colors": [
            "red",
            "blue",
            "green"
        ],
        "notifications": {
            "email": true,
            "sms": false,
            "push": {
                "enabled": true,
                "frequency": "daily"
            }
        }
    },
    "projects": [
        {
            "id": 1,
            "name": "Project Alpha",
            "tasks": [
                {
                    "task_id": 101,
                    "task_name": "Design",
                    "completed": false
                },
                {
                    "task_id": 102,
                    "task_name": "Development",
                    "completed": true
                }
            ]
        },
        {
            "id": 2,
            "name": "Project Beta",
            "tasks": [
                {
                    "task_id": 201,
                    "task_name": "Planning",
                    "completed": true
                },
                {
                    "task_id": 202,
                    "task_name": "Execution",
                    "completed": false
                }
            ]
        }
    ],
    "meta": {
        "created_at": "2025-02-11T10:00:00Z",
        "updated_at": null
    }
}
console.log(jsonStringify(deeplyNestedPythonLikeDict, { pretty: true }));
