class MainController < Controller
  helper :user
  
  # the index action is called automatically when no other action is specified
  def index
    @title = 'Ramaze PowerDNS Interface'
    redirect Domains.route
  end
end

