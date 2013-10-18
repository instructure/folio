# Raised when a value passed to a Folio's paginate method is
# non-sensical or out of bounds for that folio.
module Folio
  class InvalidPage < ArgumentError; end
end
