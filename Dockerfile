FROM ruby:2.7.1-alpine

RUN apk update
RUN apk add openssl nginx build-base openrc

RUN mkdir /run/openrc
RUN mkdir /run/nginx
RUN touch /run/openrc/softlevel

WORKDIR /app

RUN gem install bundler
COPY Gemfile* ./
RUN bundle install

RUN mkdir -p /etc/nginx
RUN mkdir -p /etc/nginx/conf.d
RUN mkdir -p /etc/nginx/certs
RUN mkdir -p versions
RUN mkdir -p /var/www/root/html

# COPY nginx.conf /etc/nginx/nginx.conf
COPY frontend/build /var/www/root/html

COPY /api /app/api
COPY config.ru /app/config.ru
COPY entrypoint.sh /app/entrypoint.sh
