#!/usr/bin/env bash
# ========================= BEGIN HELPERS =============================
c_green=""
c_bold=""
c_reset_bold=""
# If the shell has an output, then we can use colors
if [ -t 0 ]; then
	c_green="\033[32m"
	c_reset="\033[0m"
	c_bold="\033[1m"
	c_reset_bold="\033[22m"
fi
function green() { printf "%b%s%b\n" "$c_green" "$@" "$c_reset"; }
function bold() { printf "%b%s%b\n" "$c_bold" "$@" "$c_reset_bold"; }
function logger() {
	printf "%s: [$(date '+%Y-%m-%d %H:%M:%S %Z')] %s\n" "$1" "$2"
}
function info() {
	logger "$(green "$(bold INFO)")" "$(green "$1")"
}
elapsed_from_last_step="$(date -u +%s)"
function reset_elapsed() {
    elapsed_from_last_step="$(date -u +%s)"
}
function elapsed() {
    echo "$(($(date -u +%s)-elapsed_from_last_step))s"
}
function join_by() { local IFS="$1"; shift; echo "$*"; }
# ========================= END HELPERS =============================
# Command error fail the file
set -e
deps=()
deps_dir="./deps"
mkdir -p "$deps_dir"

# SOURCE: https://www.aldebaran.com/en/support/pepper-naoqi-2-9/downloads-softwares/former-versions?os=49&category=108
pynaoqi_source="$deps_dir/pynaoqi-python.tar.gz"
deps+=("$pynaoqi_source")
if [[ ! -f "$pynaoqi_source" ]]; then
    info "Getting the pynaoqi SDK" 
    reset_elapsed
    curl -L -o "$pynaoqi_source" https://community-static.aldebaran.com/resources/2.5.5/sdk-python/pynaoqi-python2.7-2.5.5.5-linux64.tar.gz
    info "Got the pynaoqi SDK in $(elapsed) to $pynaoqi_source"
else info "Already got pynaoqi SDK at $pynaoqi_source";
fi;

# SOURCE: https://www.aldebaran.com/en/support/pepper-naoqi-2-9/downloads-softwares/former-versions?os=49&category=98
choregraphe_src="$deps_dir/choregraphe-suite.tar.gz"
deps+=("$choregraphe_src")
if [[ ! -f "$choregraphe_src" ]]; then
    info "Getting Choregraph suite" 
    reset_elapsed
    curl -L -o "$choregraphe_src" https://community-static.aldebaran.com/resources/2.5.10/Choregraphe/choregraphe-suite-2.5.10.7-linux64.tar.gz
    info "Got Choregraph suite in $(elapsed) to $choregraphe_src"
else info "Already got Choregraph suite at $choregraphe_src";
fi;

# SOURCE: https://github.com/cpe-majeure-robotique/qibullet
qibullet_src="$deps_dir/qibullet-master.tar.gz"
deps+=("$qibullet_src")
if [[ ! -f "$qibullet_src" ]]; then
    info "Getting qibullet"
    reset_elapsed
    curl -L -o "$qibullet_src" https://github.com/cpe-majeure-robotique/qibullet/archive/refs/heads/master.tar.gz
    info "Got qibullet in $(elapsed) to $qibullet_src"
else info "Already got qibullet at $qibullet_src";
fi;

# SOURCE: https://github.com/cpe-majeure-robotique/python_pepper_kinematics
pepper_kinematics_src="$deps_dir/python-pepper-kinematics.tar.gz"
deps+=("$pepper_kinematics_src")
if [[ ! -f "$pepper_kinematics_src" ]]; then
    info "Getting python pepper kinematics"
    reset_elapsed
    curl -L -o "$pepper_kinematics_src" https://github.com/cpe-majeure-robotique/python_pepper_kinematics/archive/refs/heads/master.tar.gz
    info "Got python pepper kinematics in $(elapsed) to $pepper_kinematics_src"
else info "Already got python pepper kinematics at $pepper_kinematics_src";
fi;

# SOURCE: https://github.com/aldebaran/libqi-js
libqi_js_src="$deps_dir/libqi-js.tar.gz"
deps+=("$libqi_js_src")
if [[ ! -f "$libqi_js_src" ]]; then
    info "Getting libqi-js"
    reset_elapsed
    curl -L -o "$libqi_js_src" https://github.com/aldebaran/libqi-js/archive/refs/heads/master.tar.gz
    info "Got libqi-js in $(elapsed) to $libqi_js_src"
else info "Already got libqi-js at $libqi_js_src";
fi;

# SOURCE: https://gitlab.com/davidvivier/naoqi-tablet-simulator
naoqi_tablet_simulator_src="$deps_dir/naoqi-tablet-simulator.tar.gz"
deps+=("$naoqi_tablet_simulator_src")
if [[ ! -f "$naoqi_tablet_simulator_src" ]]; then
    info "Getting naoqi tablet simulator"
    reset_elapsed
    curl -L -o "$naoqi_tablet_simulator_src" https://gitlab.com/davidvivier/naoqi-tablet-simulator/-/archive/master/naoqi-tablet-simulator-master.tar.gz
    info "Got naoqi tablet simulator in $(elapsed) to $naoqi_tablet_simulator_src"
else info "Already got naoqi tablet simulator at $naoqi_tablet_simulator_src";
fi;

if [[ "$*" =~ "--no-pack" ]]; then
    info "Skipping packing dependencies"
else
    deps_str="$(join_by ' ' "${deps[@]}")"
    packed_src="./vendored_deps/vendored_deps.tar.gz."
    info "Packing all the sources"
    reset_elapsed
    tar -I "gzip -9" -cf - $deps_str | split -b 100M - "$packed_src"
    info "Packed all the sources in $(elapsed) to ./vendored_deps"
fi;
