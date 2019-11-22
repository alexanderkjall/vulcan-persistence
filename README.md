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
