require 'minitest/autorun'
require 'folio/will_paginate/view_helpers/link_renderer'
require 'folio/page'

describe WillPaginate::LinkRenderer do
  before do
    @template = Class.new do
      def link_to(*args)
        "link_to(#{args.map(&:inspect).join(', ')})"
      end

      def content_tag(*args)
        "content_tag(#{args.map(&:inspect).join(', ')})"
      end

      def will_paginate_translate(*args)
        yield
      end
    end.new

    @renderer = Class.new(WillPaginate::LinkRenderer) do
      def url_for(page)
        "url://#{page}"
      end
    end.new

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
    @renderer.prepare(@collection, {page_links: true, previous_label: "Previous", next_label: "Next"}, @template)
    @renderer.to_html.must_equal [
      @template.link_to("Previous", "url://9", {:rel=>"prev", :class=>"prev_page"}),
      @template.link_to("Next", "url://11", {:rel=>"next", :class=>"next_page"})
    ].join
  end

  it "should still honor page_links parameter with ordinal pages" do
    @renderer.prepare(@collection, {page_links: false, previous_label: "Previous", next_label: "Next"}, @template)
    @renderer.to_html.must_equal [
      @template.link_to("Previous", "url://9", {:rel=>"prev", :class=>"prev_page"}),
      @template.link_to("Next", "url://11", {:rel=>"next", :class=>"next_page"})
    ].join

    @renderer.prepare(@collection, {page_links: true, previous_label: "Previous", next_label: "Next"}, @template)
    @renderer.to_html.must_equal [
      @template.link_to("Previous", "url://9", {:rel=>"prev", :class=>"prev_page"}),
      @template.link_to("1", "url://1", {:rel=>"start", :class=>nil}),
      @renderer.gap_marker,
      @template.content_tag(:span, "10", {:class=>"current"}),
      @renderer.gap_marker,
      @template.link_to("20", "url://20", {:rel=>nil, :class=>nil}),
      @template.link_to("Next", "url://11", {:rel=>"next", :class=>"next_page"})
    ].join
  end

  it "should treat last_page as total_pages when known" do
    @collection.last_page = 15
    @renderer.prepare(@collection, {}, @template)
    @renderer.total_pages.must_equal @collection.last_page
  end

  it "should treat next_page as total_pages when last_page unknown" do
    @collection.last_page = nil
    @renderer.prepare(@collection, {}, @template)
    @renderer.total_pages.must_equal @collection.next_page
  end

  it "should add :gap after page links when last_page unknown" do
    @collection.last_page = nil
    @renderer.prepare(@collection, {page_links: true, previous_label: "Previous", next_label: "Next", inner_window: 1}, @template)
    @renderer.to_html.must_equal [
      @template.link_to("Previous", "url://9", {:rel=>"prev", :class=>"prev_page"}),
      @template.link_to("1", "url://1", {:rel=>"start", :class=>nil}),
      @renderer.gap_marker,
      @template.link_to("9", "url://9", {:rel=>"prev", :class=>nil}),
      @template.content_tag(:span, "10", {:class=>"current"}),
      @template.link_to("11", "url://11", {:rel=>"next", :class=>nil}),
      @renderer.gap_marker,
      @template.link_to("Next", "url://11", {:rel=>"next", :class=>"next_page"})
    ].join
  end

  it "should end inner window at next_page when last_page unknown" do
    @collection.last_page = nil
    @renderer.prepare(@collection, {page_links: true, previous_label: "Previous", next_label: "Next", inner_window: 2}, @template)
    @renderer.to_html.must_equal [
      @template.link_to("Previous", "url://9", {:rel=>"prev", :class=>"prev_page"}),
      @template.link_to("1", "url://1", {:rel=>"start", :class=>nil}),
      @renderer.gap_marker,
      @template.link_to("7", "url://7", {:rel=>nil, :class=>nil}),
      @template.link_to("8", "url://8", {:rel=>nil, :class=>nil}),
      @template.link_to("9", "url://9", {:rel=>"prev", :class=>nil}),
      @template.content_tag(:span, "10", {:class=>"current"}),
      @template.link_to("11", "url://11", {:rel=>"next", :class=>nil}),
      @renderer.gap_marker,
      @template.link_to("Next", "url://11", {:rel=>"next", :class=>"next_page"})
    ].join
  end

  describe "previous_page" do
    it "should respect collection.previous_page" do
      @collection.previous_page = 5
      @renderer.prepare(@collection, {page_links: false, previous_label: "Previous", next_label: "Next"}, @template)
      @renderer.to_html.must_equal [
        @template.link_to("Previous", "url://5", {:rel=>"prev", :class=>"prev_page"}),
        @template.link_to("Next", "url://11", {:rel=>"next", :class=>"next_page"})
      ].join
    end

    it "should produce link with rel=prev for non-numeric" do
      @collection.previous_page = "abcdef"
      @renderer.prepare(@collection, {page_links: false, previous_label: "Previous", next_label: "Next"}, @template)
      @renderer.to_html.must_equal [
        @template.link_to("Previous", "url://abcdef", {:rel=>"prev", :class=>"prev_page"}),
        @template.link_to("Next", "url://11", {:rel=>"next", :class=>"next_page"})
      ].join
    end

    it "should have rel=start in the html for non-numeric value matching first_page" do
      @collection.first_page = "abcdef"
      @collection.previous_page = "abcdef"
      @renderer.prepare(@collection, {page_links: false, previous_label: "Previous", next_label: "Next"}, @template)
      @renderer.to_html.must_equal [
        @template.link_to("Previous", "url://abcdef", {:rel=>"prev start", :class=>"prev_page"}),
        @template.link_to("Next", "url://11", {:rel=>"next", :class=>"next_page"})
      ].join
    end
  end

  describe "next_page" do
    it "should respect collection.next_page" do
      @collection.next_page = 15
      @renderer.prepare(@collection, {page_links: false, previous_label: "Previous", next_label: "Next"}, @template)
      @renderer.to_html.must_equal [
        @template.link_to("Previous", "url://9", {:rel=>"prev", :class=>"prev_page"}),
        @template.link_to("Next", "url://15", {:rel=>"next", :class=>"next_page"})
      ].join
    end

    it "should produce link with rel=next for non-numeric value" do
      @collection.next_page = "abcdef"
      @renderer.prepare(@collection, {page_links: false, previous_label: "Previous", next_label: "Next"}, @template)
      @renderer.to_html.must_equal [
        @template.link_to("Previous", "url://9", {:rel=>"prev", :class=>"prev_page"}),
        @template.link_to("Next", "url://abcdef", {:rel=>"next", :class=>"next_page"})
      ].join
    end
  end
end
