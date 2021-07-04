FROM ruby

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock /usr/src/app/

RUN apt update 

RUN bundle install

COPY . .

CMD ["./main.rb"]
