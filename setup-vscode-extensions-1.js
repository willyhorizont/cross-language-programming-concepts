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

// 2. Parsing parameter CLI manual (Meniru perilaku param PS1)
const args = process.argv.slice(2);
let profilePattern = ".*";
let clear = false;
let install = false;

for (let i = 0; i < args.length; i++) {
    if (args[i] === '--profile-pattern' && args[i + 1]) {
        profilePattern = args[i + 1];
        i++;
    } else if (args[i] === '--clear') {
        clear = true;
    } else if (args[i] === '--install') {
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
        // Mengembalikan string kosong jika command gagal/tidak ada extension
        return "";
    }
}

// 4. Logika CLEAR jika switch --clear aktif
if (clear) {
    matchedProfiles.forEach(p => {
        console.log(`clear profile ${p}`);
        
        // Ambil daftar ekstensi aktif pada profil tersebut
        const output = runCmd(`code --profile "${p}" --list-extensions`);
        const extensions = output.split('\n').map(ext => ext.trim()).filter(Boolean);
        
        // Uninstall setiap ekstensi yang ditemukan
        extensions.forEach(ext => {
            console.log(`  Uninstalling ${ext}...`);
            runCmd(`code --profile "${p}" --uninstall-extension "${ext}" --force`);
        });
    });
}

// 5. Logika INSTALL jika switch --install aktif
if (install) {
    matchedProfiles.forEach(p => {
        console.log(`install profile ${p} extensions`);
        
        // Install semua ekstensi yang terdaftar di konfigurasi profil
        config[p].forEach(e => {
            console.log(`  Installing ${e}...`);
            runCmd(`code --profile "${p}" --install-extension "${e}" --force`);
        });
    });
}
