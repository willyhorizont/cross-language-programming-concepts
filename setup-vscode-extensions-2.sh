#!/bin/bash

# 1. Konfigurasi data profil dan ekstensinya
declare -A config
config["Default"]="humao.rest-client"
config["pwsh"]="ms-vscode.powershell"
config["py"]="ms-python.python"
config["az"]="humao.rest-client ms-vscode.azure-account ms-vscode.azurecli"
config["dotnet"]="humao.rest-client ms-dotnettools.csharp"

# 2. Nilai default parameter
PROFILE_PATTERN=".*"
CLEAR=false
INSTALL=false

# 3. Parsing parameter (Mendukung format -Clear, -Install, -ProfilePattern)
while [[ "$#" -gt 0 ]]; do
    case ${1,,} in # Mengubah input argumen menjadi lowercase agar case-insensitive
        -profilepattern) PROFILE_PATTERN="$2"; shift ;;
        -clear) CLEAR=true ;;
        -install) INSTALL=true ;;
        *) echo "Parameter tidak dikenal: $1"; exit 1 ;;
    esac
    shift
done

# 4. Filter profil menggunakan Regex sesuai input pattern
matched_profiles=()
for p in "${!config[@]}"; do
    if [[ $p =~ $PROFILE_PATTERN ]]; then
        matched_profiles+=("$p")
    fi
done

# 5. Logika CLEAR jika switch -Clear aktif
if [ "$CLEAR" = true ]; then
    for p in "${matched_profiles[@]}"; do
        echo "clear profile: $p"
        
        # Trik Otomatis Bikin Profil:
        # VS Code tidak punya command khusus untuk 'bikin profil baru kosong'.
        # Kita pancing dengan menginstall satu ekstensi dummy, lalu langsung menghapusnya.
        # Ini akan memaksa VS Code membuat folder profil tersebut secara otomatis.
        code --profile "$p" --install-extension golang.go &> /dev/null
        code --profile "$p" --uninstall-extension golang.go --force &> /dev/null

        # Ambil daftar ekstensi yang ada di profil tersebut
        code --profile "$p" --list-extensions | while read -r ext; do
            if [ -n "$ext" ]; then
                echo "  Uninstalling $ext..."
                code --profile "$p" --uninstall-extension "$ext" --force &> /dev/null
            fi
        done
    done
fi

# 6. Logika INSTALL jika switch -Install aktif
if [ "$INSTALL" = true ]; then
    for p in "${matched_profiles[@]}"; do
        echo "install profile $p extensions"
        
        # Pecah string ekstensi menjadi array
        for e in ${config[$p]}; do
            echo "  Installing $e..."
            code --profile "$p" --install-extension "$e" --force &> /dev/null
        done
    done
fi
