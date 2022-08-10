# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang ffmpeg fftw3 graphicsmagick imagemagick libcurlpp-dev curl \
    libjpeg-dev libpng-dev libtiff-dev libopencv-dev libx11-dev libxext-dev libxxf86vm-dev libxrandr-dev

ADD . /CImg
WORKDIR /CImg/fuzz

## Build
RUN mkdir -p build
WORKDIR build
RUN cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
RUN make -j$(nproc)

## Package Stage
FROM --platform=linux/amd64 ubuntu:20.04
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y libtiff5 libjpeg-turbo8 zlib1g libpng16-16 libopenexr24 libilmbase24 libxext6 libxrandr2 libx11-6 libgcc-s1 libwebp6 libzstd1 liblzma5 libjbig0 libxrender1 libxcb1 libxau6 libxdmcp6 libbsd0
COPY --from=builder /CImg/fuzz/fuzz-cimg /fuzz-cimg
