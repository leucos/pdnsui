require_relative '../helper'

describe "A Domain" do
  behaves_like :rack_test

  before do
    clean = Domain[:name => 'spec.com']
    clean.destroy unless clean.nil?

    @domain = Domain.create(:name => 'spec.com', :type => 'MASTER')
    @record = Record.create(:domain_id => @domain.id, :name => 'www.spec.com', :type => 'A',
                     :content => '10.10.10.10', :ttl => 1234)
    @soa = Record.create(:domain_id => @domain.id, :name => 'spec.com', :type => 'SOA',
                  :content => 'ns.spec.com root.spec.com 2006090501 7200 3600 4800 86400',
                  :ttl => 4321)
  end

  after do
    @record.destroy
    @soa.destroy
    @domain.destroy
  end

  should 'have a name' do
    @record.name.should.not.be.nil
    @soa.name.should.not.be.nil
  end

  should 'have some records' do
    @domain.records.count.should.not.equal 0
  end

  should 'not accept being created twice' do
    should.raise(Sequel::ValidationFailed) do
      Domain.create(:name => 'spec.com', :type => 'MASTER')
    end
  end

  should 'refuse to be slave if master field is empty' do
    should.raise(Sequel::ValidationFailed) do
      d = Domain.create(:name => 'rtbsimfie.spec.com', :type => 'SLAVE')
      d.destroy unless d.nil?
    end
    should.raise(Sequel::ValidationFailed) do
      d = Domain.create(:name => 'rtbsimfie.spec.com', :type => 'SLAVE', :master => '')
      d.destroy unless d.nil?
    end
  end

  should 'return ns from SOA' do
    @domain.soa.domain_ns.should.equal "ns.spec.com"
  end

  should 'return email from SOA' do
    @domain.soa.domain_email.should.equal "root.spec.com"
  end

  should 'return serial from SOA' do
    @domain.soa.domain_serial.should.equal "2006090501"
  end

  should 'return refresh from SOA' do
    @domain.soa.domain_refresh.should.equal "7200"
  end

  should 'return retry from SOA' do
    @domain.soa.domain_retry.should.equal "3600"
  end

  should 'return expiry from SOA' do
    @domain.soa.domain_expiry.should.equal "4800"
  end

  should 'return minimum from SOA' do
    @domain.soa.domain_minimum.should.equal "86400"
  end

  # master/slave/native accessors and validators
  doms = {}
  [ :master, :slave, :native ].each do |t|
    Domain.filter(:name => "#{t.to_s}.msnav.spec.com").destroy
    doms[t] = Domain.create(:name => "#{t.to_s}.msnav.spec.com", :type => "#{t}", :master => "1.2.3.4")

    should "upcase #{t} zone type" do
      doms[t].type.should == t.to_s.upcase
    end

    should "indicate a #{t} zone is a #{t} zone" do
      doms[t].send("#{t}?").should.be.true
    end

    [ :master, :slave, :native ].reject { |z| z == t }.each do |nein| 
      should "indicate a #{t} zone is a not a #{nein} zone" do
        doms[t].send("#{nein}?").should.be.false
      end
    end
    doms[t].destroy
  end

  # soa manipulations
  should 'save ns into SOA' do
    @domain.soa.domain_ns = "ns1.spec.com"
    @domain.soa.domain_ns.should.equal "ns1.spec.com"
    @domain.soa.save
    @soa.reload
    @soa.domain_ns.should.equal "ns1.spec.com"
  end

  should 'save email into SOA' do
    @domain.soa.domain_email= "hostmaster.spec.com"
    @domain.soa.domain_email.should.equal "hostmaster.spec.com"
    @domain.soa.save
    @soa.reload
    @soa.domain_email.should.equal "hostmaster.spec.com"
  end

  should 'save serial into SOA' do
    @domain.soa.domain_serial= "2012033101"
    @domain.soa.domain_serial.should.equal "2012033101"
    @domain.soa.save
    @soa.reload
    @soa.domain_serial.should.equal "2012033101"
  end

  should 'save refresh into SOA' do
    @domain.soa.domain_refresh= "11111"
    @domain.soa.domain_refresh.should.equal "11111"
    @domain.soa.save
    @soa.reload
    @soa.domain_refresh.should.equal "11111"
  end

  should 'save retry into SOA' do
    @domain.soa.domain_retry= "22222"
    @domain.soa.domain_retry.should.equal "22222"
    @domain.soa.save
    @soa.reload
    @soa.domain_retry.should.equal "22222"
  end

  should 'save expiry into SOA' do
    @domain.soa.domain_expiry = "33333"
    @domain.soa.domain_expiry.should.equal "33333"
    @domain.soa.save
    @soa.reload
    @soa.domain_expiry.should.equal "33333"
  end

  should 'save minimum into SOA' do
    @domain.soa.domain_minimum = "44444"
    @domain.soa.domain_minimum.should.equal "44444"
    @domain.soa.save
    @soa.reload
    @soa.domain_minimum.should.equal "44444"
  end

  # serial bumping specs
  should 'be able to bump an old serial' do
    @domain.soa.domain_serial = "%s01" % (Date.today-1).strftime("%Y%m%d")
    today = Date.today.strftime("%Y%m%d")
    @domain.soa.bump_serial
    @domain.soa.domain_serial.should == "%s01" % today
  end

  should "be able to bump today's serial" do
    today = Date.today.strftime("%Y%m%d")
    @domain.soa.domain_serial = "%s01" % today
    @domain.soa.bump_serial
    @domain.soa.domain_serial.should == "%s02" % today
  end

  should "top bumping serials if todays's count is 99" do
    today = Date.today.strftime("%Y%m%d")
    @domain.soa.domain_serial = "%s99" % today
    should.raise(RangeError) do
      @domain.soa.bump_serial
    end
  end

  # If the domain switches from slave to master, we have to remove master in it's row
  should 'remove master if it\'s not a slave' do
    Domain.filter(:name => 'rmiinas.example.org').destroy
    @dom = Domain.create(:name => 'rmiinas.example.org', :type => 'SLAVE',
                         :master => '64.85.172.162')

    @dom.master.should == '64.85.172.162'
    @dom.type.should == 'SLAVE'
    @dom.type = 'MASTER'
    @dom.save
    @dom.master.should.be.nil
    Domain.filter(:name => 'rmiinas.example.org').destroy
  end
end

