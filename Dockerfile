FROM ruby:2.7.1

LABEL Name=shorty

RUN gem install bundler

WORKDIR /app
COPY . /app

RUN bundle config --global frozen 1
COPY Gemfile Gemfile.lock ./
RUN bundle install
RUN gem install rack

EXPOSE 9292

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "9292"]