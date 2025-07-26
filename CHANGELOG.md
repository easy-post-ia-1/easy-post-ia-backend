# 📜 CHANGELOG

This document lists breaking changes for each major release.


## v0.1.0 (25/07/2025)

Feature, KAN-80, KAN-77, KAN-81,: Add project documentation and enhance API responses

- Introduced `ACTA_PROYECTO.md` and `DOCUMENTACION_TECNICA.md` for comprehensive project documentation.
- Updated `README.md` to include links to the new documentation files.
- Enhanced `ApplicationController` with `success_response` and `error_response` methods for standardized API responses.
- Added new `DashboardController`, `TemplatesController`, and `PostsController` with improved error handling and response formatting.
- Implemented new model `Template` and updated existing models (`Company`, `Post`, `Team`, etc.) to include new attributes and associations.
- Added migrations for new fields and relationships, including `code` for `Company` and `Team`, and `category` and `emoji` for `Post`.
- Updated tests to cover new features and ensure existing functionality remains intact.

## v0.0.11 (26/06/2025)

Feature KAN-48, KAN-74, KAN-71: Implement user roles and permissions with Rolify

- Role Model Creation: Added a new `Role` model to manage user roles and their associations.
- User Model Updates: Updated the `User` model to include role management, allowing users to have multiple roles.
- Ability Configuration: Implemented the `Ability` class to define permissions based on user roles, enabling fine-grained access control for resources like `Post`, `Strategy`, and `Team`.
- Database Migrations: Created migrations to add the `roles` table and a join table for user-role associations.
- Controller Enhancements: Updated relevant controllers to enforce role-based access control, ensuring that only authorized users can perform certain actions.
- Testing: Added tests for the new role and ability functionalities, ensuring that permissions are correctly enforced.

## v0.0.10 (11/06/2025)

- chore, KAN-62, KAN-65, KAN-63, KAN-67, KAN-68, KAN-70: add migrations/controllers/seeds, swagger and strategy/calendar features.

- Update seeds and translations.
- Added new migrations for strategy and calendar support
- Updated seeds to include initial strategy/calendar data
- Enhanced backend translation files
- Implemented strategy list and calendar logic in models/controllers

## v0.0.9 (01/06/2025)

- Update Docker configuration and dependencies for improved functionality

- Comment out the entrypoint command in docker-compose.yml for flexibility.
- Update healthcheck command to use a custom script.
- Upgrade PostgreSQL image version in docker-compose.yml.
- Modify Dockerfile to streamline installation of dependencies and ensure proper bundler version.
- Add foreman gem to Gemfile for process management.
- Update Procfile.dev to simplify web server command.
- Adjust dev script to ensure proper environment setup and command execution.

## v0.0.8 (29/05/2025)

- Feature, KAN-32, KAN-58: Refactor Docker and application files for improved structure and functionality

- Update docker-compose.yml to correct service names and health checks.
- Modify Dockerfile to upgrade bundler version.
- Change gemspec version from 0.0.6 to 0.0.8.
- Adjust routes for strategy creation endpoint.
- Enhance StrategiesController to include user authentication and improve response structure.
- Refactor strategy status management in the Strategy model.
- Update Sidekiq job handling for better error management and logging.
- Revise seed data generation for users, companies, teams, and strategies using Faker for randomness.
- Improve test coverage for image generation helper methods.

## v0.0.7 (08/03/2025)

- Feature, KAN-53, KAN-54, KAN-55: Enhance post creation and authentication flow.

- Fix session handling in rack_session_fix.rb.
- Improve Bedrock post generation in create_posts_ia_helper.rb.
- Refactor CreateMarketingStrategyJob for better strategy execution.
- Update Post and User models with new attributes and methods.
- Adjust Rswag UI configuration in rswag_ui.rb.
- Modify routes to accommodate new API endpoints.
- Enhance test coverage new request specs and updated factories.
- Remove obsolete specs and outdated request tests.
- Update Sidekiq job for social network publishing.
- Replace deprecated YAML with JSON format.

## v0.0.6 (22/02/2025)

- Feature, KAN-52: Add initial authentication skeleton.

- Fix Dockerfile and remove entry point.
- Create post generator using AWS SDK Bedrock.
- Create template prompt and remove unused characters.
- Implement login strategy for AWS.
- Create posts, save Base64 images, and test in database.
- Add helper for Twitter login and post publishing.
- Develop job strategy for marketing automation.
- Enable Post model conversion to cron time.
- Add new status to Strategy model.
- Configure Sidekiq, routes, and S3.
- Update Gemfile and README.

## v0.0.5 (18/12/2024)

Feature, KAN-36, KAN-3: Create strategy backend.

- Update rubocop to add hash syntax.
- Update gemfile lock.
- Create translations to controllers strategy.
- Create routes, models, migrations, controllers, test, seeds related with Strategy, Posts.
- Create job to handle Strategy in the future to schedule post.
- Update post controller to allow pagination.
- Update session controller to make endpoint /me to get information.

## v0.0.4 (12/12/2024)

Feature, KAN-4, KAN-38, KAN-39: Create admin.

- Change development entrypoint with dev to get compilation of tailwind and run rails.
- Update .gitignore to ignore app assets build.
- Update previous CHANGELOG.
- Add madmin gem with routes, resources to different models, views and simple auth and update styles.
- Add tailwind config to add styles.

## v0.0.3 (09/12/2024)

Feature, KAN-34, KAN-30: CRUD Post and add other models.

- Create CRUD controller to posts with verification of Team.
- Add future helper to post.
- Create migrations, models and initial test to Company, Team, TeamMember, Post.
- Update User model to verified with username and relate references.
- Create routes.
- Create seeds to the different models.
- Generate strategy to clean db in the test.
- Allow more ips in cors to look console.
- Add translations to look errors, success status in endpoints and models.
- Create rake task to cleanup the seeds.
- Update test and helpers to advance in resolve the error.

## v0.0.2 (21/09/2024)

Feature: KAN-26, KAN-2, KAN-28, Create login, logout and signup.

- Create configuration to Cors, to console and debug.
- Configure devise with JWT and strategy to revocate.
- Create helpers to auth.
- Update .gitignore.
- Update Rbuocop rules.
- Add initial swagger.
- Create initial routes, controllers to auth.
- Add and update config to test with Rspec, FactoryBot, ShouldMatchers, Devise test, coverage.
- Add test to models, controllers, helpers, etc.
- Update Gemfile to new gems to clean database in the tests.

## v0.0.1 (20/09/2024)

Feature: KAN-13, Config project and initial projects

- Add initial dockerfiles and docker compose.
- Add gems to test, rspec, factory bot, faker, should matchers.
- Add other gems to use devise, rolify, cancancan
- Add LICENSE, README, CHANGELOG, .gemspec.
- Add hooks git to pre-commit and pre-push.
