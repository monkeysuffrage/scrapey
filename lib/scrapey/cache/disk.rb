require 'fileutils'

module Scrapey

  def cache_filename url
    @config['cache_dir'] + "/" + Digest::MD5.hexdigest(url).sub(/(.)(.)/, '\1/\2/\1\2') + ".cache"
  end

  def is_cached? url
    File.exists? cache_filename(url)
  end

=begin
  def load_cache url
    filename = cache_filename url
    return nil unless File::exists?(filename)
    debug "Loading #{filename} from cache"
    begin
      Mechanize::Page.new URI.parse(url), [], Marshal.load(File.open(filename, "rb"){|f| f.read}), nil, @agent
    rescue Exception => e
      puts e.message
    end
  end

  def save_cache url, doc, options = {}
    File.open(cache_filename(url), "wb") {|f| f << Marshal.dump(doc) }
  end
=end

  def load_cache url
    filename = cache_filename url
    return nil unless File::exists?(filename)
    debug "Loading #{filename} from cache"
    begin
      Mechanize::Page.new URI.parse(url), [], Marshal.load(Zlib::Inflate.inflate(File.open(filename, "rb"){|f| f.read})), nil, @agent
    rescue Exception => e
      puts e.message
      # delete_cache url
      # Mechanize::Page.new URI.parse(url), [], '<html></html>', nil, @agent
    end
  end

  def save_cache url, doc, options = {}
    File.open(cache_filename(url), "wb") {|f| f << Zlib::Deflate.deflate(Marshal.dump(doc)) }
  end


  def delete_cache url
    FileUtils.rm(cache_filename(url)) rescue nil
  end

end
