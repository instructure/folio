require 'minitest/autorun'
require 'folio/basic_page'

describe Folio::BasicPage do
  before do
    @page = Folio::BasicPage.new
  end

  it "should be an enumerable" do
    @page.must_respond_to :each
  end

  it "should be a page" do
    @page.must_respond_to :current_page
  end
end
