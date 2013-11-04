require "folio/version"
require "folio/per_page"

# Mix into any class implementing the following two methods:
#
# +build_page+: Responsible for instantiating a Folio::Page and
# configuring its ordinal_pages?, first_page, and last_page attributes;
# those values being common to any page returned from the folio.
#
# +fill_page+: Receives a Folio::Page with the ordinal_pages?,
# first_page, last_page, current_page, per_page, and total_entries
# attributes configured, and populates the page with the corresponding
# items from the folio. Also sets appropriate values for the next_page
# and previous_page attributes on the page. If the value provided in the
# page's current_page cannot be interpreted as addressing a page in the
# folio, raises Folio::InvalidPage.
#
# In return, `Folio` provides a the paginate method and per_page
# attributes described below.
module Folio
  # Returns a page worth of items from the folio in a Folio::Page.
  # accepts the following parameters:
  #
  # +page+: a page identifier addressing which page of the folio to
  # return. if not present, the first page will be returned. will raise
  # Folio::InvalidPage if the provided value cannot be used to address a
  # page.
  #
  # +per_page+: number of items to attempt to include in the page. if
  # not present, defaults to the folio's per_page value. should only
  # include fewer items if the end of the folio is reached.
  #
  # +total_entries+: pre-calculated value for the total number of items
  # in the folio. may be nil, indicating the returned page should have
  # total_entries nil.
  #
  # if the folio implements a count method and the total_entries
  # parameter is not supplied, the page's total_entries will be set from
  # the count method.
  def paginate(options={})
    page = self.build_page
    page = self.configure_pagination(page, options)
    page = self.fill_page(page)
    page
  end

  def configure_pagination(page, options)
    current_page = options.fetch(:page) { nil }
    current_page = page.first_page if current_page.nil?
    page.current_page = current_page
    page.per_page = options.fetch(:per_page) { self.per_page }
    page.total_entries = options.fetch(:total_entries) { self.respond_to?(:count) ? self.count : nil }
    page
  end

  def default_per_page
    self.class.per_page
  end

  include ::Folio::PerPage

  # this funny pattern is so that if a module (e.g. Folio::Ordinal)
  # includes this module, it won't get the per_page attribute, but will
  # still be able to bestow that attribute on any class that includes
  # *it*.
  module PerPageIncluder
    def included(klass)
      if klass.is_a?(Class)
        klass.extend ::Folio::PerPage
      else
        klass.extend ::Folio::PerPageIncluder
      end
    end
  end

  extend PerPageIncluder
  extend PerPage
  per_page(30)
end

# load the other commonly used portions of the gem
require "folio/page"
require "folio/ordinal"
