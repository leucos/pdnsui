class Right < Sequel::Model
  many_to_one :user

  self.db = AUTH
end


