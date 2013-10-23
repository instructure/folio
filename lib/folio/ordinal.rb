require 'folio'
require 'folio/ordinal/page'
require 'folio/invalid_page'

# Mix in to a source to provide the same methods as Folio, but with simpler
# build_page and fill_page methods required on the host (some responsibility is
# moved into the paginate method).
#
#  * build_page no longer needs to configure ordinal_page?, first_page,
#    or last_page on the instantiated page. Instead, just instantiate
#    and return a Folio::Ordinal::Page. If what you return is not a
#    Folio::Ordinal::Page, paginate will decorate it to be one.
#
#  * fill_page no longer needs to configure next_page and previous_page; the
#    ordinal page will handle them. (Note that if necessary, you can still set
#    next_page explicitly to nil.) Also, paginate will now perform ordinal
#    bounds checking for you, so you can focus entirely on populating the page.
#
module Folio
  module Ordinal
    # decorate the page before configuring, and then validate the configured
    # current_page before returning it
    def configure_pagination(page, options)
      page = super(::Folio::Ordinal::Page.decorate(page), options)
      raise ::Folio::InvalidPage unless page.current_page.is_a?(Integer)
      raise ::Folio::InvalidPage if page.out_of_bounds?
      page
    end

    # otherwise acts like a normal folio
    include ::Folio
  end
end
