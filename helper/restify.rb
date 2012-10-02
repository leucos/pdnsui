# Helper de génération du menu de gauche.
module Ramaze
  module Helper
    module Restify

      # Expose helper methods as actions
      Ramaze::Helper::EXPOSE << self

      def index(*args)
        Ramaze::Log.info("Got request #{request.env["REQUEST_METHOD"]}")
        case request.env["REQUEST_METHOD"]
        when "POST"
          Ramaze::Log.info "Calling create"
          create
        when "GET"
          Ramaze::Log.info "Calling read"
          read(args.first)
        when "PUT"
          Ramaze::Log.info "Calling read"
          update(args.first)
        when "DELETE"
          Ramaze::Log.info "Calling delete"          
          delete(args.first)
        else
          Ramaze::Log.error "No match for method #{request.env["REQUEST_METHOD"]}."

          reply!(:error   => "unknown method", 
                 :message => "unknown method #{request.env["REQUEST_METHOD"]}. Please check RFC 2616.")
        end          
      end

      private

      def reply!(body)
        respond!(body.to_json, 200, 'Content-Type' => 'application/json')  
      end

    end
  end
end
