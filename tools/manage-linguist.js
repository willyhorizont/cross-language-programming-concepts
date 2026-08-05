const fs = require("fs").promises;

const manageLinguist = async () => {
    try {
        const ljS = await fs.readFile("linguist-languages.json", "utf8");
        const lJ = JSON.parse(ljS);
        const nLj = Object.entries(lJ).reduce((cur, [pk, pv]) => {
            if (pv?.["type"] !== "programming") return cur;
            if (!pv?.["color"]) return cur;
            cur.push({
                "id": pk,
                "stack": [
                    {
                        "name": pk,
                        "color": pv?.["color"]
                    }
                ],
            });
            return cur;
        }, []);
        console.log(nLj.length);
        const nLjS = JSON.stringify(nLj, null, 4);
        await fs.writeFile("./output/linguist-programming-languages.json", nLjS);
        console.log("Success!");
    } catch (err) {
        console.error("Something went wrong:", err.message);
    }
};
manageLinguist();
