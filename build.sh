#!/bin/bash

external="$(pwd)/external/win32"
arch=${1#--}

archs=(
  "linux32"
  "linux64"
  "linuxarmhf"
  "linuxarm64"
  "win32"
  "win64"
)

hosts=(
  ""
  ""
  "arm-linux-gnueabihf"
  "aarch64-linux-gnu"
  "i686-w64-mingw32"
  "x86_64-w64-mingw32"
)

defines=(
  "-DBUILD_SHARED=OFF -DBUILD_EXAMPLES=OFF -DDUMB=OFF -DMODPLUG=OFF"
  "-DBUILD_SHARED=OFF -DBUILD_EXAMPLES=OFF -DDUMB=OFF -DMODPLUG=OFF"
  "-DBUILD_SHARED=OFF -DBUILD_EXAMPLES=OFF -DDUMB=OFF -DMODPLUG=OFF"
  "-DBUILD_SHARED=OFF -DBUILD_EXAMPLES=OFF -DDUMB=OFF -DMODPLUG=OFF"
  "-DBUILD_SHARED=OFF -DBUILD_EXAMPLES=OFF -DDUMB=OFF -DMODPLUG=OFF -DHAS_SNDFILE=1 -DHAS_VORBISFILE=1 -DHAS_FLAC=1 -DHAS_MPG123=1 -DHAS_FLUIDSYNTH=1"
  "-DBUILD_SHARED=OFF -DBUILD_EXAMPLES=OFF -DDUMB=OFF -DMODPLUG=OFF -DHAS_SNDFILE=1 -DHAS_VORBISFILE=1 -DHAS_FLAC=1 -DHAS_MPG123=1 -DHAS_FLUIDSYNTH=1"
)

ccflags=(
  "-DCMAKE_CXX_FLAGS=-m32 -DCMAKE_C_FLAGS=-m32"
  "-DCMAKE_CXX_FLAGS=-m64 -DCMAKE_C_FLAGS=-m64"
  "-DCMAKE_TOOLCHAIN_FILE=../XCompile-ARM.txt"
  "-DCMAKE_TOOLCHAIN_FILE=../XCompile-ARM.txt"
  "-DCMAKE_CXX_FLAGS=\"-I$external/include\" -DCMAKE_TOOLCHAIN_FILE=../XCompile.txt"
  "-DCMAKE_CXX_FLAGS=\"-I$external/include\" -DCMAKE_TOOLCHAIN_FILE=../XCompile.txt"
)

output=(
  "libalure-static.a"
  "libalure-static.a"
  "libalure-static.a"
  "libalure-static.a"
  "libALURE32-static.a"
  "libALURE32-static.a"
)

openaldir=(
  ""
  ""
  ""
  ""
  "$external"
  "$external"
)

for i in ${!archs[@]}; do
  if [ ! -z ${arch} ] && [ ! ${archs[$i]} = ${arch} ]; then
    continue
  fi
  mkdir -p "build_${archs[$i]}"
  export OPENALDIR=${openaldir[$i]}
  prefix=`[ ! -z ${hosts[$i]} ] && echo ${hosts[$i]}-`
  (cd "build_${archs[$i]}" && cmake .. -DHOST=${hosts[$i]} ${ccflags[$i]} ${defines[$i]} && make)
  ${prefix}strip --strip-unneeded build_${archs[$i]}/${output[$i]}
done
