class User < Sequel::Model
  one_to_many :rights

  include BCrypt

  self.db = AUTH

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def can?(dowat, towho)
    return true if super_powers

    # TODO: check & cache !
  end

  # Convenience function for more good looking ruby
  def super_powers?
    super_powers
  end

  def self.authenticate(creds)
    Ramaze::Log.info("Login attempt for %s" % creds['email'] )

    if !creds['email'] or !creds['password']
      Ramaze::Log.info("Login failure : no credentials")
      return false
    end

    user = self[:email => creds['email']]

    if user.nil? 
      Ramaze::Log.info("Login failure : wrong password")
      return false
    end

    if user.password == creds['password']
      Ramaze::Log.info("Login success")
      return user
    end

  end

end
