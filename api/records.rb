# coding: utf-8

module PDNSui
  module API

    class Records < Ramaze::Controller
      helper :restify, :model_exception_wrapper
      map "/api/records"

      def create
        data = request.subset(:domain_id, :name, :type, :content, :ttl, :prio)
        name = request.params['name']
        api_model_wrap("create", name) do
          Record.create(data)
        end
      end

      def read(arg)
        api_model_wrap do
          get_record(:read, arg)
        end
      end

      def update(arg)
        data = request.subset(:domain_id, :name, :type, :content, :ttl, :prio)
        Ramaze::Log.info(data.inspect)

        api_model_wrap("update", data['name']) do
          rec = get_record(:update, arg)

          rec.update(data)
          rec.save
        end
      end

      def delete(arg)
        rec = get_record(:delete, arg)
        name = rec[:name] rescue nil
        api_model_wrap("delete", name) do
          rec.delete
        end
      end

      def search(*args)
        # Example searches : 
        # .../search/cname:www/@erasme => look for a cname containing 'www' in domain containing 'erasme'
        # .../search/ptr:210/@0.168.192.in-addr.arpa => look for an IP containing 210 in reverse zone for 192.168.0

        records = Record.where(:id != nil)
        domains = nil

        args.each do |a|
          case a 
          when /^@(.*)$/
            domains = Domain.where(:name.like("%#{$1}%")).select(:id)
          when /^\*(.*)$/i
            records = records.where(:type.ilike($1))
          when /^=(.*)$/i
            records = records.where(:content.ilike("%#{$1}%"))
          when /^:(.*)$/i
            records = records.where(:id => $1)
          else
            records = records.where(:name.ilike("%#{a}%"))
          end  
        end

        # Restrict to domains if we had one
        records = records.where(:domain_id => domains) if domains

        # Limit number of records returned
        records = records.limit(request.params['limit']) if request.params['limit']

        Ramaze::Log.debug("Got %s matching records" % records.count)
        records.all
        #eply!( records.all )
      end

      private

      def get_record(wat, id)
        #can?(wat, id) or raise PDNSui::API::InsufficientRightsError
        Record[id] #or raise PDNSui::API::InvalidObjectError
      end

    end
  end
end

Ramaze::Log.info "API Loaded"

