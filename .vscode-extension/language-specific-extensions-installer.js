const vscode = require("vscode");
const { exec } = require("child_process");
const path = require("path");
const fs = require("fs");
const lJ = require(path.join(__dirname, "languages.json"));
const p = require(path.join(__dirname, "package.json"));

const lExtDict = lJ.reduce((cur, l) => {
    const fX = l["file_extension"].toLowerCase();
    const lExts = l["vscode_extensions"].map((lExt) => lExt.toLowerCase());
    if (cur[fX]) {
        cur[fX] = [...cur[fX], ...lExts];
        return cur;
    }
    cur[fX] = lExts;
    return cur;
}, {});

const bP = path.join(__dirname, "vscode-extensions-base.txt");
const bExts = fs.existsSync(bP) ? fs.readFileSync(bP, "utf8").split(/\r?\n/).map((ln) => ln.trim().toLowerCase()).filter((ln) => ln.length > 0) : [];

const runCommand = (cmd) => {
    return new Promise((resolve) => {
        exec(cmd, (err) => {
            if (err) console.error(`Failed running command: ${cmd}`, err);
            resolve();
        });
    });
};

module.exports = { activate: (context) => {
    (async () => {
        vscode.window.showInformationMessage(`Installing base extensions...`);
        for (const bExt of bExts) {
            if (!vscode.extensions.getExtension(bExt)) {
                await runCommand(`code --install-extension ${bExt} --force`);
                vscode.window.showInformationMessage(`Extension ${bExt} just installed.`);
            }
        }
        vscode.window.showInformationMessage(`Base extensions just installed.`);
    })();

    let dsp = vscode.window.onDidChangeActiveTextEditor(async (edt) => {
        if (!edt) return;

        const fNm = edt.document.fileName;
        const fX = path.extname(fNm).toLowerCase();
        const lExts = lExtDict?.[fX];

        if (lExts) {
            vscode.window.showInformationMessage(`Uninstalling other extensions...`);
            for (const el of vscode.extensions.all) {
                if (el?.packageJSON?.isBuiltin) continue;
                const insExt = el.id.toLowerCase();

                if (insExt === `undefined_publisher.${p.name}`) continue;
                if (bExts.some((bExt) => insExt === bExt)) continue;
                if (lExts.some((lExt) => insExt === lExt)) continue;

                await runCommand(`code --uninstall-extension ${insExt} --force`);
            }
            vscode.window.showInformationMessage(`Other extensions just uninstalled.`);

            vscode.window.showInformationMessage(`Installing extensions for "${fX}" files...`);
            for (const lExt of lExts) {
                if (!vscode.extensions.getExtension(lExt)) {
                    await runCommand(`code --install-extension ${lExt} --force`);
                }
            }
            vscode.window.showInformationMessage(`Extensions for "${fX}" files just installed.`);
            return;
        }
    });
    context.subscriptions.push(dsp);
}, deactivate: () => undefined };
