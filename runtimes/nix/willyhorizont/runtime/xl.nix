{ ... }:

let

do = va:
    builtins.foldl'
        (acc: v:
        let
            r = v acc;
        in
            builtins.deepSeq r r
        )
        { }
        va;

escapeString = s:
    if s == "" then ""
    else builtins.replaceStrings
        ["\\" "\"" "\n" "\r" "\t"]
        ["\\\\" "\\\"" "\\n" "\\r" "\\t"]
        s;

ifThenElse = cond: fT: dF: ctx:
    if cond ctx
    then fT ctx
    else dF ctx;

while = cond: cb: ctx:
    if cond ctx
    then
        let
            nextCtx = cb ctx;
        in
            builtins.deepSeq nextCtx (while cond cb nextCtx)
    else
        ctx;

stringRepeat = str: n: if n <= 0 then "" else str + (stringRepeat str (n - 1));

in
let

jsonStringify = a: { pretty ? false }:
    let
    p = pretty;
    t = (stringRepeat " " 4);
    s = [{ t = "v"; v = a; d = 0; }];
    r = "";
    in
    (while (ctx: (builtins.length ctx.s) > 0) (ctx:
        let
        sLen = builtins.length ctx.s;
        c = builtins.elemAt ctx.s (sLen - 1);
        rS = builtins.genList (i: builtins.elemAt ctx.s i) (sLen - 1);
        cT = builtins.typeOf c.v;
        curD = c.d;
        in
        if c.t == "r" then
            ctx // {
            s = rS;
            r = ctx.r + c.v;
            }
        else if cT == "null" then
            ctx // {
            s = rS;
            r = ctx.r + "null";
            }
        else if cT == "bool" then
            ctx // {
            s = rS;
            r = ctx.r + (if c.v then "true" else "false");
            }
        else if cT == "string" then
            ctx // {
            s = rS;
            r = ctx.r + "\"" + (escapeString c.v) + "\"";
            }
        else if cT == "int" || cT == "float" then
            ctx // {
            s = rS;
            r = ctx.r + (builtins.toString c.v);
            }
        else if cT == "lambda" then
            ctx // {
            s = rS;
            r = ctx.r + "\"[object Function]\"";
            }
        else if cT == "list" then
            if (builtins.length c.v) == 0 then
                ctx // {
                s = rS;
                r = ctx.r + "[]";
                }
            else
            let
            childD = curD + 1;
            llen = builtins.length c.v;
            in
            ctx // { s = rS
            ++ [{
                t = "r";
                v = if p then "\n" + (stringRepeat t curD) + "]" else "]";
                d = curD;
            }]
            ++ builtins.concatLists (builtins.genList (lI:
            let
            i = llen - 1 - lI;
            in
            if i > 0 then
            [
                {
                    t = "v";
                    v = builtins.elemAt c.v i;
                    d = childD;
                }
                {
                    t = "r";
                    v = if p then ",\n" + (stringRepeat t childD) else ",";
                    d = childD;
                }
            ]
            else
            [
                {
                    t = "v";
                    v = builtins.elemAt c.v i;
                    d = childD;
                }
            ]
            ) llen)
            ++ [{
                t = "r";
                v = if p then "[\n" + (stringRepeat t childD) else "[";
                d = childD;
            }];
            }
        else if cT == "set" then
            let
            childD = curD + 1;
            dkl = builtins.attrNames c.v;
            dklLen = builtins.length dkl;
            in
            if dklLen == 0 then
                ctx // {
                s = rS;
                r = ctx.r + "{}";
                }
            else
            ctx // { s = rS
            ++ [{
                t = "r";
                v = if p then "\n" + (stringRepeat t curD) + "}" else "}";
                d = curD;
            }]
            ++ builtins.concatLists (builtins.genList (dklI:
            let
            i = dklLen - 1 - dklI;
            dK = builtins.elemAt dkl i;
            dV = c.v.${dK};
            in
            if i > 0 then
            [
                {
                    t = "v";
                    v = dV;
                    d = childD;
                }
                {
                    t = "r";
                    v = if p then "\"" + dK + "\": " else "\"" + dK + "\":";
                    d = childD;
                }
                {
                    t = "r";
                    v = if p then ",\n" + (stringRepeat t childD) else ",";
                    d = childD;
                }
            ]
            else
            [
                {
                    t = "v";
                    v = dV;
                    d = childD;
                }
                {
                    t = "r";
                    v = if p then "\"" + dK + "\": " else "\"" + dK + "\":";
                    d = childD;
                }
            ]
            ) dklLen)
            ++ [{
                t = "r";
                v = if p then "{\n" + (stringRepeat t childD) else "{";
                d = childD;
            }];
            }
        else
        ctx // {
            s = rS;
            r = ctx.r + "\"" + cT + "\"";
        }
    )
    ({
        s = s;
        r = r;
    })).r;

in
{
inherit
do
stringRepeat
jsonStringify
ifThenElse
while
;}
