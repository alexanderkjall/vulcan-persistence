#!/bin/bash

set -e

cat .env.config | envsubst > .env.production

if [ ! -z "$POSTGRES_CA_B64" ]; then
  mkdir -p /root/.postgresql
  echo $POSTGRES_CA_B64 | base64 -d > /root/.postgresql/root.crt  # for rails
fi

unset VERSION # unset VERSION to prevent conflicts in db:migrate
bin/rails db:migrate

if [ -f "$1" ]
then
  source .env.production
  PGPASSWORD=$POSTGRES_PASSWORD PGSSLMODE=$POSTGRES_SSLMODE psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -1 -f $1
fi

pid=0

# SIGTERM-handler
term_handler() {
  if [ $pid -ne 0 ]; then
    kill -SIGTERM "$pid"
    wait "$pid"
  fi
  exit 143; # 128 + 15 -- SIGTERM
}

trap 'kill ${!}; term_handler' SIGTERM

# run application
bundle exec puma -C config/puma.rb --control-url tcp://127.0.0.1:9293 --control-token token &
pid="$!"

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done
