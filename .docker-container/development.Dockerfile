# # Make sure RUBY_VERS6ON matches the Ruby version in .ruby-version and Gemfile
# ARG RUBY_VERSION=3.3.6
# FROM registry.docker.com/library/ruby:3.3.6-slim as base
#
# # Rails app lives here
# WORKDIR /rails
#
# # Set development environment
# ENV RAILS_ENV="development" \
#   BUNDLE_PATH="/usr/local/bundle" \
#   BUNDLE_WITHOUT="production" \
#   BUNDLE_FLAGS="--jobs=4" \
#   BUNDLE_VERSION="2.6.2" \
#   RAILS_LOG_TO_STDOUT="true" \
#   RAILS_SERVE_STATIC_FILES="true" \
#   RAILS_MASTER_KEY=""
#
# # Throw-away build stage to reduce size of final image
# FROM base as build
#
# # Install packages needed to build gems
# RUN apt-get update -qq && \
#   apt-get install --no-install-recommends -y apt-utils build-essential git libpq-dev libvips pkg-config shared-mime-info
#
#
# # Install application gems
# RUN gem install bundler -v 2.6.2
# COPY Gemfile* /rails/
#
# RUN gem update --system bundler --no-document \
#   && gem clean bundler \
#   && bundle update --bundler \
#   && bundle install -v 2.6.2
#
# # Copy application code
# COPY . /rails/
#
# # Final stage
# FROM base
#
#
# # Install packages needed for development
# RUN apt-get clean && apt-get update -qq && \
#   apt-get install --no-install-recommends -y curl libvips postgresql-client nodejs && \
#   rm -rf /var/lib/apt/lists /var/cache/apt/archives
#
#
# # Install foreman for managing multiple processes
# RUN gem install foreman
#
# # Run and own only the runtime files as a non-root user for security
# RUN useradd rails --create-home --shell /bin/bash && \
#   chown -R rails:rails /rails
#
#
# USER rails:rails
#
# # Copy built artifacts: gems, application
# COPY --from=build /usr/local/bundle /usr/local/bundle
# COPY --from=build /rails /rails
#
# USER root
# RUN chmod g+w /rails/Gemfile.lock && chmod g+w /rails/Gemfile
# USER rails:rails
#
# # Entrypoint prepares the database.
# ENTRYPOINT ["/rails/bin/docker-entrypoint"]
#
# # Expose port for web server
# EXPOSE 3000
#
# # Command to run the server and webpack-dev-server for development
# CMD ["foreman", "start", "-f", "Procfile.dev"]

