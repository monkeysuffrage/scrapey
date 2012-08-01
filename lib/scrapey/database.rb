module Scrapey
  def check_db_config
    raise 'No database configured' unless @config['database']
  end

  def tables *args
    check_db_config
    missing_tables = false
    args.each do |arg|
      model = Object.const_set(arg, Class.new(ActiveRecord::Base) {})
      missing_tables = true unless model.table_exists?
    end
    schema = "#{BASEDIR}/src/schema.rb"
    require schema if missing_tables && File.exists?(schema)
  end

  def truncate *args
    check_db_config
    args.each do |arg|
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{Object.const_get(arg).table_name}")
    end
  end
end