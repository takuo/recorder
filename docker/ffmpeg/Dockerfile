FROM ubuntu:18.04

WORKDIR /tmp/workdir

RUN apt-get -yqq update && apt-get install -yq --no-install-recommends \
      ca-certificates expat \
      ubuntu-restricted-addons 
 
# FROM base AS build

RUN apt-get install -y --no-install-recommends git libva-dev \
    autoconf automake build-essential libass-dev libtool pkg-config texinfo zlib1g-dev libva-dev cmake mercurial libdrm-dev libvorbis-dev libogg-dev git libx11-dev libperl-dev libpciaccess-dev libpciaccess0 xorg-dev libfdk-aac-dev libx264-dev libx265-dev libopus-dev

RUN apt-get build-dep -y --no-install-recommends ffmpeg

RUN apt-get install libssl-dev libx265-dev

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

# FROM base AS release
MAINTAINER takuo kitame@gmail.com

CMD ["--help"]
ENTRYPOINT ["ffmpeg"]

# COPY --from=build /usr/local /usr/local/
RUN \
	apt-get update -y && \
	apt-get install -y --no-install-recommends libva-drm2 libva2 i965-va-driver vainfo && \
        apt-get autoremove -y && apt-get clean -y
#	rm -rf /var/lib/apt/lists/*

