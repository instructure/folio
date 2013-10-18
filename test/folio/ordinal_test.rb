require 'minitest/autorun'
require 'folio/ordinal'

describe Folio::Ordinal do
  before do
    @klass = Class.new do
      def build_page
        Folio::BasicPage.new
      end

      def fill_page(page)
      end

      include Folio::Ordinal
    end
    @folio = @klass.new
  end

  describe "decorated build_page" do
    before do
      @page = @folio.build_page
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
  end

  describe "bounds checking on fill_page" do
    before do
      @page = @folio.build_page
      @page.per_page = 10
      @page.total_entries = 30
    end

    it "should raise on non-integer page" do
      @page.current_page = "non-integer"
      lambda{ @folio.fill_page(@page) }.must_raise Folio::InvalidPage
    end

    it "should raise on negative page" do
      @page.current_page = -1
      lambda{ @folio.fill_page(@page) }.must_raise Folio::InvalidPage
    end

    it "should raise on page of 0" do
      @page.current_page = 0
      lambda{ @folio.fill_page(@page) }.must_raise Folio::InvalidPage
    end

    it "should raise on page greater than known last_page" do
      @page.current_page = 4
      lambda{ @folio.fill_page(@page) }.must_raise Folio::InvalidPage
    end

    it "should not raise on page number between first_page and known last_page" do
      @page.current_page = 1
      @folio.fill_page(@page)

      @page.current_page = 3
      @folio.fill_page(@page)
    end

    it "should not raise on large page if last_page unknown" do
      @page.total_entries = nil
      @page.current_page = 100
      @folio.fill_page(@page)
    end
  end

  it "should behave like a Folio" do
    @folio.must_respond_to :paginate
  end
end
