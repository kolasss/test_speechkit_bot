# Yandex SpeechKit telegram bot

## Usage

```sh
bundle install
cp config/secrets.yml.sample config/secrets.yml
bin/bot
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
rspec
```
