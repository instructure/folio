require 'folio/page'

# A subclass of Array mixing in Folio::Page
module Folio
  class BasicPage < Array
    include ::Folio::Page
  end
end
