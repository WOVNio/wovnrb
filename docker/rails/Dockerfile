FROM ruby:2.6.5

WORKDIR /usr/src/app

COPY ./TestSite/ .

RUN gem update --system
RUN gem uninstall bundler && rm /usr/local/bin/bundle && rm /usr/local/bin/bundler
RUN gem install bundler:2.1.4
RUN apt update && apt install npm -y
RUN npm install --global yarn
RUN yarn install --check-files
RUN bundle install

CMD ["/bin/bash", "start.sh"]