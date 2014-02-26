require 'folio'
require 'folio/ordinal/page'
require 'folio/invalid_page'

# Mix in to a source to provide the same methods as Folio, but with simpler
# build_page and fill_page methods required on the host (some responsibility is
# moved into the paginate method). build_page also has a default implementation.
#
#  * build_page no longer needs to configure ordinal_page?, first_page,
#    or last_page on the instantiated page. Instead, just instantiate
#    and return a Folio::Ordinal::Page. If not provided, the default
#    implementation just returns a Folio::Ordinal::BasicPage.
#
#  * fill_page no longer needs to configure next_page and previous_page; the
#    ordinal page will handle them. (Note that if necessary, you can still set
#    next_page explicitly to nil.) Also, paginate will now perform ordinal
#    bounds checking for you, so you can focus entirely on populating the page.
#
module Folio
  module Ordinal
    def build_page
      Folio::Ordinal::Page.create
    end

    # validate the configured page before returning it
    def configure_pagination(page, options)
      page = super(page, options)
      raise ::Folio::InvalidPage unless page.current_page.is_a?(Integer)
      raise ::Folio::InvalidPage if page.out_of_bounds?
      page
    rescue ::WillPaginate::InvalidPage
      raise ::Folio::InvalidPage
    end

    # otherwise acts like a normal folio
    include ::Folio
  end
end
