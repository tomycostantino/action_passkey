# ActionPasskey

ActionPasskey generates boilerplate code to easily set up passkey authentication in Rails apps. It generates the Rails models, migration, controllers, routes, helpers, and Stimulus controllers needed to register and authenticate with WebAuthn passkeys.

## Requirements

- Rails 7.1 or newer
- Ruby 3.2 or newer
- Importmap and Stimulus
- `bin/rails generate authentication`
- An application `User` model

## Installation

Add the gem to your application's Gemfile:

```ruby
gem "action_passkey"
```

Then install it:

```bash
bundle install
bin/rails generate action_passkey:install
bin/rails db:migrate
```

The generator creates passkey models, controllers, JavaScript files, importmap pins, and routes.

## Configuration

The generator creates `config/initializers/action_passkey.rb`:

```ruby
ActionPasskey.configure do |config|
  config.origins = ["http://localhost:3000"]
  config.name = "My Application"
end
```

Set `origins` to the browser origins your app is served from. In production this should be your HTTPS origin, for example:

```ruby
config.origins = ["https://example.com"]
```

## User Model

The generator adds this macro to `app/models/user.rb` when the file exists:

```ruby
class User < ApplicationRecord
  has_passkeys
end
```

The macro defines:

```ruby
has_many :passkeys, dependent: :destroy
```

If the generator did not add it, add `has_passkeys` manually.

## Routes

The generator adds these routes to `config/routes.rb`:

```ruby
resources :passkeys, only: :create
resource :passkey_session, only: :create

namespace :passkeys do
  resource :options, only: :create
end

namespace :passkey_sessions do
  resource :options, only: :create
end
```

## View Helpers

Use the generated helpers in your views:

```erb
<%= add_passkey_button %>
```

```erb
<%= sign_in_with_passkey_button %>
```

`add_passkey_button` starts passkey registration for the current user.

`sign_in_with_passkey_button` starts passkey authentication.

## Generated Files

The install generator creates:

```text
app/models/passkey.rb
app/controllers/concerns/passkey_relying_party.rb
app/controllers/passkeys_controller.rb
app/controllers/passkeys/options_controller.rb
app/controllers/passkey_sessions_controller.rb
app/controllers/passkey_sessions/options_controller.rb
app/helpers/passkeys_helper.rb
app/javascript/controllers/passkey_registration_controller.js
app/javascript/controllers/passkey_authentication_controller.js
app/javascript/helpers/passkey.js
app/javascript/helpers/post.js
app/javascript/helpers/headers.js
config/initializers/action_passkey.rb
vendor/javascript/webauthn-json.js
```

It also creates a `create_passkeys` migration and updates `config/importmap.rb`.

## Development

After checking out the repo, install dependencies:

```bash
bin/setup
```

Run tests and linting:

```bash
bundle exec rake test
bundle exec rubocop
```

Build the gem locally:

```bash
gem build action_passkey.gemspec
```

## License

The gem is available as open source under the terms of the MIT License.
