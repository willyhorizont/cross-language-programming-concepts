addpath(fileparts(fullfile({fileparts(mfilename("fullpath"))}{1}, "..", "..", "runtimes", "matlab-or-octave", "willyhorizont", "runtime", "xl.m")));

%{
1. support lambda as value, or has workaround
%}
sayhello = @(callbackfunction) {
    disp("hello"),
    callbackfunction()
}{end};
sayhello(@() {
    disp("world")
}{end});
createmultiplier = @(aa) {@(bb) {aa * bb}{end}}{end};
multiplybytwo = createmultiplier(2);
disp(cstrcat("multiply_by_two(10): ", xl.jsonstringify(multiplybytwo(10))));
multiplybyeight = createmultiplier(8);
disp(cstrcat("multiply_by_eight(4): ", xl.jsonstringify(multiplybyeight(4))));
disp(cstrcat("multiply_by_two(8): ", xl.jsonstringify(multiplybytwo(8))));

%{
2. support dynamic-typed value, or has workaround
%}
xllist = {
    {},
    true,
    false,
    "foo",
    0,
    -123,
    123.789,
    -123.789,
    {1, 2, 3},
    xl.dict("foo", "bar"),
    @(aa, bb) {aa * bb}{end},
};
disp(cstrcat("xl_list: ", xl.jsonstringify(xllist)));
disp(cstrcat("xl_list: ", xl.jsonstringify(xllist, struct("pretty", true))));
xldict = xl.dict( ...
    "xl_none", {}, ...
    "xl_bool_true", true, ...
    "xl_bool_false", false, ...
    "xl_string", "foo", ...
    "xl_int_positive", 0, ...
    "xl_int_negative", -123, ...
    "xl_float_positive", 123.789, ...
    "xl_float_negative", -123.789, ...
    "xl_list", {1, 2, 3}, ...
    "xl_dict", xl.dict("foo", "bar"), ...
    "xl_lambda", @(aa, bb) {aa * bb}{end} ...
);
disp(cstrcat("xl_dict: ", xl.jsonstringify(xldict)));
disp(cstrcat("xl_dict: ", xl.jsonstringify(xldict, struct("pretty", true))));
