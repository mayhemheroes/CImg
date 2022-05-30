# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git cmake clang ffmpeg fftw3 graphicsmagick imagemagick libcurlpp-dev curl \
    libjpeg-dev libpng-dev libtiff-dev libopencv-dev libx11-dev libxext-dev libxxf86vm-dev libxrandr-dev

## Add source code to the build stage. ADD prevents git clone being cached when it shouldn't
WORKDIR /
ADD https://api.github.com/repos/capuanob/CImg/git/refs/heads/mayhem version.json
RUN git clone -b mayhem https://github.com/capuanob/CImg.git
WORKDIR /CImg/fuzz

## Build
RUN mkdir -p build
WORKDIR build
RUN cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
RUN make -j$(nproc)

## Prepare all library dependencies for copy
WORKDIR /
RUN mkdir /deps
RUN cp `ldd /CImg/fuzz/fuzz-cimg | grep so | sed -e '/^[^\t]/ d' | sed -e 's/\t//' | sed -e 's/.*=..//' | sed -e 's/ (0.*)//' | sort | uniq` /deps 2>/dev/null || :

## Package Stage

FROM --platform=linux/amd64 ubuntu:20.04
COPY --from=builder /CImg/fuzz/fuzz-cimg /fuzz-cimg
COPY --from=builder /deps /usr/lib

CMD /fuzz-cimg -close_fd_mask=2
