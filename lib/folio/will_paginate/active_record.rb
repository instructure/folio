# place WillPaginate's versions in place first to ensure the folio versions
# included later are used
begin
  require 'active_record'
rescue LoadError
  raise "folio-pagination-legacy's activerecord support requires activerecord"
end

begin
  require 'will_paginate/finder'
rescue LoadError
  raise "folio-pagination-legacy's activerecord support requires will_paginate"
end

ActiveRecord::Base.send :include, WillPaginate::Finder
ActiveRecord::Associations::AssociationCollection.send :include, WillPaginate::Finder::ClassMethods

require 'folio/ordinal'
require 'folio/ordinal/page'
require 'folio/will_paginate/array'

module Folio
  module WillPaginate
    # replaces model_or_association.paginate(...) method to behave like that
    # from Folio while preserving basic mechanics of the version from
    # WillPaginate.
    #
    # differences:
    #
    #  * paginate does *not* recognize any parameters beyond those described in
    #    for Folio's paginate (e.g. finder options, count options).
    #
    module ActiveRecord
      module Pagination
        include Folio::Ordinal

        def paginate_with_wp_count(options={})
          unless options.has_key?(:total_entries)
            page = options.fetch(:page) { 1 }
            per_page = options.fetch(:per_page) { self.per_page }
            offset = (page - 1) * per_page
            options[:total_entries] = wp_count({}, [:all, {offset: offset, limit: per_page}], 'find')
          end
          paginate_without_wp_count(options)
        end
        alias_method_chain :paginate, :wp_count

        def build_page
          Folio::Ordinal::Page.create
        end

        # load the results and place them in the page
        def fill_page(page)
          page.replace self.find(:all, offset: page.offset, limit: page.per_page)
          page
        end

        # don't try and look at Class (ActiveRecord::Base.class, etc.) for
        # defaults
        def default_per_page
          Folio.per_page
        end
      end

      # mix into Active Record. these are the same ones that WillPaginate mixes
      # its version of pagination into.
      ::ActiveRecord::Base.extend Pagination
      ::ActiveRecord::Associations::AssociationCollection.send(:include, Pagination)
    end
  end
end
