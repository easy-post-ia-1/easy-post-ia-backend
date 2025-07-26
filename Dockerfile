# ---------------------
# Base Image
# ---------------------
ARG RUBY_VERSION=3.3.6
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Set working directory for the Rails app
WORKDIR /rails

# Install base dependencies
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y \
  curl \
  libjemalloc2 \
  libvips \
  libpq-dev && \
  rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# ---------------------
# Build Stage
# ---------------------
FROM base AS build

ENV RAILS_ENV="development" \
  BUNDLE_DEPLOYMENT="1" \
  BUNDLE_PATH="/usr/local/bundle" \
  BUNDLE_WITHOUT=""

# Install build tools for native gems and dependencies
RUN apt-get update -qq && \
  apt-get install --no-install-recommends -y \
  build-essential \
  curl \
  git \
  pkg-config && \
  rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Copy full app code to ensure all required files are available
COPY . /rails/

# Ensure matching bundler version
RUN gem update --system && \
  gem install bundler -v 2.6.9

# Install Ruby gems (not in deployment mode)
RUN bundle _2.6.9_ install
RUN rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git
RUN bundle exec bootsnap precompile --gemfile

RUN bundle check || (echo "💥 Bundler gems missing!" && exit 1)

# Precompile bootsnap for app code
RUN bundle exec bootsnap precompile app/ lib/

# Precompile assets using dummy secret
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Install foreman for Procfile support
RUN gem install foreman

# ---------------------
# Final Stage
# ---------------------
FROM base

# # Set runtime environment
ENV RAILS_ENV="development" \
  BUNDLE_DEPLOYMENT="0" \
  BUNDLE_PATH="/usr/local/bundle" \
  BUNDLE_WITHOUT=""

# Copy installed gems and app code from build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Create a non-root user and set ownership of needed folders
RUN groupadd --system --gid 1000 rails && \
  useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
  chown -R rails:rails db log storage tmp /usr/local/bundle

USER 1000:1000

# Expose default Rails port
EXPOSE 4000

# Entrypoint to prepare DB or run commands
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
# CMD ["tail", "-f", "/dev/null"]

