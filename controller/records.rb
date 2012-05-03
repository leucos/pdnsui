#
# Controller for Domains
#
class Records < MainController

  def delete(id=nil)
    r = Record[id]
    if id.nil?
      flash[:error] = "Ooops, you didn't ask me which record you wanted"
    elsif r.nil?
      flash[:error] = "Sorry, the record ID '%s' doesn\'t exist" % id
    else
      model_wrap("delete", r.name) do
        r.destroy
      end
    end
    redirect_referrer
  end

  # This method handles updates & inserts
  # If a record_id is passed, then an update will be done
  # otherwise, it will be a create
  # 
  def save
    id   = request.params['record_id']
    data = request.subset(:domain_id, :name, :content, :type, :ttl, :prio)

    if !id.nil? and !id.empty?
      record = Record[id]

      # Let's check the id provided is valid
      if record.nil?
        flash[:error] = %q{Can not update this record (I can't find it)}
        redirect_referrer
      end


      data['name'] = data['name'] + '.' + Domain[data['domain_id']].name
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
