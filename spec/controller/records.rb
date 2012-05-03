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
         :content   => '3.example.com').status.should == 302
    last_response['Content-Type'].should == 'text/html'
    follow_redirect!
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Entry 2.example.com created successfully/
  end

  should 'update record for a domain' do
    post('/records/save',
         :domain_id => @domain.id,
         :record_id => @record.id,
         :name      => 'aaaa',
         :type      => 'CNAME',
         :content   => 'bbbb').status.should == 302
    last_response['Content-Type'].should == 'text/html'
    follow_redirect!
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Entry aaaa.example.com updated successfully/
  end

  should 'not update a non-existent record' do
    post('/records/save',
         :domain_id => @domain.id,
         :record_id => 999999,
         :name      => 'aaaa',
         :type      => 'CNAME',
         :content   => 'bbbb').status.should == 302
    last_response['Content-Type'].should == 'text/html'
    follow_redirect!
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Can not update this record/
  end

  should 'delete record' do
    get("/records/delete/#{@record.id}").status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Entry 0.example.com deleted successfully/
  end

  should 'not delete a non-existent record' do
    get("/records/delete/999999").status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Sorry, the record id '999999' doesn't exist/
  end

  should 'not delete a nil record' do
    get("/records/delete/").status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Ooops, you didn't ask me which record you wanted/
  end

  should 'not add the same record twice' do
    post('/records/save',
         :domain_id => @domain.id,
         :name      => '0.example.com',
         :type      => 'CNAME',
         :content   => '1.example.com').status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Invalid data : domain_id and name and type and content is already taken/
  end
end

