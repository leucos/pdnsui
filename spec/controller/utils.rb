require_relative '../helper'

describe "The Utils controller" do
  behaves_like :rack_test

  should 'notify slaves' do
    get('/utils/notify_slaves').status.should.equal 302
    follow_redirect!
    last_response.status.should.equal 200
    noko_text('div.alert-block p').should.equal "This is not implemented yet :("
  end
end
