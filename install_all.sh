#!/bin/bash -e
#
#  Copyright (c) 2014, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under the BSD-style license found in the
#  LICENSE file in the root directory of this source tree. An additional grant
#  of patent rights can be found in the PATENTS file in the same directory.
#

echo
echo This script will install fblualib and all its dependencies.
echo It has been tested on Ubuntu 13.10 and Ubuntu 14.04, Linux x86_64.
echo

set -e
set -x


dir=$(mktemp --tmpdir -d fblualib-build.XXXXXX)

echo Working in $dir
echo
cd $dir

echo Installing required packages
echo

echo
echo Cloning repositories
echo
if [ $current -eq 1 ]; then
    git clone --depth 1 https://github.com/facebook/fbthrift
    git clone https://github.com/facebook/thpp
    git clone https://github.com/facebook/fblualib
    git clone https://github.com/facebook/wangle
else
    git clone -b v0.24.0  --depth 1 https://github.com/facebook/fbthrift
    git clone -b v1.0 https://github.com/facebook/thpp
    git clone -b v1.0 https://github.com/facebook/fblualib
fi

brew install folly

if [ $current -eq 1 ]; then
    echo
    echo Wangle
    echo

    cd $dir/wangle/wangle
    cmake .
    make
    sudo make install
fi

echo
echo Building fbthrift
echo

cd $dir/fbthrift/thrift
autoreconf -ivf
./configure
if [ $current -eq 1 ]; then
    pushd lib/cpp2/fatal/internal
    ln -s folly_dynamic-inl-pre.h folly_dynamic-inl.h
    popd
fi
make
sudo make install

echo
echo 'Installing TH++'
echo

cd $dir/thpp/thpp
./build.sh

echo
echo 'Installing FBLuaLib'
echo

cd $dir/fblualib/fblualib
./build.sh

echo
echo 'All done!'
echo
