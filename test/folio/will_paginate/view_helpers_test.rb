require 'minitest/autorun'
require 'folio/will_paginate/view_helpers'

# for I18n in page_entries_info
require 'active_support/core_ext/string/inflections'

describe WillPaginate::ViewHelpers do
  include WillPaginate::ViewHelpers

  before do
    @collection = Folio::Ordinal::Page.create
  end

  describe "will_paginate" do
    before do
      @renderer = Minitest::Mock.new
      @renderer.expect(:prepare, nil, [@collection, Hash, self])
      @renderer.expect(:to_html, '<PAGES>')
    end

    it "should return nil if total_pages is 1" do
      @collection.total_entries = @collection.per_page
      will_paginate(@collection, :renderer => @renderer).must_be_nil
    end

    it "should not error if total_entries is unknown" do
      @collection.total_entries = nil
      will_paginate(@collection, :renderer => @renderer).must_equal '<PAGES>'
    end
  end

  describe "page_entries_info" do
    it "should return nominally if collection is ordinal with total_entries known" do
      @collection.total_entries = 20
      page_entries_info(@collection).wont_be_nil
    end

    it "should return nil if total_entries is unknown" do
      @collection.total_entries = nil
      page_entries_info(@collection).must_be_nil
    end

    it "should return nil if collection is non-ordinal" do
      @collection = Folio::Page.create
      @collection.total_entries = 20
      page_entries_info(@collection).must_be_nil
    end
  end
end
