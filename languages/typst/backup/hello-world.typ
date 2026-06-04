#set page(
    fill: rgb("1c1c1c"),
    margin: 0cm,
)

#set text(
    font: "DejaVu Sans Mono",
    fill: rgb("#00e287"),
    size: 10pt,
)

#let print-prompt = () => [user\@computer:#text(fill: rgb("#3c5fcf"))[\~]#text(fill: rgb("#ddd"))[\$]]
#let print-command = (command-output) => [#text(fill: rgb("#ddd"))[#command-output]]

#print-prompt() #print-command("typst compile hello-world.typ") \
#print-command("hello, world") \
