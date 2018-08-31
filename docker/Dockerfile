FROM ubuntu:18.04

WORKDIR /tmp/workdir

RUN apt-get -yqq update && apt-get install -yq --no-install-recommends \
      ca-certificates expat ruby mediainfo \
      ubuntu-restricted-addons 
 
# FROM base AS build

RUN apt-get install -y --no-install-recommends git libva-dev \
    autoconf automake build-essential libass-dev libtool pkg-config texinfo zlib1g-dev libva-dev cmake mercurial libdrm-dev libvorbis-dev libogg-dev git libx11-dev libperl-dev libpciaccess-dev libpciaccess0 xorg-dev libfdk-aac-dev libx264-dev libx265-dev libopus-dev libssl-dev

RUN apt-get build-dep -y --no-install-recommends ffmpeg

# x265
RUN hg clone https://bitbucket.org/multicoreware/x265
RUN cd x265/build/linux && cmake -G "Unix Makefiles" -DENABLE_SHARED:bool=off ../../source && make && make install

# libaom
RUN git clone https://aomedia.googlesource.com/aom
RUN mkdir aom_build && cd aom_build && cmake -G "Unix Makefiles" -DENABLE_SHARED:bool=off -DENABLE_NASM:bool=on ../aom && make && make install

# libkvazaar
RUN git clone https://github.com/ultravideo/kvazaar
RUN cd kvazaar && ./autogen.sh && ./configure --disable-shared && make && make install

RUN git clone https://github.com/FFmpeg/FFmpeg.git 
RUN cd FFmpeg && ./configure \
        --pkg-config-flags="--static" \
        --disable-debug \
        --disable-doc \
        --disable-ffplay \
        --enable-vaapi \
        --enable-libvorbis \
        --enable-libvpx \
        --enable-avresample \
        --enable-libopencore-amrnb \
        --enable-libopencore-amrwb \
        --cpu=native \
        --enable-gpl \
        --enable-libass \
        --enable-libfreetype \
        --enable-libmp3lame \
        --enable-libopenjpeg \
        --enable-libopus \
        --enable-libtheora \
        --enable-libvorbis \
        --enable-libvpx \
        --enable-libxvid \
        --enable-libx264 \
        --enable-libx265 \
        --enable-libaom \
        --enable-libkvazaar \
        --enable-nonfree \
        --enable-openssl \
        --enable-libfdk-aac \
        --enable-opengl \
        --enable-postproc \
        --enable-small \
        --enable-version3 \
        --extra-libs=-lpthread \
        --extra-libs=-ldl \
        --prefix=/usr/local && \
        make && make install && make distclean

## golang

ENV GOPATH /usr/local/go
ENV PATH $GOPATH/bin:$PATH
RUN apt-get install -yqq --no-install-recommends golang
RUN mkdir $GOPATH
RUN mkdir -p $GOPATH/src
RUN git clone https://github.com/takuo/skicka -b add-desc-command $GOPATH/src/github.com/google/skicka
RUN cd $GOPATH/src/github.com/google/skicka && go get .


## TsSplitter.exe
RUN apt-get update && apt-get install -y wget gnupg software-properties-common
RUN wget -nc https://dl.winehq.org/wine-builds/Release.key
RUN apt-key add Release.key && rm Release.key
RUN apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'

RUN dpkg --add-architecture i386
RUN apt-get -yqq update && apt-get install -yq --install-recommends \
       wine-stable
ENV PATH /opt/wine-stable/bin:$PATH
RUN winecfg

COPY TsSplitter.exe /usr/local/bin/

# FROM base AS release
MAINTAINER takuo kitame@gmail.com

# COPY --from=build /usr/local /usr/local/
COPY tsenc /usr/local/bin/
RUN \
	apt-get update -y && \
	apt-get install -y --no-install-recommends libva-drm2 libva2 i965-va-driver vainfo && \
        apt-get clean -y && \
	rm -rf /var/lib/apt/lists/*

