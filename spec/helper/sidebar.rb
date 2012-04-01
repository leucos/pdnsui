require_relative '../helper'

require 'hpricot'

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
      doc = Hpricot(get("/sidebar/#{short}.sidebar.example.com").body)
      doc.to_s.should =~ /<li class="active">/
      (doc/'ul//li[@class="active"]').each do |li|
        (li/"a").inner_html.should == "#{short}.sidebar.example.com"
      end
    end
  end

end
