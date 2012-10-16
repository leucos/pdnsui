namespace :db do
  task :load_config do
    RAMAZE_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    require(File.join(RAMAZE_ROOT, 'app'))
    Sequel.extension :migration
    Sequel.extension :schema_dumper
  end

  desc "Dumps the schema to db/schema.db"
  task :schemadump => :load_config do
    schema = DB.dump_schema_migration
    schema_file = File.open(File.join(RAMAZE_ROOT, 'db', 'schema.rb'), "w"){|f| f.write(schema)}
  end
  
  desc "Migrate the database through scripts in db/migrations and update db/schema.rb by invoking db:schema:dump. Target specific version with VERSION=x. Turn off output with VERBOSE=false."
  task :migrate => :load_config do
    Sequel::Migrator.apply(DB, File.join(RAMAZE_ROOT, 'db', 'migrations'))
    Rake::Task["db:schemadump"].invoke
  end

  namespace :migrate do
    desc  'Rollbacks the database one migration and re migrate up. If you want to rollback more than one step, define STEP=x. Target specific version with VERSION=x.'
    task :redo => :load_config do
      Rake::Task["db:rollback"].invoke
      Rake::Task["db:migrate"].invoke
      Rake::Task["db:schema:dump"].invoke
      Rake::Task["db:seed"].invoke
    end

    desc 'Runs the "up" for a given migration VERSION.'
    task :up => :load_config do
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      raise "VERSION is required" unless version
      puts "migrating up to version #{version}"
      Sequel::Migrator.apply(DB, File.join(RAMAZE_ROOT, 'db', 'migration'), version)
      Rake::Task["db:schema:dump"].invoke 
    end

    desc 'Runs the "down" for a given migration VERSION.'
    task :down => :load_config do
      step = ENV['STEP'] ? ENV['STEP'].to_i : 1
      current_version = Sequel::Migrator.get_current_migration_version(DB)
      down_version = current_version - step
      down_version = 0 if down_version < 0
      puts "migrating down to version #{down_version}"
      Sequel::Migrator.apply(DB, File.join(RAMAZE_ROOT, 'db', 'migration'), down_version)
      Rake::Task["db:schema:dump"].invoke
    end
  end

  desc 'Rolls the schema back to the previous version. Specify the number of steps with STEP=n'
  task :rollback => :load_config do
    Rake::Task["db:migrate:down"].invoke
  end

  desc 'Drops and recreates the database from db/schema.rb for the current environment.'
  task :reset => ['db:schema:drop', 'db:schema:load']

  desc 'Creates an admin user'
  task :seed => :load_config do
    User.create(:email => 'admin', :password => '1234', :super_powers => '1234')
  end
end
