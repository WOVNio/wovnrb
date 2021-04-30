FROM ruby:2.6.5

WORKDIR /usr/src/app

COPY ./TestSite/ .
COPY ["wovnrb-3.0.0.gem", "."]
CMD ["/bin/bash", "start.sh"]