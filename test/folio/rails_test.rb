require 'folio/rails'
require 'folio/invalid_page'
require 'action_controller/base'

describe ActionController::Base do
  it "should translate Folio::InvalidPage to a 404" do
    controller = ActionController::Base.new
    code = controller.send :response_code_for_rescue, Folio::InvalidPage.new
    code.must_equal :not_found
  end
end
