# AGENTS.md

This file is the entrypoint for task-specific instructions in this repository.

This is the reference project for Tramway skill. Use tramway-skill by default for Tramway and Rails work in this project.

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

## Start of Tramway AGENTS.md
# Tramway Rules

Load this file when the task touches Tramway entities, forms, decorators, components, controller patterns around Tramway, or default CRUD behavior.

## Core Principle

- Prefer Tramway defaults and generators over hand-rolled Rails setup.
- Use domain language instead of generic names.
- Keep logic in the correct layer: models for data, controllers for HTTP, components for reusable UI, views for straightforward rendering.

## Entities And CRUD

- If CRUD or default actions like `index`, `show`, `create`, `update`, `destroy` are requested, use Tramway Entities by default unless custom behavior is required.
- Configure entities in `config/initializers/tramway.rb`.
- Do not manually create controllers, views, and routes for CRUD if Tramway Entities can handle the feature.
- If a namespace is requested, configure it in the entity definition.
- If the app has web authentication, set `config.application_controller = 'ApplicationController'`.

Example:

```ruby
Tramway.configure do |config|
  config.application_controller = 'ApplicationController'
  config.entities = [
    {
      name: :participant,
      pages: [
        { action: :index },
        { action: :show },
        { action: :create },
        { action: :update },
        { action: :destroy }
      ]
    }
  ]
end
```

## Search

- Search is disabled by default on entity index pages.
- Enable it with `search: true` on the `:index` page.
- If `Model.search` exists, Tramway uses it.
- Otherwise Tramway falls back to `Model.tramway_search`, which should be treated as a temporary fallback.

## Forms

- Use Tramway Form pattern when `create` or `update` pages are configured for an entity.
- Use Tramway Form validation for form-only rules.
- Keep data-integrity validation in the model unless form-only behavior is explicitly needed.
- Do not use strong parameters in controllers.
- Do not define `#{model_name}_params` methods.
- Use `tramway_form` to instantiate forms.
- Use `tramway_form_for` instead of `form_with` or `form_for`.
- Use `tramway_form_for(remote: true)` only for truly asynchronous partial-page updates.
- Keep normal create/update flows synchronous.
- For enumerized attributes, use `collection: Model.attribute.values` in field definitions.
- For API work, use `api` namespaces for forms and decorators.

Example:

```ruby
class UserForm < Tramway::BaseForm
  properties :email, :about_me, :user_type, :score

  fields email: :email,
    name: :text,
    about_me: {
      type: :text_area,
      rows: 5
    },
    user_type: {
      type: :select,
      collection: ['regular', 'user']
    },
    score: {
      type: :number,
      value: ->(object) { Score.find_by(user_id: object.id).value }
    }

  def score=(value)
    Score.find_by(user_id: object.id).update(value:)
  end
end
```

## Decorators

- Always use decorated objects in views.
- Always instantiate decorators with `tramway_decorate`.
- In Tramway decorators, use `delegate_attributes` instead of `delegate ... to: :object`.
- If an entity has an index page, define `index_attributes` in its decorator.

## Components And Views

- Inherit components from `Tramway::BaseComponent`.
- Use `tramway_decorate` and `tramway_form`; do not instantiate decorator/form classes directly.

## Chat UI

- Use `tramway_chat` for chat interfaces.
- Pass `chat_id`, `messages`, `message_form`, and `send_message_path`.
- Each message must include `:id` and `:type` with `:sent` or `:received`.
- Use `message_form: nil` for read-only chat rendering.
- Control availability with `send_messages_enabled:`.
- For live updates, use `tramway_chat_append_message`.

## Controller Pattern

- Keep controller actions short and explicit.
- Use guard clauses where useful.
- Render components for complex UI instead of logic-heavy partials.
- Do not add business logic private methods to controllers.

## State Management On Existing Entities

- If a model already has Tramway entity `index` and `show` pages and the request is about explicit state management, do not add a new controller.
- Add a component for the state buttons.
- Render it via `show_header_content` for the show page and an actions column for the index page.
## End of Tramway AGENTS.md

If you are Codex, use the tramway-skill skill for Tramway/Rails work in this project. If tramway-skill is not installed, install it from https://github.com/Purple-Magic/tramway-skill/.
