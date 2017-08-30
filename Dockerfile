FROM quay.io/criticaljuncture/baseimage:16.04

RUN apt-get install software-properties-common
RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update && apt-get install -y ruby1.9.3 ruby1.9.1-dev

# libqt4-dev libqtwebkit-dev are for capybara-webkit
RUN apt-get update && apt-get install -y build-essential libcurl4-openssl-dev libpcre3-dev git libmysqlclient-dev nodejs libqt4-dev libqtwebkit-dev &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

# rack version compatible with 1.9.3
RUN gem install rack --version 1.6.4
RUN gem install passenger --version 5.1.6
RUN gem install rake --version 11.3.0
RUN passenger-config install-standalone-runtime &&\
  passenger-config build-native-support &&\
  passenger start --runtime-check-only

RUN ln -sf /usr/share/zoneinfo/US/Pacific /etc/localtime

COPY docker/web/service/web/run /etc/service/web/run
COPY docker/web/my_init.d /etc/my_init.d

RUN adduser app -uid 1000 --system

RUN gem install bundler --version 1.13.6
WORKDIR /tmp
COPY Gemfile /tmp/Gemfile
COPY Gemfile.lock /tmp/Gemfile.lock
RUN bundle install --system

ENV DEVISE_SECRET_KEY XXXXXXXXX

COPY . /home/app/

WORKDIR /home/app

RUN DB_ADAPTER=nulldb RAILS_ENV=production bundle exec rake assets:precompile &&\
  chown -R app /home/app

ENV TERM=linux
