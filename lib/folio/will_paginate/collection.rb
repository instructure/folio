require 'folio'
require 'folio/ordinal/page'
require 'will_paginate/collection'

# overrides WillPaginate::Collection.create to return an ordinal folio page
# instead of a WillPaginate::Collection; the rest of WillPaginate::Collection
# is unused when in folio-land.
module WillPaginate
  class Collection
    def self.create(current_page, per_page=nil, total_entries=nil)
      page = ::Folio::Ordinal::Page.create
      page.current_page = current_page
      page.per_page = per_page
      page.total_entries = total_entries
      yield page if block_given?
      page
    end
  end
end
