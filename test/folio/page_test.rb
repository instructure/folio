require 'minitest/autorun'
require 'folio/page'

describe Folio::Page do
  before do
    klass = Class.new{ include Folio::Page }
    @page = klass.new
  end

  describe "ordinal_pages" do
    it "should have ordinal_pages accessors" do
      @page.must_respond_to :ordinal_pages
      @page.must_respond_to :ordinal_pages=
      @page.must_respond_to :ordinal_pages?
    end

    it "should mutate with ordinal_pages=" do
      @page.ordinal_pages = true
      @page.ordinal_pages.must_equal true
    end

    it "should alias reader as predicate" do
      @page.ordinal_pages = true
      @page.ordinal_pages?.must_equal true
    end
  end

  describe "current_page" do
    it "should have current_page accessors" do
      @page.must_respond_to :current_page
      @page.must_respond_to :current_page=
    end

    it "should mutate with current_page=" do
      @page.current_page = 3
      @page.current_page.must_equal 3
    end
  end

  describe "per_page" do
    it "should have per_page accessors" do
      @page.must_respond_to :per_page
      @page.must_respond_to :per_page=
    end

    it "should mutate with per_page=" do
      @page.per_page = 3
      @page.per_page.must_equal 3
    end
  end

  describe "first_page" do
    it "should have first_page accessors" do
      @page.must_respond_to :first_page
      @page.must_respond_to :first_page=
    end

    it "should mutate with first_page=" do
      @page.first_page = 3
      @page.first_page.must_equal 3
    end
  end

  describe "last_page" do
    it "should have last_page accessors" do
      @page.must_respond_to :last_page
      @page.must_respond_to :last_page=
    end

    it "should mutate with last_page= when next_page is non-nil" do
      @page.next_page = 3
      @page.last_page = 5
      @page.last_page.must_equal 5
    end

    it "should default last_page=nil if unset and next_page is non-nil" do
      @page.current_page = 2
      @page.next_page = 3
      @page.last_page.must_be_nil
    end

    it "should default last_page=current_page if unset and next_page is nil" do
    end

    it "should have last_page=current_page if next_page is nil, even if explicitly set" do
      @page.current_page = 2
      @page.last_page.must_equal 2

      @page.last_page = 4
      @page.last_page.must_equal 2

      @page.last_page = nil
      @page.last_page.must_equal 2
    end
  end

  describe "next_page" do
    it "should have next_page accessors" do
      @page.must_respond_to :next_page
      @page.must_respond_to :next_page=
    end

    it "should mutate with next_page=" do
      @page.next_page = 3
      @page.next_page.must_equal 3
    end
  end

  describe "previous_page" do
    it "should have previous_page accessors" do
      @page.must_respond_to :previous_page
      @page.must_respond_to :previous_page=
    end

    it "should mutate with previous_page=" do
      @page.previous_page = 3
      @page.previous_page.must_equal 3
    end
  end

  describe "total_entries" do
    it "should have total_entries accessors" do
      @page.must_respond_to :total_entries
      @page.must_respond_to :total_entries=
    end

    it "should mutate with total_entries=" do
      @page.total_entries = 3
      @page.total_entries.must_equal 3
    end
  end

  describe "total_pages" do
    before do
      @page.total_entries = 10
      @page.per_page = 5
    end

    it "should be nil if total_entries is nil" do
      @page.total_entries = nil
      @page.total_pages.must_be_nil
    end

    it "should be nil if per_page is nil" do
      @page.per_page = nil
      @page.total_pages.must_be_nil
    end

    it "should be nil if per_page is 0" do
      @page.per_page = 0
      @page.total_pages.must_be_nil
    end

    it "should be 1 if total_entries is 0" do
      @page.total_entries = 0
      @page.total_pages.must_equal 1
    end

    it "should be total_entries/per_page if evenly divisible" do
      @page.total_pages.must_equal 2
    end

    it "should round up if not evenly divisible" do
      @page.per_page = 3
      @page.total_pages.must_equal 4
    end
  end
end
