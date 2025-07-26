# 📬 Easy Post IA Backend

Welcome to the **Easy Post IA Backend**! This is a robust Rails API application that provides the backend services for the Easy Post IA social media management platform.

## 🏗️ Architecture Overview

- **Framework**: Ruby on Rails 7.2.1
- **Database**: PostgreSQL
- **Cache**: Redis
- **Background Jobs**: Sidekiq
- **Authentication**: JWT + Devise + Rolify
- **Authorization**: CanCanCan
- **Admin Panel**: Madmin
- **API Documentation**: Swagger/OpenAPI
- **Testing**: RSpec + FactoryBot

## 📦 Prerequisites

Ensure you have the following installed:

- **Ruby** 3.3.6
- **Rails** 7.2.1
- **PostgreSQL** 14+
- **Redis** 6+
- **Docker** (optional, for containerized development)

## 🚀 Quick Start

### Option 1: Local Development

#### 1. Clone the repository
```bash
git clone https://github.com/your-username/easy-post-ia-backend.git
cd easy-post-ia-backend
```

#### 2. Install dependencies
```bash
bundle install
```

#### 3. Setup environment variables
```bash
cp .env.example .env
# Edit .env with your local configurations
```

#### 4. Setup the database
```bash
rails db:create
rails db:migrate
rails db:seed
```

#### 5. Start Redis (for Sidekiq)
```bash
redis-server
```

#### 6. Run the application
```bash
rails server -p <PORT>
```

The API will be available at `http://localhost:<PORT>`.

### Option 2: Docker Development

#### 1. Build and run with Docker Compose
```bash
docker-compose up --build
```

This will start:
- Rails API server on port <PORT>
- PostgreSQL database
- Redis server
- Sidekiq worker

## 🧪 Testing

### Run all tests
```bash
bundle exec rspec
```

### Run specific test types
```bash
# Model tests
bundle exec rspec spec/models/

# Controller tests
bundle exec rspec spec/controllers/

# Request tests
bundle exec rspec spec/requests/

# Integration tests
bundle exec rspec spec/integration/
```

### Check test coverage
```bash
bundle exec rspec --format documentation
open coverage/index.html
```

## 📚 API Documentation

### Generate Swagger documentation
```bash
rails rswag:specs:swaggerize
```

### View API documentation
- **Development**: http://localhost:<PORT>/api-docs
- **Production**: https://easy-post-ia.com/api-docs

## 🔧 Key Features

### Authentication & Authorization
- **JWT-based authentication** with stateless sessions
- **Role-based access control** (Admin, Employer, Employee)
- **Devise** integration for user management
- **Rolify** for flexible role assignments

### Core Modules
- **Users Management**: Registration, authentication, profile management
- **Posts**: CRUD operations for social media posts
- **Templates**: Reusable content templates
- **Strategies**: Marketing campaign management
- **Dashboard**: Analytics and reporting
- **Companies & Teams**: Multi-tenant organization structure

### Background Processing
- **Sidekiq** for asynchronous job processing
- **Redis** for job queue and caching
- **Scheduled post publishing**
- **Social media integration jobs**

## 🛡️ Security

### Security Checks
```bash
# Run Brakeman security scanner
bundle exec brakeman

# Run bundle audit for gem vulnerabilities
bundle exec bundle-audit
```

### Security Features
- **Strong Parameters** for input validation
- **CORS** configuration for cross-origin requests
- **SQL Injection Protection** via ActiveRecord
- **XSS Protection** with Rails built-in security
- **CSRF Protection** for web interfaces

## 🐳 Docker Deployment

### Production Dockerfile
```dockerfile
# Multi-stage build for production
FROM ruby:3.3.6-slim as base

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    nodejs \
    postgresql-client

# Set working directory
WORKDIR /app

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

# Copy application code
COPY . .

# Precompile assets
RUN SECRET_KEY_BASE=dummy rails assets:precompile

# Create non-root user
RUN useradd -m -s /bin/bash rails
RUN chown -R rails:rails /app
USER rails

# Expose port
EXPOSE <PORT>

# Start command
CMD ["rails", "server", "-b", "0.0.0.0"]
```

## ⚙️ Key Gems & Tools

- **Rails**: Full-stack web framework for building applications.
- **PostgreSQL**: The database used for ActiveRecord.
- **Puma**: High-performance web server.
- **Turbo-Rails & Stimulus-Rails**: Tools for SPA-like acceleration and JS framework support.
- **Rspec-Rails**: Testing framework for Rails.
- **FactoryBot & Faker**: Easy data generation and factories for tests.
- **Rubocop**: Code linting for clean and consistent syntax.
- **Brakeman**: Security vulnerability scanner.
- **SimpleCov**: Code coverage analysis for tests.

## 📊 Monitoring & Logging

### Application Monitoring
- **New Relic**: Application performance monitoring
- **Sentry**: Error tracking and monitoring
- **Papertrail**: Centralized logging

### Health Checks
```bash
# Application health
curl http://localhost:<PORT>/health

# Database connectivity
rails runner "puts ActiveRecord::Base.connection.active?"

# Redis connectivity
rails runner "puts Redis.new.ping"
```

## 🔄 CI/CD Pipeline

## 📈 Performance Optimization

### Database Optimization
```ruby
# Add indexes for frequently queried columns
add_index :posts, [:team_member_id, :status]
add_index :posts, :programming_date_to_post
add_index :strategies, [:company_id, :from_schedule]
```

### Caching Strategy
```ruby
# Fragment caching for views
<% cache @post do %>
  <%= render @post %>
<% end %>

# Russian doll caching
<% cache [@company, @team] do %>
  <% @posts.each do |post| %>
    <% cache post do %>
      <%= render post %>
    <% end %>
  <% end %>
<% end %>
```

## 🔧 Development Tools

### Useful Commands
```bash
# Rails console
rails console

# Database console
rails dbconsole

# Routes
rails routes

# Generate new model
rails generate model Post title:string description:text

# Generate new controller
rails generate controller Api::V1::Posts

# Run migrations
rails db:migrate

# Rollback migration
rails db:rollback

# Reset database
rails db:reset

# Seed database
rails db:seed
```

### Code Quality
```bash
# Run RuboCop
bundle exec rubocop

# Auto-fix RuboCop issues
bundle exec rubocop -a

# Run all linters
bundle exec rake lint
```

## 📚 Additional Documentation

- **Technical Documentation**: [DOCUMENTACION_TECNICA.md](./DOCUMENTACION_TECNICA.md)
- **API Documentation**: http://localhost:<PORT>/api/v1/docs
- **Admin Panel**: http://localhost:<PORT>/admin
- **Sidekiq Dashboard**: http://localhost:<PORT>/sidekiq

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

Easy Post IA © 2025 by Santiago Toquica Yanguas is licensed under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International. To view a copy of this license, visit [https://creativecommons.org/licenses/by-nc-nd/4.0/](https://creativecommons.org/licenses/by-nc-nd/4.0/).

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/your-username/easy-post-ia-backend/issues)
- **Documentation**: [Technical Documentation in Spanish](./DOCUMENTACION_TECNICA.md)
