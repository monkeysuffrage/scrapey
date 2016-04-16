require "base64"

class Proxy
  attr_reader :current
  BOOM = 'boom'

  def initialize agent = nil, options = {}
    @user_agents = [
      'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.76 Safari/537.36',
      'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.66 Safari/537.36',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/536.30.1 (KHTML, like Gecko) Version/6.0.5 Safari/536.30.1',
      'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:24.0) Gecko/20100101 Firefox/24.0',
      'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.69 Safari/537.36',
      'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:23.0) Gecko/20100101 Firefox/23.0',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.76 Safari/537.36',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.69 Safari/537.36',
      'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.76 Safari/537.36',
      'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; WOW64; Trident/6.0)'
    ]
    @agent = agent
    @min = options[:min] || 5
    @sleep = options[:sleep] || 60 * 60 # 1 hour
    @verbose = options[:verbose] || false
    @timeout = options[:timeout] || 30
    @round_time = options[:round_time] || 5 * 60 # 5 minutes
    @agent.open_timeout = @agent.read_timeout = @timeout
    proxies = options[:proxies] || []
    set_proxies proxies
  end

  def set_proxies proxies
    @proxies = proxies.select{|x| x[/:/]}.uniq{|x| x[/.*:/]}
    self.shuffle
  end

  def debug str
    puts str if @verbose
  end

  def shuffle
    @proxies = [BOOM] + (@proxies - [BOOM]).shuffle
    start_round
    self.rotate
  end

  def to_yaml
    @proxies.to_yaml
  end

  def start_round
    now = Time.now.to_i
    if @round_start
      sleep_time = @round_time - (now - @round_start)
      if sleep_time > 0
        puts "sleeping for #{sleep_time}"
        sleep sleep_time
      end
    end
    @round_start = Time.now.to_i
  end

  def get_more_proxies
    puts 'getting more proxies'
    proxies = Proxy::get_proxies
    set_proxies proxies
  end

  def rotate
    debug "rotating"
    @proxies.rotate!
    @user_agents.rotate!
    if @proxies.length < @min
      get_more_proxies
    end
    @current = @proxies.first
    if @current == BOOM
      start_round
      rotate
      return
    end

    host, port = @current.split ':'
    debug "setting proxy to #{host}:#{port}"
    @agent.set_proxy host, port.to_i
    debug "setting user_agent to #{@user_agents.first}"
    @agent.user_agent = @user_agents.first
  end

  def remove
    debug "--- removing #{@current}"
    @proxies.shift
    rotate
    debug @proxies.join(', ')
    debug @current
  end

  def pause
    time = @sleep / @proxies.length
    debug "sleeping for #{time}"
    sleep time
  end

  def length
    @proxies.length
  end



  def self.get_idcloak
    proxies = []
    ['http://www.idcloak.com/proxylist/free-proxy-servers-list.html'].each do |url|
      page = @agent.get url

      page.search('#sort td[7]').each do |td|
        port = td.text.strip
        host = td.at('+ td').text.strip
        proxies << "#{host}:#{port}"
      end

    end
    proxies
  end

  def self.get_proxynova
    proxies = []
    ['http://www.proxynova.com/proxy-server-list/'].each do |url|
      page = @agent.get url

      page.search('.row_proxy_ip').each do |span|
        str = span.text[/long2ip\((.*?)\)/, 1]
        next if str[/a-z/i]
        i = eval str
        host = Proxy::long2ip(i)
        port = span.parent.at('+ td').text.strip
        proxies << "#{host}:#{port}"
      end
    end
    proxies
  end

  def self.get_proxy_list
    proxies = []
    ['http://proxy-list.org/en/index.php',
    'http://proxy-list.org/en/index.php?sp=20',
    'http://proxy-list.org/en/index.php?sp=40',
    'http://proxy-list.org/en/index.php?sp=60',
    'http://proxy-list.org/en/index.php?sp=80',
    'http://proxy-list.org/en/index.php?sp=100',
    'http://proxy-list.org/en/index.php?sp=120'].each do |url|
      page = @agent.get url
      proxies += page.body.scan(/(?:\d+\.){3}\d+:\d+/)
    end
    proxies
  end

  def self.get_hidemyass
    proxies = []
    ['http://hidemyass.com/proxy-list/search-227752',
    'http://hidemyass.com/proxy-list/search-227752/2',
    'http://hidemyass.com/proxy-list/search-227752/3',
    'http://hidemyass.com/proxy-list/search-227752/4',
    'http://hidemyass.com/proxy-list/search-227752/5',
    'http://hidemyass.com/proxy-list/search-227752/6'].each do |url|
      page = @agent.get url
      page.search('*[style*="display:none"]').remove
      page.search(page.body.scan(/(\..*?)\{display:none\}/).flatten.join(', ')).remove
      page.search('style').remove
      proxies += page.search('td[2]').map{|x| x.text.strip}.zip(page.search('td[3]').map{|x| x.text.strip}).map{|h,p| "#{h}:#{p}"}[1..-1]
    end
    proxies
  end

  def self.get_cool_proxy
    proxies = []
    page = @agent.get 'http://www.cool-proxy.net/proxies/http_proxy_list/sort:score/direction:desc'
    page.search('tr')[1..-2].each do |tr|
      next unless tr.at('td[2]')
      host = Base64.decode64 tr.at('td[1]').text[/"(.*?)"/, 1]
      port = tr.at('td[2]').text
      proxies << [host, port].join(':')
    end

    while a = page.at('a[rel=next]')
      url = URI.join('http://www.freeproxylists.net/', a[:href]).to_s
      begin
        page = @agent.get url
      rescue
        return proxies
      end
      page.search('tr')[1..-2].each do |tr|
        next unless tr.at('td[2]')
        host = Base64.decode64 tr.at('td[1]').text[/"(.*?)"/, 1]
        port = tr.at('td[2]').text
        proxies << [host, port].join(':')
      end
    end

    proxies
  end


  def self.get_freeproxylists
    proxies = []

    @agent.follow_meta_refresh = true
    page = @agent.get 'http://www.freeproxylists.net/'

    page.body.scan(/IPDecode\("([^"]+)"\)<\/script><\/td><td align="center">(\d+)/).each do |row|
      proxies << [URI.decode(row[0]), row[1]].join(':')
    end

    while a = page.at('a[text()^=Next]')
      url = URI.join('http://www.freeproxylists.net/', a[:href]).to_s
      puts url
      page = @agent.get url
      page.body.scan(/IPDecode\("([^"]+)"\)<\/script><\/td><td align="center">(\d+)/).each do |row|
        proxies << [URI.decode(row[0]), row[1]].join(':')
      end
    end

    proxies
  end

def self.long2ip(long)
  ip = []
  4.times do |i|
    ip.push(long.to_i & 255)
    long = long.to_i >> 8
  end
  ip.join(".")
end

  def self.get_proxies provider = :all

    @agent ||= Mechanize.new{|a| a.history.max_size = 10}
    @agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'

    case provider
      when :proxy_list then return get_proxy_list
      when :hidemyass then return get_hidemyass
      when :freeproxylists then return get_freeproxylists
      when :cool_proxy then return get_cool_proxy
      when :proxynova then return get_proxynova
      when :idcloak then return get_idcloak
      when :all
        proxies = []
        [:proxy_list, :hidemyass, :freeproxylists, :cool_proxy, :proxynova, :idcloak].each do |key|
          puts key
          begin
            part = get_proxies(key)
          rescue Exception => e
            part = []
            puts e.message
          end
          puts part.length
          proxies += part
        end
        proxies
    end
  end
end

if ARGV.include?('-p')
  puts "refreshing proxies, please wait..."
  require "#{BASEDIR}/src/get_proxies.rb"
  puts "#{@config['proxies'].length} proxies found."
  puts "Hit [enter] to exit"
  $stdin.gets
  exit
end

def pget url, skip_ok = false
  raise 'no gaq' unless @gaq
  return nil unless url[/^http/]
  if @use_cache && is_cached?(url)
    return get(url)
  end
  @proxy.rotate
  begin
    page = get url
  rescue StandardError => e
    puts e.message
    @proxy.remove
    @agent.cookie_jar.clear!
    return pget(url)
  end

  case
    when page.respond_to?(:title) && page.title  && page.body[@gaq] && page.code == '200'
      return page
    else
      delete_cache url
      puts page.code
      @proxy.remove
      @agent.cookie_jar.clear!
      return pget(url)
  end
end

@config['proxies'] = File.read("#{BASEDIR}/config/proxies.txt").scan /[\w.]+:\d+/

puts "starting with #{@config['proxies'].length} proxies..."
@proxy = Proxy.new @agent, :proxies => @config['proxies'], :round_time => 60, :min => 0




# for testing
if __FILE__ == $0
  require 'mechanize'
  @agent = Mechanize.new
  proxy = Proxy.new @agent, :verbose => true, :min => 5
end