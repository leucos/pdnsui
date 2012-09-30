require_relative '../helper'
require 'nokogiri'
require 'date'

module Rack
  class MockResponse
    def tb_alertbox
      ab = Nokogiri::HTML(self.body)
      ab.css("div.alert > p").text
    end
  end
end

describe "The Domains controller" do
  behaves_like :rack_test

  serial_root = Date.today.strftime("%Y%m%d")

  before do
    Domain.filter(:name.like("%controller.domain.spec")).destroy
    @domains = Array.new
    [ '0', 'zzzz' ].each do |d|
      Domain.filter(:name  => "#{d}.controller.domain.spec").destroy
      @domains<<Domain.create(:name => "#{d}.controller.domain.spec", :type => 'MASTER')
    end
  end

  after do
    Domain.filter(:name.like("%controller.domain.spec")).destroy
  end

  should 'show domains list' do
    get('/domains/').status.should == 200
    last_response.body.should =~ /0.controller.domain.spec/
  end

  should 'show domains list in ascending order' do
    # Fixtures
    ('0000'..'0050').each do |t|
      Domain.create(:name => "#{t}.sdliao.controller.domain.spec",
                    :type => 'MASTER')
    end
    # Test
    get('/domains/', :order => 'asc').status.should == 200
    last_response.body.should =~ /0000.sdliao.controller.domain.spec/
  end

  should 'show domains list in descending order' do
    # Fixtures
    ('zzya'..'zzzz').each do |t|
      Domain.create(:name => "#{t}.sdlido.controller.domain.spec",
                    :type => 'MASTER',
                    :master => 'spec-sdlido')
    end
    # Test
    get('/domains/', :order => 'desc').status.should == 200
    last_response.body.should =~ /zzzz.sdlido.controller.domain.spec/
  end

  should 'show records page' do
    get("/domains/records/#{@domains[0].id}").status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.body.should =~ /<h1>\s+0.controller.domain.spec/
  end

  should 'show records page in ascending order' do
    # Fixtures
    ('0000'..'0050').each do |t|
      @domains[0].add_record(:name => "#{t}.srpiao.controller.spec",
                         :type => 'A', :content => 'srpiao')
    end
    # Test
    get("/domains/records/#{@domains[0].id}", :order => 'asc').status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.body.should =~ /0000.srpiao.controller.spec/
  end

  should 'show records page in descending order' do
    # Fixtures
    ('zzya'..'zzzz').each do |t|
      @domains[0].add_record(:name => "#{t}.srpido.controller.domain.spec",
                            :type => 'A', :content => 'srpido')
    end
    # Test
    get("/domains/records/#{@domains[0].id}", :order => 'desc').status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.body.should =~ /zzzz.srpido.controller.domain.spec/
  end

  should 'not show a records for a non-existent domain' do
    get("/domains/records/99999").status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
#    last_response.tb_alertbox.should.equal "Sorry, the domain id '99999' doesn't exist"
    last_response.body.should =~ /Sorry, the domain id '99999' doesn't exist/
  end

  should 'not show a records for a nil domain' do
    get("/domains/records/").status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
#    last_response.tb_alertbox.should.equal "Ooops, you didn't ask me which domain you wanted"
    last_response.body.should =~ /Ooops, you didn't ask me which domain you wanted/
  end

  should 'add domain' do
    post('/domains/save',
         :name => 'controller.domain.spec',
         :type => 'SLAVE',
         :master => '1.2.3.4').status.should == 302
    last_response['Content-Type'].should == 'text/html'
    follow_redirect! 
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'

    last_response.tb_alertbox.should.equal 'Entry controller.domain.spec created successfully'
  end

  should 'update domain' do
    id = Domain.filter(:name => '0.controller.domain.spec').first[:id]

    # THINK: Well, this should probably be made illegal
    # or handled properly, e.g. rename all records for this domain
    post('/domains/save',
         :domain_id   => id,
         :name =>'1.controller.domain.spec',
         :type => 'MASTER',
         :master => '4.3.2.1').status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response.body.should =~ /Entry 1.controller.domain.spec updated successfully/
   end

  should 'not update a non-existent domain' do
    post('/domains/save',
         :domain_id   => 999999,
         :name =>'1.controller.domain.spec',
         :type => 'MASTER',
         :master => '4.3.2.1').status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response.body.should =~ /Can not update this domain/
  end

  should 'refuse to add a slave domain without master' do
    post('/domains/save',
         :name => '1.controller.domain.spec',
         :type => 'SLAVE').status.should == 302
    last_response['Content-Type'].should == 'text/html'
    follow_redirect! 
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.body.should =~ /Invalid data : master is not present/
  end

  should 'not create or update a nil domain' do
    post('/domains/save').status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response.body.should =~ /Invalid data : name is not present, type is not present, type is not a valid domain type/
  end

  should 'delete domain' do
    id = Domain.filter(:name => '0.controller.domain.spec').first[:id]

    get("/domains/delete/#{id}").status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.body.should =~ /Entry 0.controller.domain.spec deleted successfully/
  end

  should 'not delete a non-existent domain' do
    get("/domains/delete/99999").status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.body.should =~ /Sorry, the domain id '99999' doesn't exist/
  end

  should 'not delete a nil domain' do
    get("/domains/delete/").status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.body.should =~ /Ooops, you didn't ask me which domain you wanted/
  end

  should 'not add the same domain twice' do
    post('/domains/save',
         :name => '0.controller.domain.spec',
         :type => 'SLAVE',
         :master => '1.2.3.4').status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.body.should =~ /Invalid data : name is already taken/
  end

  should 'bump not bump a serial for a non existent domain' do
    get("/domains/bump_serial/999999")
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    nok = Nokogiri::HTML(last_response.body)
    nok.css("div.alert-error > p").first.text.should.equal "Sorry, the domain id '999999' doesn't exist"
  end

  should 'bump not bump a serial for a nil domain' do
    get("/domains/bump_serial/")
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    nok = Nokogiri::HTML(last_response.body)
    nok.css("div.alert-error > p").first.text.should.equal "Ooops, you didn't ask me which domain you wanted"
  end

  should 'bump a domain serial' do
    id = Domain.filter(:name => '0.controller.domain.spec').first[:id]
    r  = Record.create(:domain_id => id, :name => '0.controller.domain.spec', :type => 'SOA',
                  :content => "ns1.example.com postmaster.example.com #{serial_root}01 7200 3600 4800 86400",
                  :ttl => 4321)

    get("/domains/bump_serial/#{id}")
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    nok = Nokogiri::HTML(last_response.body)
    nok.css("div.alert-success > p").first.text.should.equal "Serial for domain 0.controller.domain.spec bumped to #{serial_root}02"
    r.delete
  end

  should 'complain when a domain serial already ends with 99' do
    id = Domain.filter(:name => '0.controller.domain.spec').first[:id]
    r  = Record.create(:domain_id => id, :name => '0.controller.domain.spec', :type => 'SOA',
                  :content => "ns1.example.com postmaster.example.com #{serial_root}99 7200 3600 4800 86400",
                  :ttl => 4321)

    post("/domains/bump_serial/#{id}")
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    nok = Nokogiri::HTML(last_response.body)
    nok.css("div.alert-error > p").first.text.should =~ /serial sequence is already maxed out for today/

    r.delete
  end

  should 'complain if trying to bump and no SOA exists for domain' do
    id = Domain.filter(:name => '0.controller.domain.spec').first[:id]

    post("/domains/bump_serial/#{id}")
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    nok = Nokogiri::HTML(last_response.body)
    nok.css("div.alert-error > p").first.text.should =~ /there is no soa record available for this domain/
  end

end
