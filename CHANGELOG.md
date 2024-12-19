# 📜 CHANGELOG

This document lists breaking changes for each major release.

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
