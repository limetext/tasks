#!/usr/bin/env bash

source "$(dirname -- "$0")/setup.sh"

if [ "$TRAVIS_OS_NAME" == "linux" ]; then

	echo "Package installs configured in .travis.yml"

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

fold_start "go.get_cov" "go get coverage tools"

go get github.com/mattn/goveralls
go get github.com/axw/gocov/gocov

fold_end "go.get_cov"

fold_start "go.get_depends" "go get dependencies"

go get "$1/..."

# Repeat the get to work around golang/go#12573.
go get -u "$1/..."

fold_end "go.get_depends"
