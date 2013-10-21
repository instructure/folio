require 'minitest/autorun'
require 'folio/will_paginate/view_helpers/link_renderer_base'
require 'folio/page'

describe WillPaginate::ViewHelpers::LinkRendererBase do
  before do
    @renderer = WillPaginate::ViewHelpers::LinkRendererBase.new

    # looks just like a standard WillPaginate collection would
    @collection = Folio::Page.create
    @collection.ordinal_pages = true
    @collection.first_page = 1
    @collection.total_entries = 200
    @collection.per_page = 10
    @collection.last_page = 20
    @collection.current_page = 10
    @collection.next_page = 11
    @collection.previous_page = 9
  end

  it "should ignore page_links parameter with non-ordinal pages" do
    @collection.ordinal_pages = false
    @renderer.prepare(@collection, page_links: true)
    @renderer.pagination.must_equal [:previous_page, :next_page]
  end

  it "should still honor page_links parameter with ordinal pages" do
    @renderer.prepare(@collection, page_links: false)
    @renderer.pagination.must_equal [:previous_page, :next_page]

    @renderer.prepare(@collection, page_links: true)
    @renderer.pagination.must_equal [:previous_page, 1, :gap, 10, :gap, 20, :next_page]
  end

  it "should treat last_page as total_pages when known" do
    @collection.last_page = 15
    @renderer.prepare(@collection, {})
    @renderer.total_pages.must_equal @collection.last_page
  end

  it "should treat next_page as total_pages when last_page unknown" do
    @collection.last_page = nil
    @renderer.prepare(@collection, {})
    @renderer.total_pages.must_equal @collection.next_page
  end

  it "should add :gap after page links when last_page unknown" do
    @collection.last_page = nil
    @renderer.prepare(@collection, page_links: true, inner_window: 1)
    @renderer.pagination.must_equal [:previous_page, 1, :gap, 9, 10, 11, :gap, :next_page]
  end

  it "should end inner window at next_page when last_page unknown" do
    @collection.last_page = nil
    @renderer.prepare(@collection, page_links: true, inner_window: 2)
    @renderer.pagination.must_equal [:previous_page, 1, :gap, 7, 8, 9, 10, 11, :gap, :next_page]
  end
end
