ActionPasskey.configure do |config|
  # The origins of your application (must match the browser URL)
  config.origins = ["http://localhost:3000"]

  # The display name for your relying party
  config.name = "My Application"
end
