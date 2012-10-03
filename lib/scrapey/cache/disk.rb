module Scrapey

  def cache_filename url
    @config['cache_dir'] + "/" + Digest::MD5.hexdigest(url) + ".cache"
  end

  def is_cached? url
    File.exists? cache_filename(url)
  end

  def load_cache url
    filename = cache_filename url
    return nil unless File::exists?(filename)
    debug "Loading #{filename} from cache"
    begin
      Nokogiri::HTML Marshal.load(File.open(filename, "rb"){|f| f.read})
    rescue Exception => e
      puts e.message
    end
  end

  def save_cache url, doc, options = {}
    File.open(cache_filename(url), "wb") {|f| f << Marshal.dump(doc) }
  end
end