ARG rails_env=production
FROM ruby:2.4.9-alpine AS pre-builder
ARG build_without=""
ENV SECRET_KEY_BASE=dumb
RUN apk add --update --no-cache \
        openssl \
        tar \
        build-base \
        tzdata \
        postgresql-dev \
        postgresql-client \
        sqlite-dev \
    && mkdir -p /var/app
ENV BUNDLE_PATH="/gems" BUNDLE_JOBS=2 RAILS_ENV=${rails_env} BUNDLE_WITHOUT=${bundle_without}
WORKDIR /var/app
COPY Gemfile* /var/app/
RUN bundle install -j4 --retry 3 \
    && rm -rf /gems/cache/* \
    && find /gems/ -name "*.c" -delete \
    && find /gems/ -name "*.o" -delete

FROM ruby:2.4.9-alpine
ARG rails_env=production
RUN apk add --update --no-cache \
        openssl \
        tzdata \
        postgresql-dev \
        sqlite-dev \
        postgresql-client \
        gettext
COPY --from=pre-builder /gems/ /gems/
ENV BUNDLE_PATH="/gems" BUNDLE_JOBS=2 RAILS_ENV=${rails_env} BUNDLE_WITHOUT=${bundle_without}
ENV RAILS_LOG_TO_STDOUT true

WORKDIR /app
COPY . .

CMD ["./run.sh"]
