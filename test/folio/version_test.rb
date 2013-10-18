require 'minitest/autorun'
require 'folio/version'

describe Folio::VERSION do
  it "should have a version" do
    Folio::VERSION.wont_be_nil
  end
end
