require 'minitest/autorun'
require 'folio/ordinal'

describe Folio::Ordinal::Page do
  before do
    @page = Folio::Ordinal::Page.create
    @page.current_page = 1
    @page.per_page = 10
    @page.total_entries = 30
  end

  it "should have ordinal_pages=true" do
    @page.ordinal_pages.must_equal true
    @page.ordinal_pages?.must_equal true
  end

  it "should have first_page=1" do
    @page.first_page.must_equal 1
  end

  it "should force current_page to an integer" do
    @page.current_page = "3"
    @page.current_page.must_equal 3
  end

  describe "when total pages known" do
    it "should have last_page=total_pages" do
      @page.last_page.must_equal @page.total_pages

      @page.total_entries = 0
      @page.last_page.must_equal @page.total_pages

      @page.total_entries = nil
      @page.last_page.must_equal @page.total_pages
    end

    it "should have next_page=current_page+1 when not at end" do
      @page.current_page = 2
      @page.next_page.must_equal 3
    end

    it "should still have next_page=current_page+1 when not at end, despite set value" do
      @page.current_page = 2
      @page.next_page = nil
      @page.next_page.must_equal 3
    end

    it "should have next_page=nil when at end" do
      @page.current_page = 3
      @page.next_page.must_be_nil
    end

    it "should still have next_page=nil when at end, despite set value" do
      @page.current_page = 3
      @page.next_page = 4
      @page.next_page.must_be_nil
    end
  end

  describe "when total pages not known" do
    before do
      @page.total_entries = nil
    end

    it "should have last_page=nil if next_page is known or assumed" do
      # @page.next_page unset
      @page.last_page.must_be_nil

      # @page.next_page explicitly non-nil
      @page.next_page = 2
      @page.last_page.must_be_nil
    end

    it "should have last_page=current_page if next_page is explicitly nil" do
      @page.next_page = nil
      @page.last_page.must_equal @page.current_page
    end

    it "should have next_page=current_page+1 when not explicitly set" do
      @page.current_page = 2
      @page.next_page.must_equal 3
    end

    it "should force non-nil set next_page to an integer" do
      @page.next_page = "4"
      @page.next_page.must_equal 4
    end

    it "should not force nil set next_page to an integer" do
      @page.next_page = nil
      @page.next_page.must_be_nil
    end

    it "should have next_page=set value when explicitly set" do
      @page.next_page = nil
      @page.current_page = 2
      @page.next_page.must_be_nil
    end
  end

  it "should have previous_page=nil when at beginning" do
    @page.current_page = 1
    @page.previous_page.must_be_nil
  end

  it "should have previous_page=current_page-1 when not at beginning" do
    @page.current_page = 3
    @page.previous_page.must_equal 2
  end

  describe "out_of_bounds?" do
    it "should be false if in first_page..last_page range" do
      @page.current_page = 1
      @page.out_of_bounds?.must_equal false

      @page.current_page = 3
      @page.out_of_bounds?.must_equal false
    end

    it "should be true if negative page" do
      @page.current_page = -1
      @page.out_of_bounds?.must_equal true
    end

    it "should be true if zero page" do
      @page.current_page = 0
      @page.out_of_bounds?.must_equal true
    end

    it "should be true after known last_page" do
      @page.current_page = 4
      @page.out_of_bounds?.must_equal true
    end

    it "should not care about large numbers when total_pages not known" do
      @page.total_entries = nil
      @page.current_page = 50
      @page.out_of_bounds?.must_equal false
    end
  end

  describe "BasicPage" do
    before do
      @page = Folio::Ordinal::BasicPage.new
    end

    it "should be an Array" do
      (Array === @page).must_equal true
    end

    it "should be a folio page" do
      assert_respond_to @page, :current_page
    end

    it "should be a ordinal folio page" do
      @page.first_page.must_equal 1
    end
  end

  describe "create" do
    before do
      @page = Folio::Ordinal::Page.create
    end

    it "should be a basic ordinal page" do
      @page.class.must_equal Folio::Ordinal::BasicPage
    end
  end
end
