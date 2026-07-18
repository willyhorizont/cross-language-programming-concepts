#!/bin/bash

source "$(dirname "$(realpath "$0")")/../../tools/base-runner.sh" "$0" "$@"

PTRFNX="$RD/runtimes/wolfram-language-mathematica/willyhorizont/runtime/xl.wl"
if [ "$(realpath "$1" 2>/dev/null)" = "$(realpath "$PTRFNX" 2>/dev/null)" ]; then
    echo "usage:"
    echo "\"$SD/runner.sh\" path/to/*.$FX"
    exit 1
fi

PTLICD="$RD/runtimes/wolfram-language-mathematica/Licensing"
PTLIC="$PTLICD/mathpass"

if [ ! -s "$PTLIC" ]; then
    echo "$L"
    echo " 🔑 Missing Wolfram Engine License Token Detected!"
    echo "$L"
    echo "1. Enter your Wolfram ID & Password when prompted below."
    echo "2. Just type 'Quit' and press Enter after you see 'In[1]:=' to automatically save your token."
    echo "$L"
    read -p "Press [Enter] to start interactive license activation..."
    
    mkdir -p "$PTLICD"
    
    TMPC="wolfram-activation-tmp"
    docker run -it --name "$TMPC" "$IMG" wolframscript
    
    if [ "$(docker ps -aq -f name=$TMPC)" ]; then
        RLIC=$(docker cp "$TMPC:/home/wolframengine/.WolframEngine/Licensing/mathpass" - 2>/dev/null | tar -xO 2>/dev/null)
        docker rm -f "$TMPC" > /dev/null 2>&1
    fi
    
    if [ ! -z "$RLIC" ]; then
        NLIC=$(echo "$RLIC" | tr -d '\r' | tr -s '\t' ' ' | tr -s ' ' | xargs)
        
        echo "$NLIC" | \
            sed 's/%(\*userregistered\*) //g' | \
            sed 's/^[^ ]*/ead4bcf5fbd0/' > "$PTLIC"
        
        chmod -R 777 "$PTLICD"
    fi
    
    if [ ! -s "$PTLIC" ]; then
        echo ""
        echo "❌ Error: Activation failed or mathpass was not written. Try again."
        exit 1
    fi
    
    echo "$L"
    echo "✅ Success! Token generated cleanly inside:"
    echo "👉 $PTLIC"
    echo "$L"
    sleep 1
fi

CPV="
echo \">docker images\"
echo \"$IMG\"
echo \">wolframscript -version\"
wolframscript -version
echo \">wolframscript --version\"
wolframscript --version
"

CRLC="
wolframscript -file \"$PTFNX\"
"

DCN="$LID-runner"

if [ -f "$PTDCNTFNX" ]; then
    TDCN=$(cat "$PTDCNTFNX")
    if [ ! -z "$TDCN" ] && [ "$TDCN" != "$DCN" ]; then
        docker rm -f "$TDCN" > /dev/null 2>&1
        rm -f "$PTDCNTFNX"
    fi
fi

if [ ! "$(docker ps -q -f name=$DCN)" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=$DCN)" ]; then
        docker rm $DCN > /dev/null
    fi
    docker run -d \
        --name $DCN \
        --entrypoint "" \
        -v "$RD:$RD" \
        -v "$RD/runtimes/wolfram-language-mathematica/Licensing:/home/wolframengine/.WolframEngine/Licensing" \
        "$IMG" \
        sleep infinity > /dev/null
    echo "$DCN" > "$PTDCNTFNX"
    sleep 2
fi

docker exec -i $DCN /bin/bash -c "
    $CPV

    echo \"$L\"

    $CRLC
"
