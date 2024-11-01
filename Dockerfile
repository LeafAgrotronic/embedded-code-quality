FROM ubuntu:focal

RUN apt-get -y update && \
    apt-get -y upgrade && \
    DEBIAN_FRONTEND="noninteractive" \
    apt-get install --no-install-recommends -y \
        bzr \
        ruby-full \
        python3-pip \
        lcov \
        cppcheck \
        uncrustify \
        bison \
        flex \
        wget \
        gcc-multilib \
        g++-multilib \
        build-essential \
        clang \
        clang-tidy \
        clang-format \
        tzdata && \
    rm -rf /var/lib/apt/lists/*
RUN gem install \
        ceedling
RUN pip install \
        gcovr \
        gitlint
RUN pip3 install \
        codechecker

# Download, build and install cmake
ARG CMAKE_VERSION=3.28.0
RUN wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION.tar.gz && \
    tar -xvzf cmake-$CMAKE_VERSION.tar.gz
RUN cd cmake-$CMAKE_VERSION && \
    ./bootstrap -- -DCMAKE_USE_OPENSSL=OFF && make && make install && \
    cmake --version && \
    rm -f /cmake-$CMAKE_VERSION.tar.gz

# Download, build and install uno
RUN wget http://www.spinroot.com/uno/uno_v214.tar.gz && \
    tar -xf uno_v214.tar.gz && cd uno/src && \
    cf='-DPC -ansi -Wall -ggdb -DCPP="\\"gcc -E\\"" -DBINDIR=\\"$(BINDIR)\\"' && \
    sed -i "s/^CFLAGS=.*/CFLAGS=${cf}/" makefile && \
    make && make install && \
    uno -V | grep -q "Version 2.14" && test $? && \
    cd / && rm -f uno_v214.tar.gz

# Download, build and install infer
ARG INFER_VERSION=1.1.0
RUN wget https://github.com/facebook/infer/releases/download/v$INFER_VERSION/infer-linux64-v$INFER_VERSION.tar.xz && \
    tar xvf infer-linux64-v$INFER_VERSION.tar.xz -C /opt/ && rm -f infer-linux64-v$INFER_VERSION.tar.xz && \
    ln -s "/opt/infer-linux64-v$INFER_VERSION/bin/infer" /usr/local/bin/infer

# Create a custom user with UID 1234 and GID 1234
ARG user=appuser
ARG group=appgroup
RUN groupadd -g 1000 $group && \
    useradd -m -u 1000 -g $group $user
 
# Switch to the custom user
USER $user:$group

WORKDIR /usr/project
