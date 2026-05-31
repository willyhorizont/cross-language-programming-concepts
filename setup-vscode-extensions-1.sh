#!/bin/bash

# Default values untuk parameter
PROFILE_PATTERN=".*"
CLEAR=false
INSTALL=false

# Definisikan asosiasi profil dan extension (menggunakan associative array di Bash 4+)
declare -A config
config["Default"]="humao.rest-client"
config["pwsh"]="ms-vscode.powershell"
config["py"]="ms-python.python"
config["az"]="humao.rest-client ms-vscode.azure-account ms-vscode.azurecli"
config["dotnet"]="humao.rest-client ms-dotnettools.csharp"

# Parsing argumen / parameter
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --profile-pattern) PROFILE_PATTERN="$2"; shift ;;
        --clear) CLEAR=true ;;
        --install) INSTALL=true ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Loop untuk memproses setiap profil yang cocok dengan regex
for p in "${!config[@]}"; do
    if [[ $p =~ $PROFILE_PATTERN ]]; then
        
        # Eksekusi logika CLEAR jika switch aktif
        if [ "$CLEAR" = true ]; then
            echo "clear profile $p"
            # Ambil daftar extension, lalu uninstall satu per satu
            code --profile "$p" --list-extensions | while read -r ext; do
                if [ -n "$ext" ]; then
                    code --profile "$p" --uninstall-extension "$ext" --force
                fi
            done
        fi

        # Eksekusi logika INSTALL jika switch aktif
        if [ "$INSTALL" = true ]; then
            echo "install profile $p extensions"
            # Pecah string menjadi array extension
            for e in ${config[$p]}; do
                code --profile "$p" --install-extension "$e" --force
            done
        fi

    fi
done
