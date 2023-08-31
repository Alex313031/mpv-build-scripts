#!/bin/bash

# Copyright (c) 2023 Alex313031

YEL='\033[1;33m' # Yellow
CYA='\033[1;96m' # Cyan
RED='\033[1;31m' # Red
GRE='\033[1;32m' # Green
c0='\033[0m' # Reset Text
bold='\033[1m' # Bold Text
underline='\033[4m' # Underline Text

# Error handling
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "${RED}Failed $*"; }

# --help
displayHelp () {
	printf "\n" &&
	printf "${bold}${GRE}Script to build mpv on Linux.${c0}\n" &&
	printf "${bold}${YEL}Use the --deps install build deps.${c0}\n" &&
	printf "${bold}${YEL}Use the --bootstrap to clone & prepare the mpv repo.${c0}\n" &&
	printf "${bold}${YEL}Use the --clean flag to clean configure & build artifacts.${c0}\n" &&
	printf "${bold}${YEL}Use the --build flag to build with AVX.${c0}\n" &&
	printf "${bold}${YEL}Use the --sse4 flag to build with SSE4.1.${c0}\n" &&
	printf "${bold}${YEL}Use the --help flag to show this help.${c0}\n" &&
	printf "\n"
}
case $1 in
	--help) displayHelp; exit 0;;
esac

installDeps () {
sudo apt install libvdpau-dev python3-docutils libmujs-dev mujs libopenal-dev libass-dev uchardet libbluray-dev rubberband-cli libzimg-dev liblcms2-dev liblcms2-utils libdvdnav-dev libdvdcss2 ffmpeg libuchardet-dev librubberband-dev di libarchive-dev libavcodec-dev libavutil-dev libavformat-dev libswscale-dev libavfilter-dev libswresample-dev mesa-utils libx11-dev libxml2-dev libx264-dev libx265-dev libmp3lame-dev libfdk-aac-dev libdav1d-dev libpipewire-0.3-dev libjack-dev libcaca-dev caca-utils libplacebo-dev libsixel-dev jackd1 jack-tools figlet &&

sudo apt install libffmpeg-nvenc-dev liblua5.4-dev liblua5.4-0 liblua5.1-dev liblua5.1-0 rst2pdf libavdevice-dev libpulse-dev libva-dev libva-drm2 libva-glx2 &&

sudo apt install debhelper-compat libarchive-dev libasound2-dev libass-dev libavcodec-dev libavdevice-dev libavfilter-dev libavformat-dev libavutil-dev libbluray-dev libcaca-dev libcdio-paranoia-dev libdrm-dev libdvdnav-dev libegl1-mesa-dev libgbm-dev libffmpeg-nvenc-dev libgl1-mesa-dev libjack-dev libjpeg-dev liblcms2-dev liblua5.2-dev libmujs-dev libplacebo-dev libpulse-dev librubberband-dev libsdl2-dev libsixel-dev libspirv-cross-c-shared-dev libswscale-dev libuchardet-dev libva-dev libvdpau-dev libvulkan-dev libwayland-dev libx11-dev libxinerama-dev libxkbcommon-dev libxrandr-dev libxss-dev libxv-dev libzimg-dev pkg-config python3 python3-docutils spirv-cross wayland-protocols
}
case $1 in
	--deps) installDeps; exit 0;;
esac

bootstrapMpv () {
# You can set the version here
MPV_VER="v0.34.1"
export MPV_VER &&

rm -r -f -v ./mpv &&

git clone --recursive --recurse-submodules https://github.com/mpv-player/mpv.git &&
cd ./mpv &&
git checkout -f tags/$MPV_VER &&
./bootstrap.py
}
case $1 in
	--bootstrap) bootstrapMpv; exit 0;;
esac

wafClean () {
cd ./mpv &&
export VERBOSE=1 &&
./waf clean &&
./waf distclean
}
case $1 in
	--clean) wafClean; exit 0;;
esac

buildMpv () {
cd ./mpv &&
export CFLAGS="-pipe -DNDEBUG -O3 -mavx -maes -s -g0 -flto" &&
export CPPFLAGS="-pipe -DNDEBUG -O3 -mavx -maes -s -g0 -flto" &&
export CXXFLAGS="-pipe -DNDEBUG -O3 -mavx -maes -s -g0 -flto" &&
export LDFLAGS="-Wl,-O3 -mavx -maes -flto" &&
export VERBOSE=1 &&

./waf configure --enable-libmpv-shared --enable-cdda --enable-dvdnav --enable-sdl2 --enable-optimize --disable-debug-build --enable-vector --verbose &&
./waf -v
}
case $1 in
	--build) buildMpv; exit 0;;
esac

buildSSE4 () {
cd ./mpv &&
export CFLAGS="-pipe -DNDEBUG -O3 -msse4.1 -s -g0 -flto" &&
export CPPFLAGS="-pipe -DNDEBUG -O3 -msse4.1 -s -g0 -flto" &&
export CXXFLAGS="-pipe -DNDEBUG -O3 -msse4.1 -s -g0 -flto" &&
export LDFLAGS="-Wl,-O3 -msse4.1 -flto" &&
export VERBOSE=1 &&

./waf configure --enable-libmpv-shared --enable-cdda --enable-dvdnav --enable-sdl2 --enable-optimize --disable-debug-build --verbose &&
./waf -v
}
case $1 in
	--sse4) buildSSE4; exit 0;;
esac

printf "\n" &&
printf "${bold}${GRE}Script to build mpv on Linux.${c0}\n" &&
printf "${bold}${YEL}Use the --deps install build deps.${c0}\n" &&
printf "${bold}${YEL}Use the --bootstrap to clone & prepare the mpv repo.${c0}\n" &&
printf "${bold}${YEL}Use the --clean flag to clean configure & build artifacts.${c0}\n" &&
printf "${bold}${YEL}Use the --build flag to build with AVX.${c0}\n" &&
printf "${bold}${YEL}Use the --sse4 flag to build with SSE4.1.${c0}\n" &&
printf "${bold}${YEL}Use the --help flag to show this help.${c0}\n" &&
printf "\n"

exit 0
