require_relative '../helper'
require 'json'

describe "The API controller" do
  behaves_like :rack_test

  before do
    @records = Array.new
    @domains = Array.new

    Domain.filter(:name => 'example.com').destroy
    Domain.filter(:name => 'oulala.com').destroy

    @domains << Domain.create(:name => 'example.com', :type => 'MASTER')

    @records << Record.new(:domain_id => @domains.first.id, :name => "0.example.com",
                           :type => "CNAME", :content => "1.example.com").save
    @records << Record.new(:domain_id => @domains.first.id, :name => "1.example.com",
                           :type => "A", :content => "192.168.0.222").save
    @records << Record.new(:domain_id => @domains.first.id, :name => "hattver.example.com",
                           :type => "LOC", :content => "63 56 05.05 N 19 2 32.31 W 0.0").save

    @domains << Domain.create(:name => 'oulala.com', :type => 'MASTER')
    @records << Record.new(:domain_id => @domains.last.id, :name => "some.oulala.com",
                           :type => "TXT", :content => "Random crap").save
  end

  after do
    @records.each { |r| r.destroy if r.exists? }
    @domains.each { |d| d.destroy if d.exists? }
  end

  # Searching
  # * `@<domain>` will restrict search to a single domain, e.g. `@github.com`
  # * `*<type>` will restrict search to a single type, e.g. `:mx`
  # * `:<id>` will retrieve a specific record ID
  # * `=<text>` will restrict search to records having 'test' in their `content` field
  # * `<text>` will search for 'text' in the record's name
  should 'allow searching freely' do
    get('/api/records/search/example.api').status.should.equal 200

    resp = JSON.parse(last_response.body)

    last_response['Content-Type'].should.equal 'application/json'
    resp.count.should.equal 3
    resp.first.name.should.equal "0.example.com"
  end

  should 'allow searching in a domain' do
    get('/api/records/search/@example.api').status.should.equal 200

    resp = JSON.parse(last_response.body)

    last_response['Content-Type'].should.equal 'application/json'
    resp.count.should.equal 3
    resp.each do |r|
      r.name.should.not.match(/oulala\.com/)
    end
  end

  should 'allow searching for types' do
    get("/api/records/search/*#{@records.last.type}.api").status.should.equal 200
   
    resp = JSON.parse(last_response.body)

    last_response['Content-Type'].should.equal 'application/json'
    resp.count.should.equal 1
    resp.first.name.should.equal @records.last.name
    resp.first.content.should.equal @records.last.content
  end

  should 'allow searching by id' do
    get("/api/records/search/:#{@records.last.id}.api").status.should.equal 200
   
    resp = JSON.parse(last_response.body)

    last_response['Content-Type'].should.equal 'application/json'
    resp.count.should.equal 1
    resp.first.name.should.equal @records.last.name
    resp.first.content.should.equal @records.last.content
  end

  should 'allow searching by content' do
    get("/api/records/search/=#{@records.last.content[2..5]}.api").status.should.equal 200
   
    resp = JSON.parse(last_response.body)

    last_response['Content-Type'].should.equal 'application/json'
    resp.count.should.equal 1
    resp.first.name.should.equal @records.last.name
    resp.first.content.should.equal @records.last.content
  end
  
  should 'allow searching by eveything' do
    uri = "/api/records/search/hattver" # free search 
    uri << "/" + "@" + Record[:name => "hattver.example.com"].domain.name[0..5] # domain filter
    uri << "/" + "*" + Record[:name => "hattver.example.com"].type # type filter
    uri << "/" + ":" + Record[:name => "hattver.example.com"].id.to_s # id  filter
    uri << "/" + "=" + URI.escape(Record[:name => "hattver.example.com"].content[5..9]) # content filter
    uri << ".api"

    get(uri).status.should.equal 200
    resp = JSON.parse(last_response.body)

    last_response['Content-Type'].should.equal 'application/json'
    resp.count.should.equal 1
    resp.first.name.should.equal Record[:name => "hattver.example.com"].name
    resp.first.content.should.equal Record[:name => "hattver.example.com"].content
  end
end
