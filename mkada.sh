#!/bin/sh
# Pre
mkdir ada sources

this=$(pwd)
sources=$this/sources
files=$this/files
ada=$this/ada

load_func() {
    cd $sources
    echo "$1 (v$2) download"
    curl $3/"$1"-"$2".tar.gz -o $1.tar.gz
    tar -xvf $1.tar.gz
    rm $1.tar.gz
    mv $1-"$2" $1
}

sc_install() {
    cd $sources/"$1"
    ./configure --prefix=/usr CC="musl-gcc"
    make -j $(nproc)
    make install -j $(nproc) DESTDIR=$ada
}

# Start
base_dirs() {
    cd $ada
    mkdir proc sys dev boot
    mkdir -p usr/{bin,lib}

    ln -s usr/bin bin
    ln -s usr/bin sbin
    ln -s usr/lib lib
    ln -s usr/lib lib64
    cd usr
    ln -s bin sbin
    ln -s lib lib64
}

kernel() {
    linux_major=7
    linux_minor=2
    linux_patch=15

    linux="$linux_major.$linux_minor.$linux_patch"
    load_func linux $linux https://www.kernel.org/pub/linux/kernel/v$linux_major.x

    cd $sources/linux
    make defconfig
    make -j $(nproc)
    cp arch/x86/boot/bzImage $ada/boot/
}

dash() {
    dash_version="0.5.13.5"
    load_func dash $dash_version http://gondor.apana.org.au/~herbert/dash/files
    sc_install dash
    cd $ada/usr/bin
    ln -s dash sh
}

sbase() {
    cd $sources
    git clone git://git.suckless.org/sbase
    cd $sources/sbase
    make sbase-box -j $(nproc) CC="musl-gcc"
    make sbase-box-install -j $(nproc) PREFIX=/usr DESTDIR=$ada CC="musl-gcc"
}

ubase() {
    cd $sources
    git clone git://git.suckless.org/ubase
    cd $sources/ubase
    make ubase-box -j $(nproc) CC="musl-gcc"
    make ubase-box-install -j $(nproc) PREFIX=/usr DESTDIR=$ada CC="musl-gcc"
}

musl() {
    musl_version="1.2.6"
    load_func musl $musl_version https://musl.libc.org/releases
    cd $sources/musl
    ./configure --libdir=/lib --prefix=/usr CC="musl-gcc"
    make -j $(nproc)
    make install -j $(nproc) DESTDIR=$ada
}

sinit() {
    cd $sources
    git clone git://git.suckless.org/sinit
    cd $sources/sinit
    make -j $(nproc) CC="musl-gcc"
    make install -j $(nproc) PREFIX=/usr DESTDIR=$ada CC="musl-gcc"
    cd $ada/usr/bin
    ln -s sinit init

    cp $files/rc.init $ada/bin/
    chmod +x $ada/bin/rc.init
}

run() {
    #base_dirs
    kernel
    #dash
    #sbase
    #ubase
    #musl
    #sinit
}

run
