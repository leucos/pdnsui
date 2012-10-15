class Right < Sequel::Model
  plugin :schema
  many_to_one :user

  self.db = AUTH

  set_schema do
    primary_key :id

    foreign_key :user_id, :users

    varchar :ability, :empty => false, :index => true
    varchar :domain, :empty => false, :index => true
    boolean :allow, :empty => false
  end

  create_table unless table_exists?
end


