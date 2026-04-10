# Tramway Skill Reference Project

This repository is the reference Rails application for [`Purple-Magic/tramway-skill`](https://github.com/Purple-Magic/tramway-skill/).

It exists to demonstrate and validate the conventions, workflows, and generated code patterns expected by the Tramway skill. In practice, this project is also a sandbox for ongoing exploration, so some areas are intentionally incomplete and a lot of the codebase is still work in progress.

## Purpose

Use this project as the canonical example app when you need to:

- check how `tramway-skill` expects a Rails + Tramway project to be structured
- validate generated code against a real application
- experiment with new features before they are documented or extracted elsewhere
- compare future skill behavior against a known reference implementation

This is a reference project first, not a polished product app.

## Current State

The application currently includes:

- Rails 8.1 with Haml, RSpec, Tailwind, and ViewComponent-compatible Tramway conventions
- Auth0-based authentication flow
- a basic home page
- a user profile page backed by the Auth0 session payload
- a simple chat flow with chat show pages and message submission
- Docker-based local development through `dip`
- Terraform and Kamal deployment helpers

Some of these areas are stable enough to serve as examples, while others are still evolving. Expect rough edges, partially implemented features, and documentation that improves over time.

## Relationship to `tramway-skill`

If you are working on [`tramway-skill`](https://github.com/Purple-Magic/tramway-skill/), this repo is the baseline application used to:

- test prompts and implementation rules
- confirm generated Rails code fits Tramway conventions
- capture examples of preferred project organization
- preserve working patterns that the skill should continue to produce

Changes here may intentionally precede updates in the skill itself.

## Local Development

This project uses Docker and `dip` by default. In this repository, Ruby, Rails, Bundler, and RSpec commands should be run through `dip`.

### Prerequisites

- Docker
- Docker Compose
- `dip`
- Rails credentials or environment variables for Auth0 configuration

### Initial Setup

1. Install dependencies for your local environment:

```bash
dip provision
```

This provisions PostgreSQL, installs gems, and prepares the development and test databases.

### Start the App

Run the web server:

```bash
dip rails s
```

The app will be available at `http://localhost:3000`.

### Useful Commands

Run the test suite:

```bash
dip rspec
```

Run a specific Rails command:

```bash
dip rails db:migrate
```

Open a shell in the app container:

```bash
dip runner
```

Run RuboCop:

```bash
dip rubocop
```

## Authentication Setup

The app uses Auth0. For local development, configure Auth0 credentials either in Rails credentials or with environment variables supported by the initializer:

- `AUTH0_DOMAIN`
- `AUTH0_CLIENT_ID`
- `AUTH0_CLIENT_SECRET`

Auth0 should allow these local URLs:

- Callback URL: `http://localhost:3000/auth/auth0/callback`
- Logout URL: `http://localhost:3000`

For the current user-facing behavior, see [docs/users/authentication.md](/home/pavel/projects/base_project/docs/users/authentication.md).

## Deployment

The repository includes deployment-related automation with Terraform and Kamal.

Examples:

```bash
make create_new_staging
make deploy_staging
make logs_staging
```

There are also explicit destroy targets, but they are separate on purpose:

```bash
make destroy_staging
make destroy_production
```

Additional deployment notes live in [terraform/README.md](/home/pavel/projects/base_project/terraform/README.md).

## Repository Notes

- The main goal of this repo is to stay useful as a reference, not to stay minimal.
- Some implementations are intentionally direct so the skill has concrete examples to follow.
- WIP code is expected here.
- Backlog items may stay in the README so the reference status and missing pieces remain visible.

## Backlog

- [ ] Extract the deployment functionality into a separate gem.
- [ ] Implement deployment with GitHub Actions.
- [ ] Implement end-2-end tests
