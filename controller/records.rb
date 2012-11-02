#
# Controller for Domains
#
class Records < MainController

  def initialize
    super
    @api = PDNSui::API::Records.new
  end

  def index(arg)
    redirect_referrer unless @record = @api.read(arg)

    @domain = @record.domain
  end

  def delete(id)
    @api.delete(id)

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
      @api.update(id)
    else
      @api.create
    end

    redirect Domains.r(:records, data['domain_id'])

  end
end
