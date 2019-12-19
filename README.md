[![Build Status](https://travis-ci.org/adevinta/vulcan-persistence.svg?branch=master)](https://travis-ci.org/adevinta/vulcan-persistence)
[![codecov](https://codecov.io/gh/adevinta/vulcan-persistence/branch/master/graph/badge.svg)](https://codecov.io/gh/adevinta/vulcan-persistence)

# Vulcan Persistence

## Developing

In order to develop locally, the server can be set up as follows:

1. Install RVM according to the [official instructions](https://rvm.io/).
2. Create a gemset and install the required gems by running:
```
$ rvm gemset create vulcan-persistence
$ rvm gemset use vulcan-persistence
$ sudo apt install libpq-dev # Required for PostgreSQL
$ bundle install
```
3. Prepare the test database by running:
```
$ bash script/testdb
$ RAILS_ENV=test rake db:create
$ RAILS_ENV=test rake db:migrate
```
4. Make sure that everything works by running:
```
$ RAILS_ENV=test rake test
```

## Docker execute

Those are the variables you have to use:

|Variable|Description|Sample|
|---|---|---|
|POSTGRES_(HOST\|PORT\|USER\|PASSWORD\|DB)|Database access|
|SECRET_KEY_BASE|Security key||
|STREAM_CHANNEL|Postgres channel|events|
|REGION|asw region|eu-west-1|
|SCANS_BUCKET|S3 bucket for scans|my-vulcan-scan-bucket|
|SNS_TOPIC_ARN|Sns topic arn|arn:aws:sns:eu-west-1:xxx:yyy|

```bash
docker build . -t vp

# Use the default config.toml customized with env variables.
docker run --env-file ./local.env vp

# Use custom config file.
docker run -v `pwd`/custom.env:/app/.env.config vr

# Optional: If you want to execute sql commands into the database after the migrations.
docker run --env-file ./local.env -v `pwd`/load.db:/tmp/load.db vp ./run.sh /tmp/load.db
