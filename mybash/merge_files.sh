#!/bin/bash
cat "$1" "$2" >> "$3"
wc -l "$1"
wc -l "$2"
wc -l "$3"
