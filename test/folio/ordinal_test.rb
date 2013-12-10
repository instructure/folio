require 'minitest/autorun'
require 'folio/ordinal'

describe Folio::Ordinal do
  before do
    klass = Class.new do
      def build_page
        Folio::Ordinal::Page.create
      end

      def fill_page(page)
        page
      end

      include Folio::Ordinal
    end
    @folio = klass.new
  end

  describe "paginate" do
    describe "bounds checking" do
      before do
        @folio.per_page = 10
      end

      it "should raise on non-integer page" do
        lambda{ @folio.paginate(page: "non-integer") }.must_raise Folio::InvalidPage
      end

      it "should raise on negative page" do
        lambda{ @folio.paginate(page: -1) }.must_raise Folio::InvalidPage
      end

      it "should raise on page of 0" do
        lambda{ @folio.paginate(page: 0) }.must_raise Folio::InvalidPage
      end

      it "should raise on page greater than known last_page" do
        lambda{ @folio.paginate(page: 4, total_entries: 30) }.must_raise Folio::InvalidPage
      end

      it "should not raise on page number between first_page and known last_page" do
        @folio.paginate(page: 1, total_entries: 30)
        @folio.paginate(page: 3, total_entries: 30)
      end

      it "should not raise on large page if last_page unknown" do
        @folio.paginate(page: 100)
      end
    end
  end
end
