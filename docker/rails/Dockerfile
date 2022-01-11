FROM ruby:2.6.5

WORKDIR /usr/src/app
COPY ./TestSite/ .

RUN gem update --system && gem uninstall bundler && \
    rm /usr/local/bin/bundle && rm /usr/local/bin/bundler
RUN gem install bundler:2.1.4 && bundle install
RUN apt update -y && apt install npm -y && apt install dumb-init -y
RUN npm install --global yarn
RUN yarn install --check-files

CMD ["/bin/bash", "start_rails.sh"]