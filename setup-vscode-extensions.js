#!/usr/bin/env node

const { execSync } = require('child_process');

const config = {
    "Default": [
        "alecghost.tree-sitter-vscode",
        "evgeniypeshkov.syntax-highlighter",

        "formulahendry.code-runner",
        "aaron-bond.better-comments",
        "adpyke.codesnap",
        "cardinal90.multi-cursor-case-preserve",
        "christian-kohler.path-intellisense",
        "mechatroner.rainbow-csv",
        "naumovs.color-highlight",
        "oderwat.indent-rainbow",
        "ritwickdey.liveserver",
        "hjb2012.vscode-es6-string-html",
        "tobermory.es6-string-html",
        "tomrijndorp.find-it-faster",
        "vscode-icons-team.vscode-icons",
        "wholroyd.jinja",
        "yzhang.markdown-all-in-one",

        // "ms-python.autopep8",
        // "ms-python.debugpy",
        // "ms-python.isort",
        // "ms-python.python",
        // "ms-python.vscode-pylance",
        // "ms-python.vscode-python-envs",

        // "mindaro-dev.file-downloader",
        // "llvm-vs-code-extensions.lldb-dap",
        // "vadimcn.vscode-lldb",
    ],
    "kotlin": [
        "fwcd.kotlin",
        "mathiasfrohlich.Kotlin",
        "esafirm.kotlin-formatter",
    ],
};

const args = process.argv.slice(2);
let profilePattern = ".*";
let clear = false;
let install = false;

for (let i = 0; i < args.length; i++) {
    const arg = args[i].toLowerCase();
    if (arg === '-profilepattern' && args[i + 1]) {
        profilePattern = args[i + 1];
        i++;
    } else if (arg === '-clear') {
        clear = true;
    } else if (arg === '-install') {
        install = true;
    }
}

const regex = new RegExp(profilePattern);
const matchedProfiles = Object.keys(config).filter((p) => regex.test(p));

function runCmd(command) {
    try {
        return execSync(command, { encoding: 'utf8' });
    } catch (error) {
        return "";
    }
}

if (clear) {
    matchedProfiles.forEach((p) => {
        console.log(`clear profile ${p}`);

        const output = runCmd(`code --profile "${p}" --list-extensions`);
        const extensions = output.split('\n').map((ext) => ext.trim()).filter(Boolean);
        
        extensions.forEach((ext) => {
            console.log(`  Uninstalling ${ext}...`);
            runCmd(`code --profile "${p}" --uninstall-extension "${ext}" --force`);
        });
    });
}

// 5. Logika INSTALL jika switch -Install aktif
if (install) {
    matchedProfiles.forEach((p) => {
        console.log(`install profile ${p} extensions`);
        
        config[p].forEach((e) => {
            console.log(`  Installing ${e}...`);
            runCmd(`code --profile "${p}" --install-extension "${e}" --force`);
        });
    });
}
