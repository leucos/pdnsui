class Domain < Sequel::Model
  one_to_many :records, :before_remove => :remove_records
  plugin :validation_helpers
  plugin :composition

  self.db = DB
  
  #TODO : implement multi-master for slaves; check http://doc.powerdns.com/slave.html
  #Since 2.9.21, PowerDNS supports multiple
  #masters. For the BIND backend, the native BIND configuration language
  #suffices to specify multiple masters, for SQL based backends, list all
  #master servers separated by commas in the 'master' field of the domains
  #table.
  #
  #
  def validate
    super
    # A domain must have a name and a type
    validates_presence [:name, :type]
    # A domain must be unique
    validates_unique :name
    # Type must be one of MASTER, SLAVE or NATIVE
    validates_includes ['MASTER', 'SLAVE', 'NATIVE'], :type, :message => 'is not a valid domain type'
    # If type is SLAVE, we must have a master
    validates_presence :master if type == 'SLAVE'
  end

  def after_initialize
    self.type.upcase! unless type.nil?
  end

  def before_destroy
    Record.filter(:domain_id => id).destroy
  end

  def before_save
    if self.type == 'MASTER' and not self.master.nil?
      self.master = nil
    end
    self.type.upcase!
  end

  def master?
    self.type == 'MASTER'
  end

  def slave?
    self.type == 'SLAVE'
  end

  def native?
    self.type == 'NATIVE'
  end

  composition :soa,
    :composer => proc { Record.filter(:domain_id => self.id, :type => 'SOA').first },
    :decomposer => proc { } # none needed (?)
end
