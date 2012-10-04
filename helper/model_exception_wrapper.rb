#
# ModelException helper wrap model write calls (e.g. Model#save) and does all
# the logic of exception handling
#
# It currently handles the following exceptions : 
#
# - Sequel::ValidationFailed : occurs when model validation in sequel failed 
# - Sequel::Error : occurs when Sequel can not update/insert/delete a record (usually because of internal
# database constraints)
# - Sequel::DatabaseError : occurs when the database backend returned an error
# - Exception (generic handler)
#
# This helper will set flash[:error] accordingly, and will try to use sensible defaults.
# If no exception is raised during th database transaction, flash[:success] will be set.
#
# All exceptions but Sequel::ValidationFailed will be logged in Ramaze in :live mode

module Ramaze
  module Helper
    module ModelExceptionWrapper

      # Wraps a model's write operation and handles any exception that rises
      #
      # @param [String] operation The operation "name" that the block is supposed to achieve
      #   This is only used for user feedback
      # @param [String] value The value of the field that the block is supposed to act on
      #   This is only used for user feedback
      # @param [Block] block The model operation itself
      #
      # @returns [Boolean] a boolean indication success (true) or failure (false)
      # A string representing the object in a specified
      # format.
      #
      def model_wrap(operation="operate on", name="", &block)
        Ramaze::Log.info("in model wrap")
        Ramaze::Log.info(action.inspect)
        begin
          yield

          # Handle validation errors
        rescue Sequel::ValidationFailed => e
          flash[:error] = "Invalid data : %s" % e.message
          redirect_referrer

          # Handle Sequel errors (internal contraints mostly)
        rescue Sequel::Error => e
          Ramaze::Log.error(e) if Ramaze.options.mode == :live
          flash[:error] = "Unable to %s : %s" % [ operation, e.message ]
          redirect_referrer

          # Handle database backend errors
        rescue Sequel::DatabaseError => e
          Ramaze::Log.error(e) if Ramaze.options.mode == :live

          if e.respond_to? wrapped_exception and e.wrapped_exception.error_number == 1062
            flash[:error] = "Entry '%s' already exists." % name
          else
            flash[:error] = "Unable to %s %s." % [ operation, name ]
            flash[:error]<< "Got error %s : %s" % [ e.wrapped_exception.error_number, e.message ]
          end
          redirect_referrer

          # Handle other exceptions
        rescue Exception => e
          Ramaze::Log.error(e) if Ramaze.options.mode == :live

          flash[:error] = "Unable to %s %s : %s" % [ operation, name, e.message ]
          redirect_referrer

        else
          flash[:success] = "Entry %s %sd successfully" % [ name, operation ]
        end

      end

      private

      def set_error(message)
        Ramaze::Log.info(node.inspect)
        flash[:error] = message
      end
    end
  end
end
