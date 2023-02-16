FROM ruby:3.2.1

ENV LANG=C.UTF-8

RUN echo "gem: --no-document" > $HOME/.gemrc && \
    touch $HOME/.irb-history && \
    echo "IRB.conf[:SAVE_HISTORY] = 1000\nIRB.conf[:HISTORY_FILE] = '~/.irb-history'" > $HOME/.irbrc

RUN mkdir /ruby_app
WORKDIR /ruby_app

# Upgrade RubyGems and install latest Bundler
RUN gem update --system && \
    gem install bundler

COPY Gemfile Gemfile.lock ./
RUN bundle config --global jobs `grep -c cores /proc/cpuinfo` && \
    bundle config --delete bin
RUN bundle install

COPY . .

CMD "bin/bot"
