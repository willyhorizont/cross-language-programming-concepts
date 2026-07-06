const fs = require("fs").promises;

const langToExt = async () => {
    try {
        const ljS = await fs.readFile("../languages.json", "utf8");
        const lJ = JSON.parse(ljS);
        const nLj = lJ.map((l) => ({
            "id": l["id"],
            "file_extension": l["file_extension"],
            "vscode_extensions": l["vscode_extensions"],
        }));
        const nLjS = JSON.stringify(nLj, null, 4);
        await fs.writeFile("./output/ext-config.json", nLjS);
        console.log("Success!");
    } catch (err) {
        console.error("Something went wrong:", err.message);
    }
};
langToExt();
