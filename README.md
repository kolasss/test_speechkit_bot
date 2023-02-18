# Yandex SpeechKit telegram bot

## Usage

```sh
bundle install
cp config/secrets.sample.yml config/secrets.yml
cp config/shrine.sample.yml config/shrine.yml
bin/bot
```

start background tasks runner
```sh
bin/sidekiq -r ./initializers/sidekiq.rb
```

### Run in docker

```sh
docker-compose build
docker-compose up
```

### for development/test

```sh
docker-compose build
docker-compose run app bash
```

run tests
```sh
bundle exec rspec
```

run rubocop
```sh
bundle exec rubocop
```
