#let user-name = sys.inputs.at("user-name", default: "user")
#let user-computer = sys.inputs.at("user-computer", default: "computer")
#let user-pwd = sys.inputs.at("user-pwd", default: "~")
#let file-name-with-extension = sys.inputs.at("file-name-with-extension", default: "unknown.typ")
#let print-prompt = () => [#user-name\@#user-computer:#text(fill: rgb("#729fcf"))[#user-pwd]#text(fill: rgb("#ddd"))[\$]]
#let print-command = (command-output) => [
    #show regex("."): it => [#it#sym.zws]
    #text(fill: rgb("#ddd"))[#command-output]
]
#let flatten-and-clean(body) = {
    let extract(item) = {
        if type(item) != content { return (item,) }
        let fields = item.fields()
        if "children" in fields {
            return fields.children.map(extract).flatten()
        }
        if "child" in fields {
            return extract(fields.child)
        }
        return (item,)
    }

    let elements = extract(body)

    while elements.len() > 0 {
        let first = elements.at(0)
        let f-name = repr(first.func())
        if first == [ ] or f-name in ("space", "parbreak", "empty") {
            elements = elements.slice(1)
        } else {
            break
        }
    }

    if elements.len() > 0 { return elements.sum() }
    return []
}
#let setup-command-prompt = (document) => {
    return [
        #set page(
            fill: rgb("1c1c1c"),
            margin: 0cm,
        )
        #set text(
            font: "DejaVu Sans Mono",
            fill: rgb("#00e287"),
            size: 10pt,
        )
        #print-prompt() #print-command([typst compile #file-name-with-extension]) #{"\n"}#text(fill: rgb("#ddd"))[#flatten-and-clean(document)]
    ]
}
