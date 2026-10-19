#!/bin/sh

this=$(pwd)
sources=$this/sources

mkdir ada
ada=$this/ada
cd $ada

# Create base dir's
mkdir -p proc sys dev etc var usr/{bin,lib}
ln -s usr/bin bin
ln -s usr/bin sbin
ln -s usr/lib lib
ln -s usr/lib lib64
cd usr
ln -s bin sbin
ln -s lib lib64

mk() {
    make -j $(nproc)
    make install -j $(nproc)
}

sc_install() {
    cd $sources/"$1"
    ./configure --prefix "$ada"
    mk
}

glibc() {
    cd $sources/glibc
    mkdir build
    cd build
    ../configure --prefix "$ada"
    mk
}

dash() {
    sc_install dash
    cd $ada/usr/bin
    ln -s dash sh
}

toybox() {
    cd $sources/toybox
    ./configure --prefix "$ada"
    make defconfig
    mk
}

all_build() {
    glibc
    dash
    toybox
    sc_install gzip
    sc_install tar
}

all_build
