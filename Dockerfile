FROM ubuntu:trusty
MAINTAINER Armen K
ENV SYSTEMC_VERSION 2.3.0a

RUN apt-get update -q && apt-get install -qy --no-install-recommends \
      ca-certificates build-essential wget curl libboost-dev python-dev libglib2.0-dev libpixman-1-dev liblua5.2-dev swig git telnet \
      cmake \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/src/systemc \
 && cd /usr/src/systemc \
 && wget http://accellera.org/images/downloads/standards/systemc/systemc-$SYSTEMC_VERSION.tar.gz \
 && tar -xvf systemc-$SYSTEMC_VERSION.tar.gz \
 && rm -rf systemc-$SYSTEMC_VERSION.tar.gz \
 && cd /usr/src/systemc/systemc-$SYSTEMC_VERSION \
 && mkdir objdir \
 && cd objdir \
 && export CXX=g++ \
 && mkdir -p /usr/local/systemc-$SYSTEMC_VERSION \
 && ../configure --prefix=/usr/local/systemc-$SYSTEMC_VERSION \
 && make \
 && make install \
 && make check \
 && cd / \
 && rm -rf /usr/src/systemc

ENV CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/usr/local/systemc-$SYSTEMC_VERSION/include
ENV LIBRARY_PATH=$LIBRARY_PATH:/usr/local/systemc-$SYSTEMC_VERSION/lib-linux64
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/systemc-$SYSTEMC_VERSION/lib-linux64
ENV SYSTEMC_HOME=/usr/local/systemc-$SYSTEMC_VERSION

RUN mkdir -p /greensocs \
    && cd /greensocs
    && git clone https://git.greensocs.com/platforms/versatile-pb.git \
    && cd versatile-pb \
    && git submodule update --init \
    && cd libs/qbox \
    && git submodule update --init dtc \
    && cd ../.. \
    && cmake -DCMAKE_INSTALL_PREFIX=build -DSYSTEMC_PREFIX=/usr/local/systemc-$SYSTEMC_VERSION \
    && make \
    && make install
