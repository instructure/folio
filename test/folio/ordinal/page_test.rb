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

  describe "decorate" do
    before do
      @page = Folio::Ordinal::Page.decorate([])
    end

    it "should add page methods to the object" do
      assert_respond_to @page, :current_page
    end

    it "should add ordinal page methods to the object" do
      @page.first_page.must_equal 1
    end

    it "should preserve other methods on the object" do
      assert_respond_to @page, :each
    end
  end

  describe "create" do
    before do
      @page = Folio::Ordinal::Page.create
    end

    it "should be an Array at heart" do
      @page.must_be :is_a?, Array
    end

    it "should be decorated as an ordinal page" do
      @page.first_page.must_equal 1
    end
  end
end
