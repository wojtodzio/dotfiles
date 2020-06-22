#!/usr/bin/env bash

for i in ./.*; do
    if [[ -f "$i" ]]; then
        result=$(diff "$i" "$HOME/$(basename $i)");
        if [[ "$?" == 1 ]]; then
            echo "diff $i $HOME/$(basename $i):";
            echo "$result";
            echo;
        fi
    fi
done
