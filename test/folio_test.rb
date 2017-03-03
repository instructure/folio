require 'minitest/autorun'
require 'folio'

describe Folio do
  describe "class per_page" do
    it "should have a per_page attribute" do
      Folio.must_respond_to :per_page
      Folio.must_respond_to :per_page=
    end

    it "should allow setting by per_page=" do
      was = Folio.per_page
      Folio.per_page = 100
      Folio.per_page.must_equal 100
      Folio.per_page = was
    end

    it "should allow setting by argument to per_page" do
      was = Folio.per_page
      Folio.per_page(100)
      Folio.per_page.must_equal 100
      Folio.per_page = was
    end

    it "should default to 30" do
      Folio.per_page.must_equal 30
    end
  end

  before do
    page_klass = Class.new do
      include Folio::Page
    end

    @klass = Class.new do
      define_method :build_page do
        page = page_klass.new
        page.ordinal_pages = false
        page.first_page = :first
        page.last_page = :last
        page
      end

      def fill_page(page)
        page.next_page = :next
        page.previous_page = :previous
        page
      end

      include Folio
    end

    @folio = @klass.new
  end

  describe "paginate" do
    it "should get the page from the folio's build_page method" do
      page = @folio.paginate
      page.ordinal_pages.must_equal false
      page.first_page.must_equal :first
      page.last_page.must_equal :last
    end

    it "should pass the page through the folio's fill_page method" do
      page = @folio.paginate
      page.next_page.must_equal :next
      page.previous_page.must_equal :previous
    end

    it "should populate current_page and per_page before passing it to fill_page" do
      @klass.send(:remove_method, :fill_page)
      @klass.send(:define_method, :fill_page) do |page|
        page.current_page.wont_be_nil
        page.per_page.wont_be_nil
      end
      @folio.paginate
    end

    describe "page parameter" do
      it "should populate onto the page" do
        page = @folio.paginate(page: :current)
        page.current_page.must_equal :current
      end

      it "should default to the page's first_page" do
        page = @folio.paginate
        page.current_page.must_equal page.first_page
      end

      it "should set to the page's first_page if explicitly nil" do
        page = @folio.paginate(page: nil)
        page.current_page.must_equal page.first_page
      end

      it "should not set to the page's first_page if explicitly false" do
        page = @folio.paginate(page: false)
        page.current_page.must_equal false
      end
    end

    describe "per_page parameter" do
      it "should populate onto the page" do
        page = @folio.paginate(per_page: 100)
        page.per_page.must_equal 100
      end

      it "should default to the folio's per_page" do
        @folio.per_page = 100
        page = @folio.paginate
        page.per_page.must_equal 100
      end
    end

    describe "total_entries parameter" do
      it "should populate onto the page" do
        page = @folio.paginate(total_entries: 100)
        page.total_entries.must_equal 100
      end

      it "should default to the nil if the folio does not implement count" do
        page = @folio.paginate
        page.total_entries.must_be_nil
      end

      it "should default to the result of count if the folio implements count" do
        @klass.send(:define_method, :count) { 100 }
        page = @folio.paginate
        page.total_entries.must_equal 100
      end

      it "should not-execute the count if total_entries provided" do
        called = false
        @klass.send(:define_method, :count) { called = true }
        @folio.paginate(total_entries: 100)
        called.must_equal false
      end

      it "should not-execute the count if total_entries provided as nil" do
        called = false
        @klass.send(:define_method, :count) { called = true }
        page = @folio.paginate(total_entries: nil)
        called.must_equal false
        page.total_entries.must_be_nil
      end
    end
  end

  describe "per_page class attribute" do
    it "should exist" do
      @klass.must_respond_to :per_page
      @klass.must_respond_to :per_page=
    end

    it "should be settable from per_page=" do
      @klass.per_page = 100
      @klass.per_page.must_equal 100
    end

    it "should be settable from per_page with argument" do
      @klass.per_page(100)
      @klass.per_page.must_equal 100
    end

    it "should default to Folio.per_page" do
      was = Folio.per_page
      Folio.per_page = 50
      @klass.per_page.must_equal 50
      Folio.per_page = was
    end
  end

  describe "per_page instance attribute" do
    it "should exist" do
      @folio.must_respond_to :per_page
      @folio.must_respond_to :per_page=
    end

    it "should be settable from per_page=" do
      @folio.per_page = 100
      @folio.per_page.must_equal 100
    end

    it "should be settable from per_page with argument" do
      @folio.per_page(100)
      @folio.per_page.must_equal 100
    end

    it "should default to class' per_page" do
      @klass.per_page = 50
      @folio.per_page.must_equal 50
    end
  end
end
