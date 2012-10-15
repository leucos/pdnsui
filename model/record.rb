class Record < Sequel::Model
  many_to_one :domain
  plugin :validation_helpers
  plugin :json_serializer
  plugin :composition

  self.db = DB

  # We can only have one SOA per domain
  # Also, we can not have exactly the same records
  def validate
    if type == 'SOA'
      validates_unique([:domain_id, :type]) 
    else
      validates_unique([:domain_id, :name, :type, :content])
    end
  end

  def before_save
    # We need to check that the domain is appended to the record's name
    if not self.name.end_with? self.domain.name
      self.name = self.name + '.' + self.domain.name
    end
    super
  end

  def bump_serial
    if type == 'SOA'
      today = Date.today.strftime("%Y%m%d")
      serie = self.domain_serial.gsub(/^#{today}/,'')

      case serie
      when "00".."98"
        # The serial's date is today, we have to increase last digits
        serial = "#{today}%02d" % (serie.to_i+1)
      when "99"
        raise RangeError, 'serial sequence is already maxed out for today'
      else
        # The serial's date is older than today, just create one
        serial = "#{today}01"
      end
      self.domain_serial = serial
    end
  end

  SOA_COLUMNS= [ :domain_ns, :domain_email, :domain_serial, :domain_refresh,
    :domain_retry, :domain_expiry, :domain_minimum ]

  SOA = Struct.new(*SOA_COLUMNS)
  SOA_COMPOSER = proc{SOA.new(*content.split)}
  SOA_DECOMPOSER = proc{self.content = SOA_COLUMNS.map{|c| send(c)}.join(' ')}
  SOA_COLUMNS.each do |c|
    define_method(c){soa.send(c)}
    e = :"#{c}="
    define_method(e){|v| soa.send(e, v)}
  end

  composition :soa,
      :composer => SOA_COMPOSER,
      :decomposer => SOA_DECOMPOSER

end
