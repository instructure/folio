begin
  require 'will_paginate/view_helpers/action_view'
rescue LoadError
  raise "folio-pagination's actionview support requires will_paginate"
end

require 'folio/will_paginate/view_helpers'

# no overrides specific to action view necessary. just including the general
# view_helper overrides as above is sufficient.
