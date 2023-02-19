# Yandex SpeechKit telegram bot

## Usage

install and configure
```sh
bundle install
cp config/secrets.sample.yml config/secrets.yml
cp config/shrine.sample.yml config/shrine.yml
```

### You can use bot listener or puma server

start bot with long polling
```sh
bin/bot
```

start http server with webhook
```sh
bin/puma
```

### Start background tasks runner
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
docker-compose run --service-ports app bash
```

run tests
```sh
bundle exec rspec
```

run rubocop
```sh
bundle exec rubocop
```

### Configure webhook

set
```sh
rake webhook:set['https://example.com/webhook']
```

delete
```sh
rake webhook:delete
```

show info
```sh
rake webhook:get
```
