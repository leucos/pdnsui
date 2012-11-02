Sequel.migration do
  up do
    AUTH.create_table(:users) do
      primary_key :id

      String :email, :size => 255, :unique => true, :empty => false
      String :password_hash, :size => 255, :empty => false
      TrueClass :super_powers, :default => false
    end

    AUTH.create_table(:rights, :ignore_index_errors=>true) do
      primary_key :id

      foreign_key :user_id, :users

      String :ability, :size => 50, :empty => false, :index => true
      String :domain, :size => 255, :empty => false, :index => true
      TrueClass :allow, :empty => false
    end
  end

  down do
    AUTH.drop_table(:users, :schema_info)
    AUTH.drop_table(:rights, :schema_info)
  end
end
