FROM ubuntu:16.04
MAINTAINER Matteo Visconti di Oleggio Castello <mvdoc.gr@dartmouth.edu>


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
ENV OPENPOSE_SRC=/tmp/openpose-src
WORKDIR $OPENPOSE_ROOT
WORKDIR $OPENPOSE_SRC
RUN git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose $OPENPOSE_SRC && \
    git checkout v1.3.0 && \
    sync


#RUN sed -i 's/sudo -H //g;s/sudo //g' ubuntu/install_cmake.sh && \
#    bash ubuntu/install_cmake.sh && \
#    rm -rf /var/lib/apt/lists/* && \
#    sync

# set up CPU only and build
RUN cmake -DGPU_MODE=CPU_ONLY -DUSE_MKL=OFF -B$OPENPOSE_ROOT -H$OPENPOSE_SRC && \
    cd $OPENPOSE_ROOT && \
    make -j`nproc` && \
    rm -rf $OPENPOSE_SRC && \
    sync

WORKDIR $OPENPOSE_ROOT

# copy from neurodocker code
ENV OP_ENTRYPOINT="/opt/openpose.sh"
RUN echo '#!/usr/bin/env bash' >> $OP_ENTRYPOINT \
    && echo 'if [ -z "$*" ]; then /usr/bin/env bash; else $OPENPOSE_ROOT/examples/openpose/openpose.bin $*; fi' >> $OP_ENTRYPOINT \
    && chmod -R 777 /opt && chmod a+s /opt

ENTRYPOINT ["/opt/openpose.sh"]
