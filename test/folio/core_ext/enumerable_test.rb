require 'minitest/autorun'
require 'folio/core_ext/enumerable'

describe Array do
  it "should be an ordinal folio" do
    [].must_respond_to :build_page
    [].build_page.first_page.must_equal 1
  end

  describe "per_page" do
    it "should have per_page attribute as expected on instances" do
      [].must_respond_to :per_page
      [].must_respond_to :per_page=
    end

    it "should not have per_page attribute on classes" do
      Array.wont_respond_to :per_page
      Array.wont_respond_to :per_page=
    end

    it "should default to Folio.per_page" do
      was = Folio.per_page
      Folio.per_page = 100
      [].per_page.must_equal 100
      Folio.per_page = was
    end
  end

  describe "paginate" do
    before do
      @ary = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    end

    it "should return a page" do
      page = @ary.paginate
      page.must_respond_to :current_page
    end

    it "should return appropriate slice" do
      @ary.paginate(page: 2, per_page: 4).must_equal [5, 6, 7, 8]
    end

    it "should return partial slice at end" do
      @ary.paginate(page: 3, per_page: 4).must_equal [9, 10]
    end

    it "should raise InvalidPage after end even if size unknown" do
      lambda{ @ary.paginate(page: 3, per_page: 5, total_entries: nil) }.must_raise Folio::InvalidPage
    end

    it "should return empty first page if empty" do
      [].paginate.must_equal []
    end
  end
end
