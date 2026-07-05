const fs = require("fs").promises;

const getLangsNoExt = async () => {
    try {
        const ljS = await fs.readFile("../languages.json", "utf8");
        const lJ = JSON.parse(ljS);
        const nLj = lJ.reduce((cur, l) => {
            if (l["vscode_extensions"]?.length === 0) {
                cur.push({
                    "id": l["id"],
                    "file_extension": l["file_extension"],
                });
                return cur;
            }
            return cur;
        }, []);
        const nLjS = JSON.stringify(nLj, null, 4);
        await fs.writeFile("./output/langs-no-ext.json", nLjS);
        console.log("Success!");
    } catch (err) {
        console.error("Something went wrong:", err.message);
    }
};
getLangsNoExt();
