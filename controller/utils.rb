require 'whois'
require 'dnsruby'
require 'json'

class Utils < MainController

  # For this to work, the user running the application
  # must be in the pdns group
  def notify_slaves
    flash[:info] = 'This is not implemented yet :('
    redirect_referrer
  end

  def configure
    flash[:info] = 'This is not implemented yet :('
    redirect_referrer
  end

  def get_record(domain, type, server="8.8.8.8")
    type= Dnsruby::Types.const_get type
    res = Dnsruby::Resolver.new
    ret = res.query(domain, type)
    ret.answer.to_json
  end

  def whois(domain=nil)
    result = {}

    return result.to_json if domain.nil?

    begin
      r = Whois.query(domain)
    rescue Exception
      puts "\tUnable to find whois info for %s" % domain
    else
      p = r.parser

      [:status, :created_on, :updated_on, :expires_on, :registrar, :registrant, :admin, :technical].each do |type|
        begin
          result[type] = p.send(type)
          puts p.send(type)
        rescue Exception
        end
      end

      result[:nameservers] = []

      p.nameservers.each do |n|
        result[:nameservers] << n.name
      end
    end

    result.to_json
  end

end
