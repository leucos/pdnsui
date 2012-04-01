require_relative '../helper'

describe "The Domains controller" do
  behaves_like :rack_test

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
    last_response.should =~ /0.controller.domain.spec/
  end

  should 'show domains list in ascending order' do
    # Fixtures
    ('0000'..'0050').each do |t|
      Domain.create(:name => "#{t}.sdliao.controller.domain.spec",
                    :type => 'MASTER')
    end
    # Test
    get('/domains/', :order => 'asc').status.should == 200
    last_response.should =~ /0000.sdliao.controller.domain.spec/
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
    last_response.should =~ /zzzz.sdlido.controller.domain.spec/
  end

  should 'show records page' do
    get("/domains/records/#{@domains[0].id}").status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /<h1>\s+0.controller.domain.spec/
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
    last_response.should =~ /0000.srpiao.controller.spec/
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
    last_response.should =~ /zzzz.srpido.controller.domain.spec/
  end

  should 'not show a records for a non-existent domain' do
    get("/domains/records/99999").status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Sorry, the domain id '99999' doesn't exist/
  end

  should 'not show a records for a nil domain' do
    get("/domains/records/").status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Ooops, you didn't ask me which domain you wanted/
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
    last_response.should =~ /Entry controller.domain.spec/
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
    last_response.should =~ /Entry 1.controller.domain.spec updated successfully/
   end

  should 'not update a non-existent domain' do
    post('/domains/save',
         :domain_id   => 999999,
         :name =>'1.controller.domain.spec',
         :type => 'MASTER',
         :master => '4.3.2.1').status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response.should =~ /Can not update this domain/
  end

  should 'refuse to add a slave domain without master' do
    post('/domains/save',
         :name => '1.controller.domain.spec',
         :type => 'SLAVE').status.should == 302
    last_response['Content-Type'].should == 'text/html'
    follow_redirect! 
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Invalid data : master is not present/
  end

  should 'not create or update a nil domain' do
    post('/domains/save').status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response.should =~ /Invalid data : name is not present, type is not present, type is not a valid domain type/
  end

  should 'delete domain' do
    id = Domain.filter(:name => '0.controller.domain.spec').first[:id]

    get("/domains/delete/#{id}").status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Entry 0.controller.domain.spec deleted successfully/
  end

  should 'not delete a non-existent domain' do
    get("/domains/delete/99999").status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Sorry, the domain id '99999' doesn't exist/
  end

  should 'not delete a nil domain' do
    get("/domains/delete/").status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Ooops, you didn't ask me which domain you wanted/
  end

  should 'not add the same domain twice' do
    post('/domains/save',
         :name => '0.controller.domain.spec',
         :type => 'SLAVE',
         :master => '1.2.3.4').status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /Invalid data : name is already taken/
  end

  # 'View' oriented specs
  
  # TODO: Lame test alert. Use hpricot. See pagination helper in Ramaze for help 
  should 'highligh domain properly in sidebar' do
    get("/domains/records/#{@domains[0].id}").status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.should =~ /<li class="active">/
  end

end
