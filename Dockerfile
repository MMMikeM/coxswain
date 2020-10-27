FROM ruby:2.7.1-alpine

RUN export TERM=xterm
RUN apt-get update
RUN apk add -y openssl wget curl vim nginx apache2-utils

WORKDIR /app

RUN service nginx stop
RUN mkdir -p /etc/nginx
RUN mkdir -p /etc/nginx/conf.d
RUN mkdir -p /etc/nginx/certs
RUN mkdir -p versions

COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh .
COPY spec spec

RUN gem install bundler
COPY Gemfile Gemfile
RUN bundle install

COPY /api /app/api
COPY config.ru /app/config.ru
