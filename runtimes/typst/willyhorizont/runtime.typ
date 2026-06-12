#let user-name = sys.inputs.at("user-name", default: "user")
#let user-computer = sys.inputs.at("user-computer", default: "computer")
#let user-pwd = sys.inputs.at("user-pwd", default: "~")
#let file-name-with-extension = sys.inputs.at("file-name-with-extension", default: "unknown.typ")
#let to-string(content) = {
    if type(content) == str {
        content
    } else if type(content) == int or type(content) == float {
        str(content)
    } else if content.has("text") {
        to-string(content.text)
    } else if content.has("children") {
        content.children.map(to-string).join("")
    } else if content.has("body") {
        to-string(content.body)
    } else if content == [ ] {
        " "
    } else {
        ""
    }
}
#let print-prompt = () => {
    return [
        #show regex("."): (it) => [#it#sym.zws]
        #user-name\@#user-computer:#text(fill: rgb("#729fcf"))[#user-pwd]#text(fill: rgb("#ddd"))[\$]
    ]
}
#let print-command = (command-output) => {
    return [
        #show regex("."): (it) => [#it#sym.zws]
        #text(fill: rgb("#ddd"))[#command-output]
    ]
}
#let setup-document = (document) => {
    let elements = none
    if ("children" in document.fields()) {
        elements = document.children
    } else {
        elements = (document,)
    }
    if ((elements.len() > 0) and ((elements.at(0).func() == parbreak) or (elements.at(0) == [ ]) or (elements.at(0) == []) or (elements.at(0) == [#{"\n"}]))) {
        elements = elements.slice(1)
    }
    let mapped-elements = elements.map((item) => {
        let new-item = none
        if ("children" in item.fields()) {
            new-item = item.children
        } else {
            new-item = (item,)
        }
        if ((new-item.len() > 0) and ((new-item.at(0).func() == parbreak) or (new-item.at(0) == [ ]) or (new-item.at(0) == []) or (new-item.at(0) == [#{"\n"}]))) {
            new-item = new-item.slice(1)
        }
        if ((new-item == [ ]) or (new-item == [])) {
            return [#{"\n"}]
        }
        if (new-item.len() > 0) {
            return new-item.sum()
        }
        return [#{"\n"}]
    })
    return mapped-elements
}
#let setup-command-prompt = (document) => {
    let new-document = setup-document(setup-document(document).sum()).sum()
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
        #print-prompt()#print-command([typst compile #file-name-with-extension])#{"\n"}#text(fill: rgb("#ddd"))[#new-document]
    ]
}
