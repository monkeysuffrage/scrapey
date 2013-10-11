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
    _retries = options.delete :retries
    _sleep = options.delete :sleep
    begin
      new_args = method, url
      unless options.empty? && args.empty? 
        new_args << options
        args.each{|arg| new_args << arg}
      end
      
      doc = load_cache(url) if @use_cache
      return doc if doc

      page = agent.send *new_args
      str = page.respond_to?('root') ? page.root.to_s : page.body
      save_cache(url, str) if @use_cache

      #exit if Object.const_defined? :Ocra
      page
    rescue Exception => e
      case
        when defined? on_error
          return on_error e, method, url, options, *args
        when _retries && _retries > 0
          puts "Error. Retries remaining: #{options[:retries]}"
          sleep _sleep if _sleep
          get_or_post method, url, options.merge({:retries => _retries - 1, :sleep => _sleep}), *args
        else raise e
      end
    end
  end

  def get *args; get_or_post 'get', *args; end
  def post *args; get_or_post 'post', *args; end
  def head *args; get_or_post 'head', *args; end
  def goto *args; get_or_post 'goto', *args; end
  def visit *args; get_or_post 'visit', *args; end

  def set_proxy *args
    @agent.set_proxy *args
  end

  def fields *args
    @fields = args
  end

  def save item
    unless @csv && !@csv.closed?
      @csv = CSV.open @output, 'w'
      @csv << @fields if @fields
    end
    case
      when item.is_a?(Array) then @csv << item
      when item.is_a?(Hash) || item.is_a?(CSV::Row)
        raise 'No fields defined!' unless @fields
        @csv << @fields.map{|f| item[f]}
      else raise "unsupported type: #{item.class}"
    end
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
end
