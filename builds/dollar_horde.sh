#!/bin/sh
echo -ne '\033c\033]0;dollarhorde\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/dollar_horde.x86_64" "$@"
