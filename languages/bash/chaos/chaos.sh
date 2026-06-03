#!/bin/bash

# elixir: "Hello, World!" |> IO.puts()
echo "Hello, World!" | xargs echo

cetak_pesan() {
    echo "--- PESAN: $1 ---"
}
export -f cetak_pesan

# "Hello, World!" |> cetak_pesan() versi Bash:
echo "Hello, World!" | xargs -I {} bash -c 'cetak_pesan "{}"'

io_puts() {
    # Membaca baris teks yang dikirim dari pipe
    read -r baris
    echo "$baris"
}

# Jalankan aliran pipe murni tanpa xargs
echo "Hello, World!" | io_puts

readonly SECRET_1="super secret 1"
declare -r SECRET_2="super secret 2"

some_function() {
    # SECRET_1 = "new secret 1" # error
    # echo "SECRET_1: $SECRET_1" # error
    # SECRET_2 = "new secret 1" # error
    # echo "SECRET_2: $SECRET_2" # error

    local -r SECRET_3="super secret 3"
    echo "SECRET_3: $SECRET_3"

    # SECRET_3="new secret 3" # error
    # echo "SECRET_3: $SECRET_3" # error
}
some_function
