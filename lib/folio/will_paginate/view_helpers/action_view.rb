begin
  require 'will_paginate/view_helpers/action_view'
rescue LoadError
  raise "folio-pagination's actionview support requires will_paginate"
end

require 'folio/will_paginate/view_helpers'

# TODO: this file will patch up will_paginate's ActionView specific view helper
# stuff to work with Folio::Pages rather than WillPaginate::Collections, if
# necessary
