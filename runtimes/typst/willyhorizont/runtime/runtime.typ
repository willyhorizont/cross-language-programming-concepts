#let u-n = sys.inputs.at("user-name", default: "user")
#let u-c = sys.inputs.at("user-computer", default: "computer")
#let u-d = sys.inputs.at("user-pwd", default: "~/cross-language-programming-concepts")
#let f-n-x = sys.inputs.at("file-name-with-extension", default: "file.typ")
#let p-prompt = () => {
    return [
        #show regex("."): (it) => [#it#sym.zws]
        #u-n\@#u-c:#text(fill: rgb("#729fcf"))[#u-d]#text(fill: rgb("#ddd"))[\$]
    ]
}
#let setup-doc = (doc) => {
    let n-doc = doc
    if n-doc.at("children", default: ()) == none {
        return n-doc
    }
    if n-doc.children.at(0).func() == parbreak {
        n-doc = n-doc.children.slice(1).sum()
    }
    if n-doc.children.at(0) == [ ] {
        n-doc = n-doc.children.slice(1).sum()
    }
    n-doc = n-doc.children.map((el) => {
        if (el == [ ]) {
            return [#{"\n"}]
        }
        return el
    }).sum()
    return n-doc
}
#let print-cmd = (cmd-out) => {
    return [
        #show regex("."): (it) => [#it#sym.zws]
        #text(fill: rgb("#ddd"))[#cmd-out]
    ]
}
#let runtime = (doc) => {
    let n-doc = setup-doc(doc)
    return [
        #set page(
            fill: rgb("1c1c1c"),
            margin: 4pt,
        )
        #set text(
            font: "DejaVu Sans Mono",
            fill: rgb("#00e287"),
            size: 10pt,
        )
        #p-prompt()#print-cmd([typst compile #f-n-x])#{"\n"}#text(fill: rgb("#ddd"))[#n-doc|]
    ]
}
#let escape-string(s) = {
    if s == none or s == "" { return "" }
    let r = str(s)
    r = r.replace("\\", "\\\\")
    r = r.replace("\"", "\\\"")
    r = r.replace("\n", "\\n")
    r = r.replace("\r", "\\r")
    r = r.replace("\t", "\\t")
    return r
}
#let json-stringify(a, pretty: false) = {
    let p = pretty
    let t = " " * 4
    let s = ((t: "v", v: a, d: 0),)
    let r = ""
    while s.len() > 0 {
        let c = s.at(-1)
        s = s.slice(0, -1)
        if c.at("t") == "r" {
            r += c.at("v")
            continue
        }
        let v = c.at("v")
        let cur-d = c.at("d")
        let v-t = type(v)
        if v == none {
            r += "null"
            continue
        }
        if v-t == bool {
            r += if v { "true" } else { "false" }
            continue
        }
        if v-t == str {
            r += "\"" + escape-string(v) + "\""
            continue
        }
        if v-t in (int, float) {
            r += str(v)
            continue
        }
        if v-t == function {
            r += "\"[object Function]\""
            continue
        }
        if v-t == array {
            if v.len() == 0 {
                r += "[]"
                continue
            }
            let child-d = cur-d + 1
            s.push((
                t: "r",
                v: if p { "\n" + (t * cur-d) + "]" } else { "]" },
                d: cur-d
            ))
            let i = v.len() - 1
            while i >= 0 {
                s.push((
                    t: "v",
                    v: v.at(i),
                    d: child-d
                ))
                if i > 0 {
                    s.push((
                        t: "r",
                        v: if p { ",\n" + (t * child-d) } else { "," },
                        d: child-d
                    ))
                }
                i -= 1
            }
            s.push((
                t: "r",
                v: if p { "[\n" + (t * child-d) } else { "[" },
                d: child-d
            ))
            continue
        }
        if v-t == dictionary {
            let dpl = v.pairs()
            if dpl.len() == 0 {
                r += "{}"
                continue
            }
            let child-d = cur-d + 1
            s.push((
                t: "r",
                v: if p { "\n" + (t * cur-d) + "}" } else { "}" },
                d: cur-d
            ))
            let i = dpl.len() - 1
            while i >= 0 {
                let pair = dpl.at(i)
                let dk = pair.at(0)
                let dv = pair.at(1)
                s.push((
                    t: "v",
                    v: dv,
                    d: child-d
                ))
                s.push((
                    t: "r",
                    v: if p { "\"" + str(dk) + "\": " } else { "\"" + str(dk) + "\":" },
                    d: child-d
                ))
                if i > 0 {
                    s.push((
                        t: "r",
                        v: if p { ",\n" + (t * child-d) } else { "," },
                        d: child-d
                    ))
                }
                i -= 1
            }
            s.push((
                t: "r",
                v: if p { "{\n" + (t * child-d) } else { "{" },
                d: child-d
            ))
            continue
        }
        r += "\"" + str(v-t) + "\""
    }
    return r
}
