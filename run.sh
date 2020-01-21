#!/bin/sh
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

bundle exec puma -C config/puma.rb
