# require 'phantom_mechanize'

module Scrapey

  def self.init b
    eval "include Scrapey", b

    # some defaults that I like
    eval "@agent ||= Mechanize.new{|a| a.history.max_size = 10}", b
    eval "@agent.user_agent = 'Scrapey v#{Scrapey::VERSION} - #{Scrapey::URL}'", b
    eval "@agent.verify_mode = OpenSSL::SSL::VERIFY_NONE", b
  end


  def get_or_post method, url, options={}, *args
    agent = ['goto', 'visit'].include?(method) ? @browser : @agent
    begin
      new_args = method, url
      unless options.empty? && args.empty? 
        new_args << options
        args.each{|arg| new_args << arg}
      end
      
      key = method == 'post' ? url + options.to_s : url
      doc = load_cache(key) if @use_cache
      return doc if doc

      page = agent.send *new_args
      # str = page.respond_to?('root') ? page.root.to_s : page.body
      # save_cache(url, str) if @use_cache
      save_cache(key, page.body) if @use_cache

      #exit if Object.const_defined? :Ocra
      page
    rescue Exception => e
      puts e.message
      raise e
    end
  end

  def get *args; get_or_post 'get', *args; end
  def post *args; get_or_post 'post', *args; end
  def phget *args; get_or_post 'phget', *args; end

  def set_proxy *args
    @agent.set_proxy *args
  end

  def fields *args
    @fields = args
  end

  def save_images urls
    folder = "#{BASEDIR}/images"
    Dir.mkdir(folder) unless Dir.exists?(folder)
    names = []
    urls.each do |url|
      name = url[/[^\/]+$/]
      binding.pry unless name
      names << name
      fn = "#{folder}/#{name}"
      next if File.exists?(fn)
      file = @agent.get(url)
      File.open(fn, 'wb'){|f| f << file.body}
    end
    names
  end

  def save item, output = nil
    output ||= @output
    @csvs ||= {}
    unless @csvs[output]
      obj = {}
      begin
        fn = output.gsub(/(?<!csv)$/, '.csv')
        obj[:csv] = CSV.open fn, 'w'
      rescue Exception => e
        if e.is_a?(Errno::EACCES)
          puts "Unable to access #{fn} - is it locked?"
          exit
        else
          raise e
        end
      end
      obj[:fields] = output == @output && @fields && !@fields.empty? ? @fields : item.keys
      obj[:csv] << obj[:fields]
      @csvs[output] = obj
    end
    @csvs[output][:csv] << @csvs[output][:fields].map{|f| item[f]}
  end


  def visited? url
    @visited ||= []
    return true if @visited.include? url
    @visited << url
    false
  end

  def debug msg
    puts msg if @debug
  end

  def ts
    Time.now.to_i.to_s
  end

  def enqueue url
    @url_list ||= File.open("#{BASEDIR}/config/urls.txt", 'w')
    @url_list << url
    @url_list << "\n"
  end
end
