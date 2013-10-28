begin
  require 'active_support/core_ext/module/attribute_accessors'
  require 'action_controller'
rescue LoadError
  raise "folio-pagination-legacy's rails support requires rails"
end

begin
  require 'will_paginate/view_helpers'
rescue LoadError
  raise "folio-pagination-legacy's rails support requires will_paginate"
end

require 'folio/will_paginate/view_helpers'

if defined?(ActionController::Base) and ActionController::Base.respond_to? :rescue_responses
  ActionController::Base.rescue_responses['Folio::InvalidPage'] = :not_found
end

require 'folio/will_paginate/active_record'
