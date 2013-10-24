begin
  require 'rails'
rescue LoadError
  raise "folio-pagination's rails support requires rails"
end

begin
  require 'will_paginate/railtie'
rescue LoadError
  raise "folio-pagination's rails support requires will_paginate"
end

module Folio
  module WillPaginate
    class Railtie < Rails::Railtie
      config.action_dispatch.rescue_responses.merge!(
        'Folio::InvalidPage' => :not_found
      )

      initializer "folio" do |app|
        ActiveSupport.on_load :active_record do
          require 'folio/will_paginate/active_record'
        end

        ActiveSupport.on_load :action_view do
          require 'folio/will_paginate/view_helpers/action_view'
        end

        # don't need early access to our stuff, but will_paginate loaded
        # theirs, so we better patch it up now rather than later
        require 'folio/will_paginate/view_helpers'
      end
    end
  end
end
