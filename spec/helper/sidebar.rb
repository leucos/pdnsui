require_relative '../helper'

require 'nokogiri'

class SpecHelperSidebar < Ramaze::Controller
  map '/sidebar'
  helper :sidebar

  def index(name)
    @domain = Domain[:name=>"#{name}"]
    generate(@domain)
  end
end


describe "The Sidebar helper" do
  behaves_like :rack_test

  before do
    %w{aaaa bbbb cccc}.each do |short|
      Domain.create(:name => "#{short}.sidebar.example.com", :type => 'MASTER')
    end
  end

  after do
    Domain.filter(:name.like('%.sidebar.example.com')).delete
  end

  should 'highlight domain properly' do
    %w{aaaa bbbb cccc}.each do |short|
      doc = Nokogiri::HTML(get("/sidebar/#{short}.sidebar.example.com").body)

      doc.css("li.active").text.should.not.be.empty
      doc.css("ul > li.active").each do |li|
        li.css("a").text.should.equal "#{short}.sidebar.example.com"
      end

    end
  end

end
