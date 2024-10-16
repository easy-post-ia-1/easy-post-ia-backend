# 📬 Easy Post IA Backend

Welcome to the **Easy Post IA Backend**! This application is built using the latest version of Rails and integrates various powerful libraries and tools to provide a robust development experience.

## 📦 Prerequisites

Ensure you have the following installed:

- **Ruby** 3.3.0
- **Rails** 7.1.3
- **PostgreSQL** (for database management)

## 🛠️ Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/your-username/easy-post-ia-backend.git
cd easy-post-ia-backend
```

### 2. Install dependencies

```bash
bundle install
```

### 3. Setup the database

Make sure PostgreSQL is running, then create and migrate the database:

```bash
rails db:create
rails db:migrate
```

### 4. Run the application

Start the Rails server:

```bash
rails server
```

The application will be available at `http://localhost:3000`.

### 5. Run tests

This project uses **RSpec** for testing. To run the tests, simply execute:

```bash
bundle exec rspec
```

You can also check the test coverage by running:

```bash
bundle exec simplecov
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

## 🧪 API Documentation

This project integrates **Rswag** to auto-generate API documentation. You can view it by running:

```bash
rails rswag:specs:swaggerize
```

The documentation is accessible at `http://localhost:3000/api-docs`.

## 🔍 Testing

- **Capybara** and **Selenium-WebDriver** are used for system tests.
- **Shoulda Matchers** simplifies writing tests by providing one-liners for validations and associations.

## 🛡️ Security

Security checks are performed using **Brakeman**. To run a scan:

```bash
bundle exec brakeman
```

## 📜 License

Easy Post IA © 2024 by Santiago Toquica Yanguas is licensed under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International. To view a copy of this license, visit [https://creativecommons.org/licenses/by-nc-nd/4.0/](https://creativecommons.org/licenses/by-nc-nd/4.0/).
