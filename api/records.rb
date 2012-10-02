# coding: utf-8

module PDNSui
  module API
    class Records < Ramaze::Controller
      helper :restify
      map "/api/records"

      def search(*args)

        # Example searches : 
        # .../search/cname:www/@erasme => look for a cname containing 'www' in domain containing 'erasme'
        # .../search/ptr:210/@0.168.192.in-addr.arpa => look for an IP containing 210 in reverse zone for 192.168.0

        Ramaze::Log.info args.inspect

        records = Record.where(:id != nil)
        domains = nil

        args.each do |a|
          case a 
          when /^@(.*)$/
            domains = Domain.where(:name.like("%#{$1}%")).select(:id)
          when /(.*):(.*)$/i
            records = records.where(:type.ilike($1)).where(:name.ilike("%#{$2}%"))
          when /=(.*)$/i
            records = records.where(:content.ilike("%#{$1}%"))
          else
            records = records.where(:name.ilike("%#{a}%"))
          end  
        end

        # Restrict to domains if we had one
        records = records.where(:domain_id => domains) if domains

        # Limit number of records returned
        records = records.limit(request.params['limit']) if request.params['limit']

        Ramaze::Log.info records.inspect

        reply!( records.all )
      end
    end
  end
end

Ramaze::Log.info "API Loaded"

