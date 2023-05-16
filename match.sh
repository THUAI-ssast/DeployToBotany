#!/bin/bash

MID=$1
JUDGE=$2
shift 2

mkdir -p matches/$MID

argv=()

i=0
for s in $@; do
    CODE=$(find submissions/$s/code.*)
    LANG=${CODE#*.}
    exec="bin"
    env=""
    if [[ "$LANG" == "5.1.lua" ]]; then
        exec="/usr/bin/lua code.5.1.lua"
        env="--env=LUA_PATH=/botlib/?.lua"
    elif [[ "$LANG" == "py3" ]]; then
        exec="/usr/bin/python3 code.py3"
        env="--env=PYTHONPATH=/botlib"
    elif [[ "$LANG" == "py" ]]; then
        # py as python3
        exec="/usr/bin/python3 code.py"
        env="--env=PYTHONPATH=/botlib"
    elif [[ "$LANG" == "node.js" ]]; then
        exec="/usr/bin/node code.node.js"
    fi
    argv+=("isolate --run -b $i --dir=box=/var/botany/submissions/$s --dir=botlib=/var/botany/lib --dir=tmp= --dir=proc= $env --silent -- $exec")
    i=$((i + 1))
done

i=0
for s in $@; do
    argv+=(matches/$MID/$i.log)
    i=$((i + 1))
done

echo >&2 "submissions/$JUDGE/bin" "${argv[@]}"
submissions/$JUDGE/bin "${argv[@]}"
echo >&2 "match $MID finished"
