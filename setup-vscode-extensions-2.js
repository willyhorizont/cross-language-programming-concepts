#!/usr/bin/env node

const { execSync } = require('child_process');

// 1. Konfigurasi data profil dan ekstensinya
const config = {
    "Default": ["humao.rest-client"],
    "pwsh": ["ms-vscode.powershell"],
    "py": ["ms-python.python"],
    "az": ["humao.rest-client", "ms-vscode.azure-account", "ms-vscode.azurecli"],
    "dotnet": ["humao.rest-client", "ms-dotnettools.csharp"]
};

// 2. Parsing parameter CLI (Mendukung format -Clear, -Install, -ProfilePattern)
const args = process.argv.slice(2);
let profilePattern = ".*";
let clear = false;
let install = false;

for (let i = 0; i < args.length; i++) {
    // Mencocokkan argument secara case-insensitive agar mirip PowerShell
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

// 3. Filter profil menggunakan Regex sesuai input pattern
const regex = new RegExp(profilePattern);
const matchedProfiles = Object.keys(config).filter(p => regex.test(p));

// Helper untuk menjalankan command CLI secara sinkronos
function runCmd(command) {
    try {
        return execSync(command, { encoding: 'utf8' });
    } catch (error) {
        return ""; // Mengembalikan string kosong jika profil tidak memiliki ekstensi
    }
}

// 4. Logika CLEAR jika switch -Clear aktif
if (clear) {
    matchedProfiles.forEach(p => {
        console.log(`clear profile ${p}`);
        
        const output = runCmd(`code --profile "${p}" --list-extensions`);
        const extensions = output.split('\n').map(ext => ext.trim()).filter(Boolean);
        
        extensions.forEach(ext => {
            console.log(`  Uninstalling ${ext}...`);
            runCmd(`code --profile "${p}" --uninstall-extension "${ext}" --force`);
        });
    });
}

// 5. Logika INSTALL jika switch -Install aktif
if (install) {
    matchedProfiles.forEach(p => {
        console.log(`install profile ${p} extensions`);
        
        config[p].forEach(e => {
            console.log(`  Installing ${e}...`);
            runCmd(`code --profile "${p}" --install-extension "${e}" --force`);
        });
    });
}
