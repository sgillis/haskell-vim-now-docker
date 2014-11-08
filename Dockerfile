FROM debian:wheezy

RUN apt-get update && apt-get install -y \
    libgmp-dev git libncurses5-dev libgnome2-dev libgnomeui-dev \
    libgtk2.0-dev libatk1.0-dev libbonoboui2-dev libcairo2-dev libx11-dev \
    libxpm-dev libxt-dev python-dev ruby-dev mercurial lua5.2 \
    exuberant-ctags libcurl4-gnutls-dev wget locales tmux

RUN mkdir -p /git && mkdir -p /haskell && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

WORKDIR /git

RUN hg clone https://code.google.com/p/vim/

WORKDIR /git/vim

RUN ./configure --with-features=huge \
                --enable-rubyinterp \
                --enable-pythoninterp \
                --enable-luainterp && \
    make && \
    make install && \
    ln -s /usr/local/bin/vim /usr/bin/vim

WORKDIR /haskell

RUN wget https://www.haskell.org/ghc/dist/7.8.3/ghc-7.8.3-x86_64-unknown-linux-deb7.tar.bz2 && \
    tar xvfj ghc-7.8.3-x86_64-unknown-linux-deb7.tar.bz2

WORKDIR /haskell/ghc-7.8.3

RUN mkdir -p /haskell/bin/ghc-7.8.3 && \
    ./configure --prefix=/haskell/bin/ghc-7.8.3 && \
    make install

ENV PATH /haskell/bin/ghc-7.8.3/bin:$PATH

WORKDIR /haskell

RUN wget https://www.haskell.org/cabal/release/cabal-1.20.0.2/Cabal-1.20.0.2.tar.gz && \
    tar xzvf Cabal-1.20.0.2.tar.gz

WORKDIR /haskell/Cabal-1.20.0.2

RUN ghc --make Setup.hs && \
    ./Setup configure && \
    ./Setup build && \
    ./Setup install

WORKDIR /haskell/

RUN wget http://www.haskell.org/cabal/release/cabal-install-1.20.0.3/cabal-install-1.20.0.3.tar.gz && \
    tar xzvf cabal-install-1.20.0.3.tar.gz

WORKDIR /haskell/cabal-install-1.20.0.3

RUN ./bootstrap.sh

ENV CABAL_HOME /.cabal
ENV PATH /.cabal/bin:/haskell/bin/ghc-7.8.3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

WORKDIR /git

RUN cabal update && cabal install happy

ADD install.sh /git/install.sh

RUN chmod +x /git/install.sh

ENV LANG en_US.utf8
RUN /git/install.sh
