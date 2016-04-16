=begin
# ActiveRecord::SchemaDumper.dump ActiveRecord::Base.connection, File.open('schema.rb', 'w')
# put table schemas here. this will be included if the table is not found.
ActiveRecord::Schema.define do
  create_table "items", options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
    t.string   "string_field"
    t.text     "text_field"
    t.integer  "number_field"
    t.boolean  "boolean_field"
    t.float    "float_field"
    t.date     "created_at"
    t.datetime "created_on"
  end

  add_index "items", ["number_field"], :name => "number_field_idx", :unique => true
end
=end