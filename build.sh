#!/bin/sh

this=$(pwd)

mkdir ada
cd ada

# Create base dir's
mkdir -p proc sys dev etc var usr/{bin,lib}
ln -s usr/bin bin
ln -s usr/bin sbin
ln -s usr/lib lib
ln -s usr/lib lib64
cd usr
ln -s bin sbin
ln -s lib lib64

cd $this/sources
