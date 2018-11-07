######################
### BASE (FIRST)
#######################

FROM quay.io/criticaljuncture/baseimage:16.04


#######################
### RUBY
#######################

RUN apt-get update && apt-get install -y ruby2.0 ruby2.0-dev


#######################
### VARIOUS PACKAGES
#######################

RUN apt-get update && apt-get install -y libcurl4-openssl-dev libpcre3-dev git libmysqlclient-dev mysql-client secure-delete \
  # capybara-webkit
  libqt4-dev libqtwebkit-dev &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

# node js - packages are out of date
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - &&\
  apt-get install -y nodejs &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/

# npm packages for testing
RUN npm install -g jshint
RUN npm install -g coffeelint


##################
### TIMEZONE
##################

RUN ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime


##################
### APP USER
##################

RUN adduser app -uid 1000 --system &&\
  usermod -a -G docker_env app


###############################
### GEMS & PASSENGER INSTALL
###############################

RUN gem install bundler

WORKDIR /tmp
COPY Gemfile /tmp/Gemfile
COPY Gemfile.lock /tmp/Gemfile.lock
RUN bundle install --system --full-index &&\
  passenger-config install-standalone-runtime &&\
  passenger start --runtime-check-only


# docker cached layer build optimization:
# caches the latest security upgrade versions
# at the same time we're doing something else slow (changing the bundle)
# but something we do often enough that the final unattended upgrade at the
# end of this dockerfile isn't installing the entire world of security updates
# since we set up the dockerfile for the project
RUN apt-get update && unattended-upgrade -d


ENV PASSENGER_MIN_INSTANCES 1
ENV WEB_PORT 3000


##################
### SERVICES
##################

COPY docker/web/my_init.d /etc/my_init.d
COPY docker/web/service /etc/service


##################
### APP
##################

COPY --chown=1000:1000 . /home/app/

WORKDIR /home/app

RUN DB_ADAPTER=nulldb DEVISE_SECRET_KEY=XXX AWS_ACCESS_KEY_ID=XXX AWS_SECRET_ACCESS_KEY=XXX RAILS_ENV=production bundle exec rake assets:precompile &&\
  chown -R app /home/app/public

# CI setup
RUN mkdir log/test/ && touch log/test/vcr.log && chown -R app log


##################
### BASE (LAST)
##################

# ensure all packages are as up to date as possible
# installs all updates since we last bundled
RUN apt-get update && unattended-upgrade -d

# set terminal
ENV TERM=linux
