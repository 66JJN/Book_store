# `bin/rails test` runs `test:prepare` first when the task exists. This app does not load
# rails/test_unit/railtie (see config/application.rb), so the task is defined here to build
# the JS and CSS (store + /admin) before tests. Without it a fresh clone fails with
# "The asset 'application.css' was not found" until `bin/dev` has been run once.
namespace :test do
  task prepare: %w[javascript:build css:build]
end
