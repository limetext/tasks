#!/usr/bin/env bash

source "$(dirname -- "$0")/setup.sh"

function run_tests {
	go test "$1" -covermode=count -coverprofile=tmp.cov
	test_result=$?
	# Can't do race tests at the same time as coverage as it'll report
	# lots of false positives
	go test -race "$1"
	let test_result=$test_result+$?
	echo -ne "${YELLOW}=>${RESET} test $1 - "
	if [ "$test_result" == "0" ]; then
		echo -e "${GREEN}SUCCEEDED${RESET}"
	else
		echo -e "${RED}FAILED${RESET}"
	fi
}

function test_all {
	let a=0
	for pkg in $(go list "./$1/..." | grep -v /vendor/); do
		run_tests "$pkg"
		let a=$a+$test_result
		if [ "$test_result" == "0" ]; then
			sed 1d tmp.cov >> coverage.cov
		fi
		rm tmp.cov
	done
	test_result=$a
}

echo "mode: count" > coverage.cov

ret=0

fold_start "test" "run tests"
test_all "$1"
let ret=$ret+$test_result
fold_end "test"

if [ "$ret" == "0" ] && [ "$TRAVIS_OS_NAME" == "linux" ]; then
	fold_start "coveralls" "post to coveralls"
	"$(go env GOPATH | awk 'BEGIN{FS=":"} {print $1}')/bin/goveralls" -coverprofile=coverage.cov -service=travis-ci
	fold_end "coveralls"
fi

rm coverage.cov

exit $ret
