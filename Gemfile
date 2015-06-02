source 'https://rubygems.org'

gemspec

group :development do
  gem 'guard-minitest'
end

group :will_paginate do
  gem 'rails', '>= 3.0', '< 4.1'
  # this isn't in the gemspec because folio/rails.rb loads only part of
  # will_paginate, and only if folio/rails.rb is required. see the README.
  gem 'will_paginate', '~> 3.0.7'
end

group :test do
  gem 'sqlite3'
end
