require 'will_paginate/array'
require 'folio/core_ext/enumerable'

# make sure Array#paginate uses to folio version from Enumerable, not the one
# will_paginate added.
class Array
  def paginate(*args)
    super
  end
end
