# Helper de génération du menu de gauche.
module Ramaze
  module Helper
    module Restify

      class NonExistentRecordError < StandardError
        attr_reader :id

        def initialize(id)
          Ramaze::Log.info("id : %s" % id)
          @id = id
        end
      end

      # Expose helper methods as actions
      Ramaze::Helper::EXPOSE << self

      def self.included(c)
        c.class_eval {
          # Let's do nothing if we have a provide already
          if !provides.include?("api_handler")
            Ramaze::Log.info("Restify: adding .api handler to #{c.to_s} controller")

            provide(:api, :type => 'application/json') do |action, value|
              layout nil
              value.to_json
            end
          else
            Ramaze::Log.warn("Restify: .api handler in controller #{c.to_s} already exists!")            
          end

          # Define stub methods
          # These methods should be overriden in the controller to be REST compliant
          [[:create, "POST"], [:read, "GET"], [:update, "PUT"], [:delete, "DELETE"]].each do |m|
            define_method(m[0]) { |*arg|
              Ramaze::Log.warn("Restify: stub method #{c.to_s}##{m[0]} invoked for REST method #{m[1]}")
            }
          end
        }

        # Add a before_all pour auth via key ?
      end

      def index(*args)
        Ramaze::Log.debug("Restify: Got request #{request.env["REQUEST_METHOD"]}")
        case request.env["REQUEST_METHOD"]
        when "POST"
          Ramaze::Log.debug "Restify: Calling create"
          create

        when "GET"
          Ramaze::Log.debug "Restify: Calling read"
          read(args.first)

        when "PUT"
          Ramaze::Log.debug "Restify: Calling update"
          update(args.first)

        when "DELETE"
          Ramaze::Log.debug "Restify: Calling delete"          
          delete(args.first)

        else
          Ramaze::Log.error "Restify: No match for method #{request.env["REQUEST_METHOD"]}."

          reply!( { :message => "unknown method #{request.env["REQUEST_METHOD"]}. Please check RFC 2616." }, 405 )

        end          
      end

      private

      def reply!(body, status=200)
        respond!(body.to_json, status, 'Content-Type' => 'application/json')  
      end

      def api_model_wrap(operation=nil, name=nil, &block)
        mode = :web
        mode = :api if action.node.to_s =~ /::API::/

        Ramaze::Log.info("API model wrap in %s mode (node is %s)" % [ mode, action.node ])

        begin
          result = yield

        rescue Ramaze::Helper::Restify::NonExistentRecordError => e
          Ramaze::Log.info e.inspect
          set_error("Invalid record : %s" % e.id, mode) 
          redirect_referrer # never happens if :api

        # Handle validation errors
        rescue Sequel::ValidationFailed => e
          set_error("Invalid data : %s" % e.message, mode) 
          redirect_referrer # never happens if :api

        # Handle Sequel errors (internal contraints mostly)
        rescue Sequel::Error => e
          Ramaze::Log.error(e) if Ramaze.options.mode == :live
          set_error("Unable to %s : %s" % [ operation, e.message ], mode)
          redirect_referrer

        # Handle database backend errors
        rescue Sequel::DatabaseError => e
          Ramaze::Log.error(e) if Ramaze.options.mode == :live

          if e.respond_to? wrapped_exception and e.wrapped_exception.error_number == 1062
            set_error("Entry '%s' already exists." % name, mode)
          else
            set_error("Unable to %s %s." % [ operation, name ], mode)
            set_error("Got error %s : %s" % [ e.wrapped_exception.error_number, e.message ], mode)
          end
          redirect_referrer

        # Handle other exceptions
        rescue Exception => e
          Ramaze::Log.error(e) if Ramaze.options.mode == :live

          set_error("Unable to %s %s : %s" % [ operation, name, e.message ], mode)
          redirect_referrer

        else
          flash[:success] = "Entry %s %sd successfully" % [ name, operation ] if mode == :web and operation
        end

        result
      end

      def set_error(message, mode = :api)
        Ramaze::Log.debug("Ramaze::Helper::Restify#set_error called")
        reply!({ :message => message }) if mode == :api
        flash[:error] = message
      end

    end
  end
end
