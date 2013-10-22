require 'folio/ordinal'
require 'delegate'

module Folio
  module Enumerable
    class Decorator < ::SimpleDelegator
      # just fill a typical ordinal page
      def build_page
        ::Folio::Ordinal::Page.create
      end

      # fill by taking the appropriate slice out of the enumerable. if
      # the slice is empty and it's not the first page, it's invalid
      def fill_page(page)
        slice = self.each_slice(page.per_page).first(page.current_page)[page.current_page-1] || []
        raise ::Folio::InvalidPage if slice.empty? && page.current_page != page.first_page
        page.replace slice
        page
      end

      # things that already included Enumerable won't have extended the
      # PerPage, so the instance's default default_per_page method looking
      # at self.class.per_page won't work. point it back at
      # Folio.per_page
      def default_per_page
        Folio.per_page
      end

      include ::Folio::Ordinal

      METHODS = self.instance_methods - SimpleDelegator.instance_methods
    end
  end
end

# Extends any Enumerable to act like a Folio::Ordinal. Important: the
# source Enumerable is still not a Folio::Ordinal (it's not in the
# ancestors list). Instead, any Enumerable can be decorated via its new
# `pagination_decorated` method, and all folio methods are forwarded to
# that decorated version.
module Enumerable
  def pagination_decorated
    @pagination_decorated ||= Folio::Enumerable::Decorator.new(self)
  end

  Folio::Enumerable::Decorator::METHODS.each do |method|
    define_method(method) do |*args|
      pagination_decorated.send(method, *args)
    end
  end
end
