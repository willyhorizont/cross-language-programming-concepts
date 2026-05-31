#!/bin/bash

# https://dev.to/kaiwalter/automate-vs-code-extensions-setup-across-profiles-4bc2
# https://stackoverflow.com/questions/35929746/automatically-install-extensions-in-vs-code
# https://share.google/aimode/08za6aC7AlRI5UEkq
# https://share.google/aimode/hVAyTZSL7kIOGx4Xd

# 1. Konfigurasi data profil dan ekstensinya
declare -A config
config["Default"]="\
alecghost.tree-sitter-vscode \
evgeniypeshkov.syntax-highlighter \

formulahendry.code-runner \
aaron-bond.better-comments \
adpyke.codesnap \
cardinal90.multi-cursor-case-preserve \
christian-kohler.path-intellisense \
mechatroner.rainbow-csv \
naumovs.color-highlight \
oderwat.indent-rainbow \
ritwickdey.liveserver \
hjb2012.vscode-es6-string-html \
tobermory.es6-string-html \
tomrijndorp.find-it-faster \
vscode-icons-team.vscode-icons \
wholroyd.jinja \
yzhang.markdown-all-in-one \
"

config["kotlin"]="\
${config[\"Default\"]} \

fwcd.kotlin \
mathiasfrohlich.Kotlin \
esafirm.kotlin-formatter \
"

# 2. Nilai default parameter
PROFILE_PATTERN=".*"
CLEAR=false
INSTALL=false

# 3. Parsing parameter
while [[ "$#" -gt 0 ]]; do
    case ${1,,} in
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
        
        # Trik Otomatis Bikin Profil
        code --profile "$p" --install-extension golang.go &> /dev/null
        code --profile "$p" --uninstall-extension golang.go --force &> /dev/null

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
        
        # Gabungkan daftar ekstensi: Jika profil BUKAN Default, sisipkan isi Default di depannya
        list_to_install=""
        if [ "$p" != "Default" ]; then
            list_to_install="${config["Default"]} ${config[$p]}"
        else
            list_to_install="${config["Default"]}"
        fi

        # Jalankan instalasi gabungan
        for e in $list_to_install; do
            echo "  Installing $e..."
            code --profile "$p" --install-extension "$e" --force &> /dev/null
        done
    done
fi
