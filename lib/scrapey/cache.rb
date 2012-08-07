module Scrapey
  def use_cache
    @use_cache = true
    @config['cache_dir'] ||= "#{BASEDIR}/cache"
    FileUtils.mkdir_p @config['cache_dir']
  end

  def cache_filename url
    @config['cache_dir'] + "/" + Digest::MD5.hexdigest(url) + ".cache"
  end

  def load_cache url
    filename = cache_filename url
    return nil unless File::exists?(filename)
    puts "Loading #{filename} from cache"
    str = File.read(filename)
    puts str.encoding
    Nokogiri::HTML File.read(filename), :encoding => str.encoding
  end

  def save_cache url, doc, options = {}
    encoding = options[:encoding] || 'UTF-8'
    #binding.pry
    File.open(cache_filename(url), "w:#{encoding}") {|f| f.write(doc.force_encoding(encoding)) }
  end
end