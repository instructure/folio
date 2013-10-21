require 'will_paginate/view_helpers/link_renderer'

module Folio
  module WillPaginate
    module ViewHelpers
      module LinkRenderer
        def previous_page_with_folio
          # the page identifier may not be ordinal; use the value as set on the
          # collection, instead.
          previous_or_next_page(@collection.previous_page, @options[:previous_label], 'previous_page')
        end

        def next_page_with_folio
          # the page identifier may not be ordinal; use the value as set on the
          # collection, instead.
          previous_or_next_page(@collection.next_page, @options[:next_label], 'next_page')
        end

        def link_with_folio(text, target, attributes = {})
          if target
            # the non-folio version only does this for Fixnums, but we want to
            # do it for any page value. fortunately, this method only ever
            # receives Fixnums or nil, so we can do it now for any non-nil
            # value, and the non-folio version will happily avoid a double
            # application because even when the page was a fixnum, it won't be
            # anymore.
            attributes[:rel] = rel_value(target)
            target = url(target)
          end
          link_without_folio(text, target, attributes)
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
          [:previous_page, :next_page, :link, :rel_value].each do |method|
            klass.send(:alias_method, :"#{method}_without_folio", method)
            klass.send(:alias_method, method, :"#{method}_with_folio")
          end
        end

        ::WillPaginate::ViewHelpers::LinkRenderer.send :include, self
      end
    end
  end
end
