require 'folio/page'

# Mix in to an Enumerable to provide the same methods as Folio::Page but with
# the following overrides:
#
#  * ordinal_pages is always true
#
#  * first_page is always 1
#
#  * current_page is forced to an integer
#
#  * previous_page is always either current_page-1 or nil, depending on how
#    current_page relates to first_page.
#
#  * next_page can only be set if total_pages is unknown. if total_pages is
#    known, next_page will be either current_page+1 or nil, depending on how
#    current_page relates to last_page. if total_pages is unknown and next_page
#    is unset (vs. explicitly set to nil), it will default to current_page+1.
#    if next_page is set to a non-nil value, that value will be forced to an
#    integer.
#
#  * last_page is deterministic: always total_pages if total_pages is known,
#    current_page if total_pages is unknown and next_page is nil, nil otherwise
#    (indicating the page sequence continues until next_page is nil).
module Folio
  module Ordinal
    module Page
      def ordinal_pages
        true
      end
      alias :ordinal_pages? :ordinal_pages

      def first_page
        1
      end

      def last_page
        (total_pages || next_page) ? total_pages : current_page
      end

      def current_page=(value)
        @current_page = value.to_i
      end

      def next_page=(value)
        @next_page = value && value.to_i
      end

      def next_page
        if total_pages && current_page >= total_pages
          # known number of pages and we've reached the last one. no next page
          # (even if explicitly set)
          nil
        elsif total_pages || !defined?(@next_page)
          # (1) known number of pages and we haven't reached the last one
          #     (because we're not in the branch above), or
          # (2) unknown number of pages, but nothing set, so we assume an
          #     infinite stream
          # so there's a next page, and it's the one after this one
          current_page + 1
        else
          # just use what they set
          @next_page
        end
      end

      def previous_page
        current_page > first_page ? current_page - 1 : nil
      end

      def out_of_bounds?
        (current_page < first_page) || (last_page && current_page > last_page) || false
      end

      def offset
        (current_page - 1) * per_page
      end

      def self.create
        Folio::Ordinal::BasicPage.new
      end
    end

    class BasicPage < Folio::BasicPage
      include Folio::Ordinal::Page

      def replace(array)
        result = super
        if total_entries.nil? and length < per_page and (current_page == 1 or length > 0)
          self.total_entries = offset + length
        end
        result
      end
    end
  end
end
