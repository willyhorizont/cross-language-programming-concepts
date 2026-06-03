#!/bin/bash

# 1. Ini string mentah Anda (berisi simbol \n, \$, dan \")
// STRING_KOTOR='"#!/bin/bash\n declare -r -a variadic_arguments=( \"$@\" ) \n declare -r a=\"$1\" \n declare -r b=\"$2\" \n echo $(( a * b )) "'
// STRING_KOTOR_L='"#!/bin/bash\n declare -r -a variadic_arguments=( \"$@\" ) declare -r a=\"$1\" declare -r b=\"$2\" echo $(( a * b )) "'
// STRING_KOTOR_D='"#!/bin/bash\n declare -r -a variadic_arguments=( \"$@\" ) declare -r a=\"$1\" declare -r b=\"$2\" echo $(( a * b )) "'
STRING_KOTOR='"#!/bin/bash\n\n                                                        declare -r -a variadic_arguments=( \"$@\" )\n                                                        declare -r a=\"$1\"\n                                                        declare -r b=\"$2\"\n\n                                                        echo $(( a * b ))\n                                                        \n"'
// STRING_KOTOR='"#!/bin/bash\n\ndeclare-r-avariadic_arguments=(\"$@\")\ndeclare-ra=\"$1\"\ndeclare-rb=\"$2\"\n\necho$((a*b))\n\n"'

# 2. Gunakan jq -r untuk melakukan unescape otomatis (mengubah \n menjadi newline asli, \" menjadi ")
KODE_BERSIH=$(jq -r . < <(echo "$STRING_KOTOR"))

echo "--- Hasil Teks Setelah Di-parse JQ (Sudah Berubah Menjadi Multiline Asli) ---"
echo "$KODE_BERSIH"

echo -e "\n--- Hasil Eksekusi dengan bash -c ---"
# 3. Jalankan langsung dengan argumen 5 dan 4
bash -c "$KODE_BERSIH" _ 5 4
