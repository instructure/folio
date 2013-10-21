require 'will_paginate/view_helpers/link_renderer_base'

module Folio
  module WillPaginate
    module ViewHelpers
      module LinkRendererBase
        def prepare_with_folio(collection, options)
          # only include page_links if we're in a collection with ordinal
          # pages; otherwise stick to just prev/next.
          options = options.merge(page_links: false) unless collection.ordinal_pages?
          prepare_without_folio(collection, options)
        end

        def windowed_page_numbers_with_folio
          page_numbers = windowed_page_numbers_without_folio
          unless @collection.last_page
            # the last page is not known, so add a trailing gap (it won't
            # already be there, because the right range during the super call
            # won't exist).
            page_numbers << :gap
          end
          page_numbers
        end

        def total_pages_with_folio
          # the collection may not have a known last page. if so, there must be
          # a next page; count that as the last known page. it's ok to use
          # these page identifiers as a page count because (after fixing
          # LinkRenderer) it's only called when ordinal_pages is true.
          @collection.last_page || @collection.next_page
        end

        def self.included(klass)
          [:prepare, :windowed_page_numbers, :total_pages].each do |method|
            klass.send(:alias_method, :"#{method}_without_folio", method)
            klass.send(:alias_method, method, :"#{method}_with_folio")
          end
        end

        ::WillPaginate::ViewHelpers::LinkRendererBase.send :include, self
      end
    end
  end
end
