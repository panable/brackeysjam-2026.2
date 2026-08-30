#!/bin/sh
printf '\033c\033]0;%s\a' brackeysjam-2026.2
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Misdungeon.x86_64" "$@"
