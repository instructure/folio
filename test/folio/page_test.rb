require 'minitest/autorun'
require 'folio/page'
require 'folio'

describe Folio::Page do
  before do
    @page = Folio::Page.create
  end

  describe "ordinal_pages" do
    it "should have ordinal_pages accessors" do
      assert_respond_to @page, :ordinal_pages
      assert_respond_to @page, :ordinal_pages=
      assert_respond_to @page, :ordinal_pages?
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
      assert_respond_to @page, :current_page
      assert_respond_to @page, :current_page=
    end

    it "should mutate with current_page=" do
      @page.current_page = 3
      @page.current_page.must_equal 3
    end
  end

  describe "per_page" do
    it "should have per_page accessors" do
      assert_respond_to @page, :per_page
      assert_respond_to @page, :per_page=
    end

    it "should mutate with per_page=" do
      @page.per_page = 3
      @page.per_page.must_equal 3
    end

    it "should default to Folio.per_page" do
      was = Folio.per_page
      Folio.per_page = 100
      @page.per_page.must_equal Folio.per_page
      Folio.per_page = was
    end
  end

  describe "first_page" do
    it "should have first_page accessors" do
      assert_respond_to @page, :first_page
      assert_respond_to @page, :first_page=
    end

    it "should mutate with first_page=" do
      @page.first_page = 3
      @page.first_page.must_equal 3
    end
  end

  describe "last_page" do
    it "should have last_page accessors" do
      assert_respond_to @page, :last_page
      assert_respond_to @page, :last_page=
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
      assert_respond_to @page, :next_page
      assert_respond_to @page, :next_page=
    end

    it "should mutate with next_page=" do
      @page.next_page = 3
      @page.next_page.must_equal 3
    end
  end

  describe "previous_page" do
    it "should have previous_page accessors" do
      assert_respond_to @page, :previous_page
      assert_respond_to @page, :previous_page=
    end

    it "should mutate with previous_page=" do
      @page.previous_page = 3
      @page.previous_page.must_equal 3
    end
  end

  describe "total_entries" do
    it "should have total_entries accessors" do
      assert_respond_to @page, :total_entries
      assert_respond_to @page, :total_entries=
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

  describe "BasicPage" do
    before do
      @page = Folio::BasicPage.new
    end

    it "should be an Array" do
      (Array === @page).must_equal true
    end

    it "should be a folio page" do
      assert_respond_to @page, :current_page
    end
  end

  describe "create" do
    before do
      @page = Folio::Page.create
    end

    it "should be a basic page" do
      @page.class.must_equal Folio::BasicPage
    end
  end
end
