require_relative '../helper'

describe MainController do
  behaves_like :rack_test

  should 'show start page' do
    get('/').status.should.equal 200
    last_response['Content-Type'].should.equal 'text/html'
    #noko_text('div.hero-unit p').should.equal "PowerDNS web interface"
    Nokogiri::HTML(last_response.body).css('div.hero-unit p').first.text.should.equal "PowerDNS web interface"
  end

end
