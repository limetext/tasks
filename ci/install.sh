#!/usr/bin/env bash

source "$(dirname -- "$0")/setup.sh"

if [ "$TRAVIS_OS_NAME" == "linux" ]; then

	# Add the following to .travis.yml:

	# sudo: false
	#
	# addons:
	#   apt:
	#     sources:
	#       - deadsnakes
	#     packages:
	#       - libonig-dev
	#       - python3.5
	#       - python3.5-dev

elif [ "$TRAVIS_OS_NAME" == "osx" ]; then

	brew update
	brew install oniguruma python3
	ln -s "$(brew --prefix python3)/Frameworks/Python.framework/Versions/3.5/lib/pkgconfig/"* "$(brew --prefix)/lib/pkgconfig"

else

	echo "BUILD NOT CONFIGURED: $TRAVIS_OS_NAME"
	exit 1

fi

fold_start "git.submodule_recursive" "git submodule recursive update"
git submodule update --init --recursive
fold_end "git.submodule_recursive"

fold_start "go.get_glide" "go get glide"
go get github.com/Masterminds/glide
fold_end "go.get_glide"

fold_start "go.get_cov" "go get coverage tools"
go get golang.org/x/tools/cmd/cover
go get github.com/mattn/goveralls
go get github.com/axw/gocov/gocov
fold_end "go.get_cov"

fold_start "go.get_depends" "go get dependencies"
go get github.com/limetext/rubex  # for oniguruma.pc
pushd "$1"
glide install
popd
fold_end "go.get_depends"
