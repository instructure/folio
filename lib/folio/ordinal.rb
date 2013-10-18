require 'folio'
require 'folio/invalid_page'
require 'delegate'

# Mixing this into your source instead of Folio has the same
# requirements and benefits, except the responsibilities of the
# build_page and fill_page methods are narrowed.
#
# build_page no longer needs to configure ordinal_page, first_page, or
# last_page on the instantiated page; these values will all be inferred
# or hard coded instead. ordinal_page will always be true and first_page
# will always be 1. last_page is replaced by an alias to total_pages.
# build_page method now simply needs to choose a type of page to
# instantiate and return it.
#
# Similarly, fill_page no longer needs to configure next_page and
# last_page; they will be calculated from current_page, first_page, and
# last_page. Instead, the method can focus entirely on populating the
# page.
module Folio
  module Ordinal
    class PageDecorator < ::SimpleDelegator
      # hard coded values/calculations for some of the attributes
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

      def next_page=(value)
        @next_page = value
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
    end

    def build_page_with_decorator
      # wrap the page built by the host in the decorator
      ::Folio::Ordinal::PageDecorator.new(build_page_without_decorator)
    end

    def fill_page_with_bounds_checking(page)
      # perform bounds checking before passing it along
      raise ::Folio::InvalidPage unless page.current_page.is_a?(Integer)
      raise ::Folio::InvalidPage if page.current_page < page.first_page
      raise ::Folio::InvalidPage if page.last_page && page.current_page > page.last_page
      fill_page_without_bounds_checking(page)
    end

    # otherwise acts like a normal folio
    include ::Folio

    def self.included(klass)
      super

      # like ActiveSupport's alias_method_chain, but don't want to create a
      # dependency on ActiveSupport for just this.
      klass.send(:alias_method, :build_page_without_decorator, :build_page)
      klass.send(:alias_method, :build_page, :build_page_with_decorator)
      klass.send(:alias_method, :fill_page_without_bounds_checking, :fill_page)
      klass.send(:alias_method, :fill_page, :fill_page_with_bounds_checking)
    end
  end
end
