require 'folio/ordinal'
require 'folio/basic_page'

# Extends any Enumerable to be a Folio::Ordinal.
module Enumerable
  def build_page
    ::Folio::BasicPage.new
  end

  def fill_page(page)
    slice = self.each_slice(page.per_page).first(page.current_page)[page.current_page-1]
    if slice.nil?
      if page.current_page > page.first_page
        raise ::Folio::InvalidPage
      else
        slice = []
      end
    end
    page.replace slice
  end

  include ::Folio::Ordinal

  # this is crazy, but it essentially links in the methods defined on
  # the module we just included into Enumerable itself, so that things
  # that already included Enumerable can inherit them
  ::Folio::Ordinal.instance_methods.each do |method|
    alias_method method, method
  end

  # things that already included Enumerable won't have extended the
  # PerPage, so the instance's default default_per_page method looking
  # at self.class.per_page won't work. point it back at
  # Folio.per_page
  def default_per_page
    Folio.per_page
  end
end
