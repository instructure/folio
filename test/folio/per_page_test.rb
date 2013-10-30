require 'minitest/autorun'
require 'folio/per_page'
require 'folio'

describe Folio::PerPage do
  before do
    @klass = Class.new{ include Folio::PerPage }
    @object = @klass.new
  end

  describe "default_per_page" do
    it "should be Folio.per_page" do
      was = Folio.per_page
      Folio.per_page = 100
      @object.default_per_page.must_equal 100
      Folio.per_page = was
    end
  end

  describe "per_page" do
    it "should return default_per_page if nil" do
      @klass.send(:define_method, :default_per_page) { 100 }
      @object.per_page = nil
      @object.per_page.must_equal 100
    end

    it "should return set value if non-nil" do
      @object.per_page = 100
      @object.per_page.must_equal 100
    end

    it "should allow setting through argument" do
      @object.per_page(100)
      @object.per_page.must_equal 100
    end

    it "should cast to integer when setting non-nil through argument" do
      @object.per_page("100")
      @object.per_page.must_equal 100
    end

    it "should allow setting to nil through argument" do
      @klass.send(:define_method, :default_per_page) { 100 }
      @object.per_page(30)
      @object.per_page(nil)
      @object.per_page.must_equal 100
    end
  end
end
