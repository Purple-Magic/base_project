# AGENTS.md

This file is the entrypoint for task-specific instructions in this repository.

Load this file first. Do not preload every referenced file. Open only the files that match the current task.

## Always Apply

- Run all Ruby, Rails, Bundler, RSpec, and rake commands with `dip` by default.
- Use `uuid` instead of `id` in requests and lookups outside `admin` namespace.
- Do not add ActiveRecord validations for `uuid`; the database guarantees it.
- Do not use `match` in routes. Use `resources`, `get`, `post`, `patch`, or `delete`.
- Use Rails I18n for localized text. Do not hardcode locale maps inside Ruby files.
- Put prompts into `.md` files instead of embedding them directly in Ruby code.
- Prefer official gems for third-party integrations.
- Do not call third-party services synchronously from controllers. Wrap integration logic in service objects and background jobs.
- Use `anyway_config` instead of reading `ENV` directly.
- Use symbols directly instead of constants-for-symbols.
- Do not create a module and class with the same singular name. Use plural module names when namespacing by model domain.

## Load Only What Is Relevant

- For user-facing feature docs in `docs/users/`, open [docs/agents/documentation.md](/home/pavel/projects/base_project/docs/agents/documentation.md).
- For project-wide Rails rules, seeds, services, UUID, routes, scopes, enums, and deployment constraints, open [docs/agents/rails.md](/home/pavel/projects/base_project/docs/agents/rails.md).
- For Tramway entities, forms, decorators, components, controllers, chats, and CRUD behavior, open [docs/agents/tramway.md](/home/pavel/projects/base_project/docs/agents/tramway.md).
- For UI markup, Tailwind, buttons, tables, containers, flash messages, titles, and ViewComponent rules, open [docs/agents/ui.md](/home/pavel/projects/base_project/docs/agents/ui.md).
- For RSpec, Capybara, factories, and Tramway entity feature specs, open [docs/agents/testing.md](/home/pavel/projects/base_project/docs/agents/testing.md).
- For third-party integration patterns, service-object boundaries, jobs, and monadic service results, open [docs/agents/integrations.md](/home/pavel/projects/base_project/docs/agents/integrations.md).
- For implementation approaches and reusable feature patterns such as copy flows, imports, exports, search, or state transitions, open [docs/agents/recipes.md](/home/pavel/projects/base_project/docs/agents/recipes.md).

## Loading Strategy

- If the task is small and touches one area, load one additional file.
- If the task spans multiple areas, load only the relevant combination.
- If the task is purely informational, prefer reading the smallest relevant file instead of the whole instruction set.
- If a file is not relevant to the task, do not read it.

## Typical Mapping

- CRUD page or resource work: `rails.md` + `tramway.md` + `ui.md`
- Feature or system specs: `testing.md`, and `tramway.md` if entity-driven pages are involved
- Background jobs or API/service integrations: `rails.md` + `integrations.md`
- User-facing feature changes that affect onboarding docs: `documentation.md`
- Tailwind or component cleanup: `ui.md`
- Reusable feature implementation approach: `recipes.md`
