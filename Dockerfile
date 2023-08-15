######################
### BASE (FIRST)
#######################

FROM quay.io/criticaljuncture/baseimage:20.04


#######################
### RUBY
#######################

ARG RUBY_VERSION=3.0-jemalloc

# install ruby
RUN apt update &&\
  apt install -y \
    # ruby
    fullstaq-ruby-common fullstaq-ruby-${RUBY_VERSION} &&\
  apt-get clean &&\
  apt-get autoremove &&\
  apt-get purge &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/


#######################
### VARIOUS PACKAGES
#######################

RUN apt-get update && apt-get install -y libcurl4-openssl-dev libpcre3-dev git libmysqlclient-dev libssl-dev mysql-client secure-delete \
    # capybara-webkit
    qt5-default \
    # aws tools
    awscli &&\
  apt-get clean &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/


##################
### NODE
##################

RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs &&\
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
### SERVICES
##################

COPY docker/web/my_init.d /etc/my_init.d
COPY docker/web/service /etc/service


###############################
### APP USER/GROUP
###############################

RUN addgroup --gid 1000 app &&\
  adduser app -uid 1000 --gid 1000 --system &&\
  usermod -a -G docker_env app &&\
  # Add app user to teletypewriter group so passenger can log to stdout
  usermod -a -G tty app

# switch to app user automatically when exec into container
RUN echo 'su - app -s /bin/bash' | tee -a /root/.bashrc


###############################
### ADDITIONAL RUBY SETUP
###############################
RUN chown -R app /usr/lib/fullstaq-ruby

# make available in default path
ENV PATH "/usr/lib/fullstaq-ruby/versions/${RUBY_VERSION}/bin:${PATH}"
USER app
ENV PATH "/usr/lib/fullstaq-ruby/versions/${RUBY_VERSION}/bin:${PATH}"
USER root

###############################
### GEMS & PASSENGER INSTALL
###############################

RUN gem install bundler -v '~> 2.0'

WORKDIR /tmp
COPY Gemfile /tmp/Gemfile
COPY Gemfile.lock /tmp/Gemfile.lock
RUN bundle install &&\
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
### APP
##################

COPY --chown=1000:1000 . /home/app/

WORKDIR /home/app

# link persisted sitemaps
RUN ln -sf /home/app/data/efs/sitemaps /home/app/public/sitemaps

RUN DB_ADAPTER=nulldb SECRET_KEY_BASE=XXX ATTACHMENTS_AWS_ACCESS_KEY_ID=XXX ATTACHMENTS_AWS_SECRET_ACCESS_KEY=XXX RAILS_ENV=production bundle exec rake assets:precompile &&\
  chown -R app /home/app

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
