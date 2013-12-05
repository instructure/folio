require 'active_support'
require 'will_paginate/view_helpers'

module Folio
  module WillPaginate
    module ViewHelpers
      module LinkRenderer
        def prepare_with_folio(collection, options, template)
          # only include page_links if we're in a collection with ordinal
          # pages; otherwise stick to just prev/next.
          options = options.merge(page_links: false) unless collection.ordinal_pages?
          prepare_without_folio(collection, options, template)
        end

        def windowed_links_with_folio
          links = windowed_links_without_folio
          unless @collection.last_page
            # the last page is not known, so add a trailing gap
            links << gap_marker
          end
          links
        end

        def total_pages_with_folio
          # the collection may not have a known last page. if so, there must be
          # a next page; count that as the last known page. it's ok to use
          # these page identifiers as a page count because (after fixing
          # LinkRenderer) it's only called when ordinal_pages is true.
          @collection.last_page || @collection.next_page
        end

        def rel_value_with_folio(page)
          # don't check against mathed out values, just check the values on the
          # collection
          rels = []
          rels << 'prev' if page == @collection.previous_page
          rels << 'next' if page == @collection.next_page
          rels << 'start' if page == @collection.first_page
          rels.empty? ? nil : rels.join(' ')
        end

        def self.included(klass)
          [:prepare, :windowed_links, :total_pages, :rel_value].each do |method|
            klass.send(:alias_method, :"#{method}_without_folio", method)
            klass.send(:alias_method, method, :"#{method}_with_folio")
          end
        end

        ::WillPaginate::LinkRenderer.send :include, self
      end
    end
  end
end
