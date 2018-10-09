#!/bin/bash

HOST_arm=arm-linux-androideabi
CPPFLAGS_arm="-fpic -ffunction-sections -funwind-tables -fstack-protector-strong -no-canonical-prefixes -march=armv5te -mtune=xscale -msoft-float -fno-exceptions -fno-rtti -marm -O2 -DNDEBUG -DANDROID -Wa,--noexecstack -fomit-frame-pointer -fno-strict-aliasing"
LDFLAGS_arm="-no-canonical-prefixes -march=armv5te -Wl,--build-id -Wl,--no-undefined -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now -Wl,--warn-shared-textrel -marm"

HOST_armv7a=arm-linux-androideabi
CPPFLAGS_armv7a="-fpic -ffunction-sections -funwind-tables -fstack-protector-strong -no-canonical-prefixes -march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp -fno-exceptions -fno-rtti -marm -O2 -DNDEBUG -DANDROID -Wa,--noexecstack -fomit-frame-pointer -fno-strict-aliasing"
LDFLAGS_armv7a="-no-canonical-prefixes -march=armv7-a -Wl,--fix-cortex-a8 -Wl,--build-id -Wl,--no-undefined -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now -Wl,--warn-shared-textrel -marm"

HOST_arm64v8a=aarch64-linux-android
CPPFLAGS_arm64v8a="-fpic -ffunction-sections -funwind-tables -fstack-protector-strong -no-canonical-prefixes -fno-exceptions -fno-rtti -O2 -DNDEBUG -DANDROID  -Wa,--noexecstack -fomit-frame-pointer -fstrict-aliasing -funswitch-loops"
LDFLAGS_arm64v8a="-no-canonical-prefixes -Wl,--build-id -Wl,--no-undefined -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now -Wl,--warn-shared-textrel"

HOST_x86=i686-linux-android
CPPFLAGS_x86="-ffunction-sections -funwind-tables -no-canonical-prefixes -fstack-protector-strong -fno-exceptions -fno-rtti -O2 -DNDEBUG -DANDROID -Wa,--noexecstack -mstackrealign -mstack-protector-guard=global -fomit-frame-pointer -fstrict-aliasing -funswitch-loops"
LDFLAGS_x86="-no-canonical-prefixes -Wl,--build-id -Wl,--no-undefined -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now -Wl,--warn-shared-textrel"

HOST_x86_64=x86_64-linux-android
CPPFLAGS_x86_64="-ffunction-sections -funwind-tables -fstack-protector-strong -no-canonical-prefixes -fno-exceptions -fno-rtti -O2 -DNDEBUG -DANDROID -Wa,--noexecstack -fomit-frame-pointer -fstrict-aliasing -funswitch-loops"
LDFLAGS_x86_64="-no-canonical-prefixes -Wl,--build-id -Wl,--no-undefined -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now -Wl,--warn-shared-textrel"

external="$(pwd)/external/android"
toolchain_path="/opt/android-toolchains"

toolchains=(
  "arm"
  "arm"
  "arm64"
  "x86"
  "x86_64"
)

archs=(
  "armeabi"
  "armeabi-v7a"
  "arm64-v8a"
  "x86"
  "x86_64"
)

hosts=(
  "$HOST_arm"
  "$HOST_armv7a"
  "$HOST_arm64v8a"
  "$HOST_x86"
  "$HOST_x86_64"
)

cppflags=(
  "$CPPFLAGS_arm -DHAS_VORBISIDEC"
  "$CPPFLAGS_armv7a -DHAS_VORBISIDEC"
  "$CPPFLAGS_arm64v8a"
  "$CPPFLAGS_x86"
  "$CPPFLAGS_x86_64"
)

ldflags=(
  "$LDFLAGS_arm"
  "$LDFLAGS_armv7a"
  "$LDFLAGS_arm64v8a"
  "$LDFLAGS_x86"
  "$LDFLAGS_x86_64"
)

defines="-DBUILD_SHARED=OFF -DBUILD_EXAMPLES=OFF -DDYNLOAD=OFF -DDUMB=OFF -DMODPLUG=OFF -DFLUIDSYNTH=OFF -DHAS_SNDFILE=1 -DHAS_VORBISFILE=1 -DHAS_FLAC=1 -DHAS_MPG123=1"
flags="-DCMAKE_CXX_FLAGS=\"-I$external/include\" -DCMAKE_TOOLCHAIN_FILE=../XCompile-Android.txt"
output="libalure-static.a"

export OPENALDIR=$external

for i in ${!archs[@]}; do
  mkdir -p "build_${archs[$i]}"
  export NDK_TOOLCHAIN_PATH=$toolchain_path/${toolchains[$i]}
  (cd "build_${archs[$i]}" && cmake .. $flags -DHOST=${hosts[$i]} -DCPPFLAGS="${cppflags[$i]}" -DLDFLAGS="${ldflags[$i]}" $defines && make)
  prefix=`[ ! -z ${hosts[$i]} ] && echo ${hosts[$i]}-`
  ${prefix}strip --strip-unneeded build_${archs[$i]}/$output
done
