FROM debian:sid
ARG prefix=/tmp/bootstrap_ghc
ARG extra_config

COPY debian-src.sources /etc/apt/sources.list.d/debian-src.sources
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  libtinfo5 \
  autoconf automake libtool make libgmp-dev ncurses-dev g++ bzip2 ca-certificates \
  llvm xz-utils \
  ghc \
  alex \
  cabal-install \
  happy \
  python3 \
  dpkg-dev sudo \
  && apt-get clean

ENV LANG     C.UTF-8
ENV LC_ALL   C.UTF-8
ENV LANGUAGE C.UTF-8
RUN useradd -m -d /home/ghc -s /bin/bash ghc
RUN echo "ghc ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ghc && chmod 0440 /etc/sudoers.d/ghc
ENV HOME /home/ghc
WORKDIR /home/ghc
USER ghc

RUN apt-get source ghc
RUN ln -s ghc-* ghc_build
WORKDIR ghc_build

RUN [ -f mk/build.mk ] || mv mk/build.mk.sample mk/build.mk
RUN sed -i -e '/BuildFlavour = quick/s/^#//' mk/build.mk
RUN ./boot
RUN ./configure --prefix="${prefix}" ${extra_config}
RUN make
RUN sudo make install
