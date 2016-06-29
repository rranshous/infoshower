FROM ruby:2.2.2

ADD ./ /src
WORKDIR /src

RUN gem install bundler
RUN bundle install

ENTRYPOINT ["bundle", "exec"]
CMD ["./app"]

EXPOSE 80
VOLUME /data
ENV DATA_DIR /data
