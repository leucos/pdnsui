#
# Controller for Domains
#
class Domains < MainController

  before_all do
    # Context helps the default layout highlighting the good entry in the navbar
    @context=:domains
  end

  def index
    @title = 'Domains'

    # Get params, filtering ou nil and turning them to symbol
    sb = request.params['sortby'].nil? ? :name : request.params['sortby'].to_sym
    od = request.params['order'].nil? ? :asc : request.params['order'].to_sym

    # Check that the symbol obtained is valid
    sb = :name unless [:type, :content, :ttl].include? sb
    od = :asc unless :desc == od

    if (:desc == od) then
      Ramaze::Log.info("Sorting by #{sb} desc")
      @domains = paginate(Domain.order(sb).reverse.all)
    else
      Ramaze::Log.info("Sorting by #{sb} asc")
      @domains = paginate(Domain.order(sb).all)
    end
  end

  def save
    # This method handles both new additions & updates
    # If domain_id is set, this is an update
    # Otherwise, it's a new domain
    id = request.params['domain_id']
    data = request.subset(:name, :type, :master)

    if !id.nil? and !id.empty?
      # Update
      @domain = Domain[id]

      # Let's check the id provided is valid
      if @domain.nil?
        flash[:error] = %q{Can not update this domain (I can't find it)}
        redirect_referrer
      end
      operation = "update"
    else
      # Create
      @domain = Domain.new
      operation = "create"
    end

    model_wrap(operation, data['name']) do
      @domain.update(data)
    end

    redirect_referrer
    # redirect Domains.r(:index, @domain.id)
  end

  def delete(id=nil)
    d = Domain[id]
    if id.nil?
      flash[:error] = "Ooops, you didn't ask me which domain you wanted"
      redirect Domains.r(:index)
    elsif d.nil?
      flash[:error] = "Sorry, the domain ID '%s' doesn\'t exist" % id
      redirect Domains.r(:index)
    else
      model_wrap("delete", d.name) do
        d.destroy
      end
    end
    redirect_referrer
  end

  def records(id=nil)
    @domain = Domain[id]
    if id.nil?
      flash[:error] = "Ooops, you didn't ask me which domain you wanted"
      redirect Domains.r(:index)
    elsif @domain.nil?
      flash[:error] = "Sorry, the domain id '%s' doesn't exist" % id
      redirect Domains.r(:index)
    end


    # Get params, filtering ou nil and turning them to symbol
    sb = request.params['sortby'].nil? ? :name : request.params['sortby'].to_sym
    od = request.params['order'].nil? ? :asc : request.params['order'].to_sym

    # Check that the symbol obtained is valid
    sb = :name unless [:type, :content, :ttl].include? sb
    od = :asc unless :desc == od

    if (:desc == od) then
      @records = paginate(@domain.records_dataset.order(sb).reverse)
    else
      @records = paginate(@domain.records_dataset.order(sb))
    end
  end

  def bump_serial(id=nil)
    d = Domain[id]
    if id.nil?
      flash[:error] = "Ooops, you didn't ask me which domain you wanted"
    elsif d.nil?
      flash[:error] = "Sorry, the domain ID '%s' doesn\'t exist" % id
    else
      begin
        d.soa.bump_serial
        d.soa.save
      rescue Exception => e
        flash[:error] = "Unable to bump SOA for %s : %s" % [ d.name, e.message ]
      else
        flash[:success] = "Serial for domain %s bumped to %s" % [ d.name, d.soa.domain_serial ]
      end
    end
    redirect_referrer
  end
end


