require_relative '../helper'

describe "The Records controller" do
  behaves_like :rack_test

  before do
    Domain.filter(:name => 'example.com').destroy
    @domain = Domain.create(:name => 'example.com', :type => 'MASTER')
    @record = Record.new(:domain_id => @domain.id, :name => "0.example.com",
                         :type => "CNAME", :content => "1.example.com").save
  end

  after do
    @record.destroy if @record.exists?
    @domain.destroy
  end


  should 'add record for a domain' do
    post('/records/save',
         :domain_id => @domain.id,
         :name      => '2.example.com',
         :type      => 'CNAME',
         :content   => '3.example.com').status.should.equal 302
    last_response['Content-Type'].should.equal 'text/html'
    follow_redirect!
    last_response['Content-Type'].should.equal 'text/html'

    noko_text('div.alert-block p').should.equal "Entry 2.example.com created successfully"
  end

  should 'update record for a domain' do
    post('/records/save',
         :domain_id => @domain.id,
         :record_id => @record.id,
         :name      => 'aaaa',
         :type      => 'CNAME',
         :content   => 'bbbb').status.should.equal 302
    last_response['Content-Type'].should.equal 'text/html'
    follow_redirect!
    last_response['Content-Type'].should.equal 'text/html'
    noko_text('div.alert-block p').should.equal "Entry aaaa updated successfully"
  end

  should 'update record fields properly' do
    post('/records/save',
         :domain_id => @domain.id,
         :record_id => @record.id,
         :name      => 'abcd',
         :type      => 'TXT',
         :content   => 'efgh',
         :ttl       => 9876,
         :prio      => 42).status.should.equal 302
    last_response['Content-Type'].should.equal 'text/html'
    follow_redirect!
    last_response['Content-Type'].should.equal 'text/html'
    noko_text('div.alert-block p').should.equal "Entry abcd updated successfully"

    @record.reload
    @record.name.should.equal 'abcd.example.com'
    @record.type.should.equal 'TXT'
    @record.content.should.equal 'efgh'
    @record.ttl.should.equal 9876
    @record.prio.should.equal 42
  end

  should 'not update a non-existent record' do
    post('/records/save',
         :domain_id => @domain.id,
         :record_id => 999999,
         :name      => 'aaaa',
         :type      => 'CNAME',
         :content   => 'bbbb').status.should.equal 302
    last_response['Content-Type'].should.equal 'text/html'
    follow_redirect!
    last_response['Content-Type'].should.equal 'text/html'
    noko_text('div.alert-block p').should.equal "Invalid record : 999999"
  end

  should 'delete record' do
    get("/records/delete/#{@record.id}").status.should.equal 302
    follow_redirect!
    last_response.status.should.equal 200
    last_response['Content-Type'].should.equal 'text/html'
    noko_text('div.alert-block p').should.equal "Entry 0.example.com deleted successfully"
  end

  should 'not delete a non-existent record' do
    get("/records/delete/999999").status.should.equal 302
    follow_redirect!
    last_response.status.should.equal 200
    last_response['Content-Type'].should.equal 'text/html'
    noko_text('div.alert-block p').should.equal "Invalid record : 999999"
  end

  should 'not accept delete without an ID' do
    get("/records/delete/").status.should.equal 302
    follow_redirect!
    last_response.status.should.equal 200
    last_response['Content-Type'].should.equal 'text/html'    
  end

  should 'not add the same record twice' do
    post('/records/save',
         :domain_id => @domain.id,
         :name      => '0.example.com',
         :type      => 'CNAME',
         :content   => '1.example.com').status.should.equal 302
    follow_redirect!
    last_response.status.should.equal 200
    last_response['Content-Type'].should.equal 'text/html'

    noko_text('div.alert-block p').should.equal "Invalid data : domain_id and name and type and content is already taken"
  end
end

