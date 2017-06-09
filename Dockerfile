FROM ubuntu:trusty
MAINTAINER leonas@leonas.io

RUN locale-gen en_US en_US.UTF-8 \
  && dpkg-reconfigure locales

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install general dependencies
RUN apt-get update && apt-get install -y build-essential git curl libssl-dev libreadline-dev zlib1g-dev python3-dev

# install nvm with node4 and node6
ENV NVM_DIR /usr/local/nvm
ENV NODE_DEFAULT_VERSION 4
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.31.3/install.sh | bash \
  && . "$NVM_DIR/nvm.sh" \
  && nvm install $NODE_DEFAULT_VERSION \
  && nvm install 6 \
  && nvm use $NODE_DEFAULT_VERSION \
  && echo 'export OLD_PREFIX=$PREFIX && unset PREFIX' > $HOME/.profile \
  && echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> $HOME/.profile \
  && echo 'export PREFIX=$OLD_PREFIX && unset OLD_PREFIX' >> $HOME/.profile


  # RUN mkdir -p /app
  # WORKDIR /app

RUN apt-get update && \
    apt-get install -y autoconf \
                       bison \
                       build-essential \
                       curl \
                       git \
                       libffi-dev \
                       libgdbm-dev \
                       libgdbm3 \
                       libncurses5-dev \
                       libpq-dev \
                       libreadline6-dev \
                       libssl-dev \
                       libyaml-dev \
                       nodejs \
                       libsqlite3-dev \
                       zlib1g-dev && \
      apt-get autoremove -y && \
      apt-get clean


RUN git clone --depth 1 https://github.com/sstephenson/rbenv.git /root/.rbenv && \
      git clone --depth 1 https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build && \
      rm -rfv /root/.rbenv/plugins/ruby-build/.git && \
      rm -rfv /root/.rbenv/.git && \
      export PATH="/root/.rbenv/bin:$PATH" && \
      eval "$(rbenv init -)" && \
      rbenv install '2.3.2' && \
      rbenv global '2.3.2' && \
      gem install bundler --no-ri --no-rdoc && \
      rbenv rehash

ENV PATH /root/.rbenv/bin:/root/.rbenv/shims:$PATH
RUN echo "export PATH=$PATH" >> /root/.bashrc



RUN gem install bundler jekyll --no-ri --no-rdoc

WORKDIR /tmp
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN bundle install

RUN mkdir -p /src
VOLUME ["/src"]
WORKDIR /src
ADD . /src

EXPOSE 4000

# CMD ["/src/jekyll-serve.sh"]
CMD ["bundle", "exec", "jekyll", "serve", "--drafts", "--incremental", "--host", "0.0.0.0"]
