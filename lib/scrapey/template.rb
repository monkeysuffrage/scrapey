require 'fileutils'

module Scrapey
  module Template
    def self.generate name, *args
      puts "creating new scrapey project: #{name}..."
      template = File.expand_path('../../../template', __FILE__)
      FileUtils.cp_r template, name
      Dir.chdir name
      Dir.glob(['*/*.*', '*.*']).grep(/template/).each do |fn|
        FileUtils.mv fn, fn.gsub('template', name)
      end

    end
  end
end