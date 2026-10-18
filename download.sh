#!/bin/sh

linux_major=7
linux_minor=2
linux_patch=11

toybox="0.8.9"
dash="0.5.13.5"
#dinit=""
#glibc=""
#nano=""
#util-linux=""

load_func() {
    echo "$1 (v$2) download"
    curl $3/"$1"-"$2".tar.gz -o $1.tar.gz
    tar -xvf $1.tar.gz
    rm $1.tar.gz
    mv $1-"$2" $1
}

linux="$linux_major.$linux_minor.$linux_patch"

mkdir sources
cd sources

all_load() {
    load_func linux $linux https://www.kernel.org/pub/linux/kernel/v$linux_major.x
    load_func toybox $toybox https://landley.net/toybox/downloads
    load_func dash $dash http://gondor.apana.org.au/~herbert/dash/files
}

#all_load
