require 'folio/per_page'
require 'delegate'

# Mix into any Enumerable. The mixin gives you the eight attributes and
# one method described below.
#
# ordinal_pages?, first_page, and last_page are common to all pages
# created by a folio and are configured, as available, when the folio
# creates a blank page.
#
# current_page, per_page, and total_entries control the filling of a
# page and are configured from parameters to the folio's paginate
# method.
#
# next_page and previous_page are configured, as available, when the
# folio fills the configured page.
module Folio
  module Page
    # indicates whether the page identifiers in current_page,
    # first_page, last_page, previous_page, and next_page should be
    # considered ordinal or not.
    attr_accessor :ordinal_pages
    alias :ordinal_pages? :ordinal_pages

    # page identifier addressing this page within the folio.
    attr_accessor :current_page

    # number of items requested from the folio when filling the page.
    include Folio::PerPage

    # page identifier addressing the first page within the folio.
    attr_accessor :first_page

    # page identifier addressing the final page within the folio, if
    # known.
    def last_page=(value)
      @last_page = value
    end

    def last_page
      if next_page.nil?
        current_page
      else
        @last_page
      end
    end

    # page identifier addressing the immediately following page within
    # the folio, if there is one.
    attr_accessor :next_page

    # page identifier addressing the immediately preceding page within
    # the folio, if there is one and it is known.
    attr_accessor :previous_page

    # number of items in the folio, if known.
    attr_accessor :total_entries

    # number of pages in the folio, if known. calculated from
    # total_entries and per_page.
    def total_pages
      return nil unless total_entries && per_page && per_page > 0
      return 1 if total_entries <= 0
      (total_entries / per_page.to_f).ceil
    end

    class Decorator < ::SimpleDelegator
      include Folio::Page
    end

    class DecoratedArray < Decorator
      def initialize
        super []
      end
    end

    def self.decorate(collection)
      collection = Folio::Page::Decorator.new(collection) unless collection.is_a?(Folio::Page)
      collection
    end

    def self.create
      Folio::Page::DecoratedArray.new
    end
  end
end
