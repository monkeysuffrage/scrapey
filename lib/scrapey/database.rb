module Scrapey
  def tables *args
    args.each do |arg|
      Object.const_set(arg, Class.new(ActiveRecord::Base) {})
    end
  end

  def truncate *args
    args.each do |arg|
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{Object.const_get(arg).table_name}")
    end
  end
end