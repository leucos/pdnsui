#
# Controller for Domains
#
class Records < MainController

  def delete(id)
    r = Record[id]
    if r.nil?
      flash[:error] = "Sorry, the record ID '%s' doesn\'t exist" % id
    else
      # We never know, may me in the misslisecond someone deleted 
      # the record. Probably overkill though...
      model_wrap("delete", r.name) do
        r.destroy
      end
#      begin
#        r.destroy
#      rescue => e
#        Ramaze::Log.error(e) if Ramaze.options.mode == :live
#        flash[:error] = "Unable to delete record '%s'" % r.name
#        flash[:error]<< "Got error %s : %s" % [ e.wrapped_exception.error_number, e.to_s ]
#      else
#        flash[:success] = "Record '%s' deleted successfully" % r.name
#      end
      redirect_referrer
    end
  end

  # This method handles updates & inserts
  # If a record_id is passed, then an update will be done
  # otherwise, it will be a create
  # 
  def save
    id   = request.params['record_id']
    data = request.subset(:domain_id, :name, :content, :type)

    if !id.nil? and !id.empty?
      record = Record[id]

      # Let's check the id provided is valid
      if record.nil?
        flash[:error] = %q{Can not update this record (I can't find it)}
        redirect_referrer
      end

      operation = "update"
    else
      # Create
      record = Record.new
      operation = "create"
    end

    model_wrap(operation, data['name']) do
      record.update(data)
    end

    redirect Domains.r(:records, data['domain_id'])
  end
end
