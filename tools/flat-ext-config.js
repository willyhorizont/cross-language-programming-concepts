const fs = require("fs").promises;

const langToExt = async () => {
    try {
        const extCs = await fs.readFile("../languages.json", "utf8");
        const lJ = JSON.parse(extCs);
        const lExtDict = lJ.reduce((cur, l) => {
            if (!l["id"] || !l["file_extension"] || !l["vscode_extensions"]) return cur;
            const cfX = l["file_extension"].toLowerCase();
            const lExts = l["vscode_extensions"].map((lExt) => lExt.toLowerCase());
            if (cur[cfX]) {
                cur[cfX] = [...cur[cfX], ...lExts];
                return cur;
            }
            cur[cfX] = lExts;
            return cur;
        }, {});
        const s = JSON.stringify(lExtDict, null, 4);
        await fs.writeFile("./output/flat-ext-config.json", s);
        console.log("Success!");
    } catch (err) {
        console.error("Something went wrong:", err.message);
    }
};
langToExt();
