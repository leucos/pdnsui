# encoding: UTF-8
#

class Users < Controller
  helper :user, :gravatar, :paginate

  trait :paginate => {
    :limit => 5,
  }

  before(:index, :logout) do
    redirect Users.r(:login) unless logged_in?
  end

  def index(id=nil)
    if !id
      @title = @subtitle = "User management"
      @users = paginate(User)
    end
  end

  def login
    @title = @subtitle = "Log in"

    redirect_referer if logged_in?
    
    if request.post?
      user_login(request.subset(:email, :password))

      if !logged_in?
        # Login failed
        Ramaze::Log.debug("Login failed")
        flash[:error] = "The username or password you entered is incorrect."
        redirect Users.r(:login)
      else
        redirect_referrer 
      end
    end

    # Automagicaly display view
  end

  def logout
    user_logout
    session.resid!
    redirect MainController.r(:index)
  end
end
