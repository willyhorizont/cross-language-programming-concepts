const fs = require("fs").promises;

const langToExt = async () => {
    try {
        const lS = await fs.readFile("../languages.json", "utf8");
        const lJ = JSON.parse(lS);
        const lL = [...new Set(
            lJ.reduce((acc, item) => acc.concat(item["vscode_extensions"]), [])
        )];
        const s = JSON.stringify(lL);
        await fs.writeFile("./output/all-exts.json", s);
        console.log("Success!");
    } catch (err) {
        console.error("Something went wrong:", err.message);
    }
};
langToExt();
