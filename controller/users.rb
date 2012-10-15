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
        Ramaze::Log.debug("OMG login failed")
        flash[:error] = "Erreur d'identifiant ou de mot de passe"
        redirect Users.r(:login)
      else
        flash[:success] = "Hello #{user.email}"
        redirect_referrer 
      end
    end

    # Automagicaly display view
  end

  def logout
    flash[:success] = "Déconnecté"
    user_logout
    session.resid!
    redirect MainController.r(:index)
  end

end
