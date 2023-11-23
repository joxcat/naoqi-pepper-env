#!/bin/bash
# ========================= BEGIN HELPERS =============================
c_green=""
c_red=""
c_bold=""
c_reset_bold=""
# If the shell has an output, then we can use colors
if [ -t 0 ]; then
	c_green="\033[32m"
	c_red="\033[31m"
	c_reset="\033[0m"
	c_bold="\033[1m"
	c_reset_bold="\033[22m"
fi
function green() { printf "%b%s%b\n" "$c_green" "$@" "$c_reset"; }
function red() { printf "%b%s%b\n" "$c_red" "$@" "$c_reset"; }
function bold() { printf "%b%s%b\n" "$c_bold" "$@" "$c_reset_bold"; }
function logger() {
	printf "%s: [$(date '+%Y-%m-%d %H:%M:%S %Z')] %s\n" "$1" "$2"
}
function info() {
	logger "$(green "$(bold INFO)")" "$(green "$1")"
}
function error() {
	logger "$(red "$(bold INFO)")" "$(red "$1")"
}
elapsed_from_last_step="$(date -u +%s)"
function reset_elapsed() {
    elapsed_from_last_step="$(date -u +%s)"
}
function elapsed() {
    echo "$(($(date -u +%s)-elapsed_from_last_step))s"
}
# ========================= END HELPERS =============================
# Command error fail the file
set -e

vendored_deps_src="./vendored_deps.tar.gz"
if [[ -f "$vendored_deps_src" ]]; then
    info "Extracting vendored deps"
    reset_elapsed
    tar xzf "$vendored_deps_src"
    info "Extracted vendored deps in $(elapsed) to ./deps"
else error "Packed vendored deps not found in $vendored_deps_src";
fi;