#!/usr/bin/env bash

# Just so that our oniguruma.pc is found if
# the user doesn't have an oniguruma.pc.
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$GOPATH/src/github.com/limetext/rubex

# Colors.
export RED="\e[31m"
export GREEN="\e[32m"
export YELLOW="\e[33m"
export RESET="\e[0m"

export GO15VENDOREXPERIMENT=1

function fold_start {
	if [ "$TRAVIS" == "true" ]; then
		echo -en "travis_fold:start:$1\r"
		echo "\$ $2"
	fi
}

function fold_end {
	if [ "$TRAVIS" == "true" ]; then
		echo -en "travis_fold:end:$1\r"
	fi
}

function diff_test {
	# WARNING: This function is dangerous!
	$1
	changed=$(git status --porcelain)
	test_result=0
	if [ "$changed" != "" ]; then
		echo "\"$1\" hasn't been run!"
		echo "Changed files:"
		echo "$changed"
		test_result=1
		git checkout -- .
	fi
}

function build {
	pushd "$1"
	go build
	build_result=$?
	echo -ne "${YELLOW}=>${RESET} build $1 - "
	if [ "$build_result" == "0" ]; then
		echo -e "${GREEN}SUCCEEDED${RESET}"
	else
		echo -e "${RED}FAILED${RESET}"
	fi
	popd
}

export -f fold_start
export -f fold_end
export -f diff_test
export -f build
