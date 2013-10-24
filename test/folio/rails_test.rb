require 'folio/rails'
require 'folio/invalid_page'

describe ActionDispatch::ExceptionWrapper do
  before do
    # stolen from ActionDispatch::Railtie's initializer
    config = ActionDispatch::Railtie.config
    ActionDispatch::ExceptionWrapper.rescue_responses.merge!(config.action_dispatch.rescue_responses)
  end

  it "should translate Folio::InvalidPage to a 404" do
    wrapper = ActionDispatch::ExceptionWrapper.new({}, Folio::InvalidPage.new)
    wrapper.status_code.must_equal 404
  end
end
