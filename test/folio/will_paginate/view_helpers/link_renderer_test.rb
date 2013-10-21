require 'minitest/autorun'
require 'folio/will_paginate/view_helpers/link_renderer'
require 'folio/page'

describe WillPaginate::ViewHelpers::LinkRenderer do
  before do
    klass = Class.new(WillPaginate::ViewHelpers::LinkRenderer) { def url(page); "url://#{page}"; end }
    @renderer = klass.new
    @collection = Folio::Page.create
  end

  describe "previous_page" do
    it "should respect collection.previous_page" do
      @collection.previous_page = 5
      @renderer.prepare(@collection, {}, nil)
      @renderer.previous_page.must_match %r{url://5}
    end

    it "should produce link for non-numeric value" do
      @collection.previous_page = "abcdef"
      @renderer.prepare(@collection, {}, nil)
      @renderer.previous_page.must_match %r{url://abcdef}
    end

    it "should have rel=previous in the html for non-numeric value" do
      @collection.previous_page = "abcdef"
      @renderer.prepare(@collection, {}, nil)
      @renderer.previous_page.must_match %r{rel="prev"}
    end

    it "should have rel=start in the html for non-numeric value matching first_page" do
      @collection.first_page = "abcdef"
      @collection.previous_page = "abcdef"
      @renderer.prepare(@collection, {}, nil)
      @renderer.previous_page.must_match %r{rel="prev start"}
    end
  end

  describe "next_page" do
    it "should respect collection.next_page" do
      @collection.next_page = 15
      @renderer.prepare(@collection, {}, nil)
      @renderer.next_page.must_match %r{url://15}
    end

    it "should produce link for non-numeric value" do
      @collection.next_page = "abcdef"
      @renderer.prepare(@collection, {}, nil)
      @renderer.next_page.must_match %r{url://abcdef}
    end

    it "should have rel=next in the html for non-numeric value" do
      @collection.next_page = "abcdef"
      @renderer.prepare(@collection, {}, nil)
      @renderer.next_page.must_match %r{rel="next"}
    end
  end
end
