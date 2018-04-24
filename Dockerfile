FROM ubuntu:16.04
MAINTAINER Matteo Visconti dOC <mvdoc.gr@dartmouth.edu>

RUN apt-get update && apt-get install -y \
      build-essential \
      cmake \
      git \
      libatlas-base-dev \
      libatlas-dev \
      libboost-all-dev \
      libgflags-dev \
      libgoogle-glog-dev \
      libhdf5-dev \
      libleveldb-dev \
      liblmdb-dev \
      libopencv-dev \
      libprotobuf-dev \
      lsb-release \
      protobuf-compiler \
      python-dev \
      python-numpy \
      python-pip \
      python-setuptools \
      python-scipy \
      wget \
    && rm -rf /var/lib/apt/lists/* && \
    sync

ENV OPENPOSE_ROOT=/opt/openpose
WORKDIR $OPENPOSE_ROOT

RUN git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose $OPENPOSE_ROOT && \
    git checkout v1.3.0 && \
    sync

RUN sed -i 's/sudo -H //g;s/sudo //g' ubuntu/install_cmake.sh && \
    bash ubuntu/install_cmake.sh &&
    rm -rf /var/lib/apt/lists/* && \
    sync

# set up CPU only and build
RUN mkdir build && \
    sed -i 's/GPU_MODE CUDA/GPU_MODE CPU_ONLY/' CMakeLists.txt && \
    cd build && \
    cmake .. && \
    make && \
    sync
