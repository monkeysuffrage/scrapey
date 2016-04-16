require 'scrapey'
require 'watir-webdriver'
require 'pry'
require "socksify"
require 'socksify/http'
require 'net/https' 

# Mechanize: call @agent.set_socks(addr, port) before using
# any of it's methods; it might be working in other cases,
# but I just didn't tried :)
class Mechanize::HTTP::Agent
public
  def set_socks addr, port
    set_http unless @http
    class << @http
      attr_accessor :socks_addr, :socks_port

      def http_class
        Net::HTTP.SOCKSProxy(socks_addr, socks_port)
      end
    end
    @http.socks_addr = addr
    @http.socks_port = port
    @http.open_timeout = 100 
    @http.read_timeout = 100
  end
end

at_exit do
  Process.kill 9, Process.pid
  @threads.each do |t| 
    Thread.kill t
    print 'k'
  end
end

use_cache

@failures = {}
@max_failures = 5
@max_threads = 50

if arg = ARGV.find{|x| x[/--retries=(\d+)/]}
  @max_failures = $1.to_i
  ARGV.delete arg
end

if arg = ARGV.find{|x| x[/--threads=(\d+)/]}
  @max_threads = $1.to_i
  ARGV.delete arg
end

@socks = false
if arg = ARGV.find{|x| x[/socks/]}
  @socks = true
  ARGV.delete arg
end


# File.open("#{BASEDIR}/config/urls.txt", 'w'){|f| f<< (0..100).map{|i| "http://www.example.com/id=#{i}"} * "\n"}
@queue ||= File.read("#{BASEDIR}/config/urls.txt").split(/[[:space:]]+/).reject{|url| is_cached?(url)}.shuffle

if arg = ARGV.find{|x| x[/nopattern/]}
  @queue.reject!{|x| x[/google|facebook|twitter|findthebest|linkedin|yellowpages|bizapedia|dandb|manta|indeed|hoovers|cortera|yelp|yellowpages|whitepages|angieslist/i]}
  ARGV.delete arg
end


if @socks
  @proxies = File.read("#{BASEDIR}/config/socks.txt").scan(/[\w.]+:\d+/).shuffle
else
  @proxies = File.read("#{BASEDIR}/config/proxies.txt").scan(/[\w.]+:\d+/).shuffle
end

if @pattern = ARGV[0]
  @queue = @queue.select{|x| x[/#{@pattern}/]}
end

# binding.pry

def response_ok? page, url = nil
  if $0[/get_emails/]
    return !page.body[/zscaler|captcha/i]
  end

  return false if page.body[/Welcome To Zscaler/]

  case url
    when /google.com\/search/
      return page.body[/ - Google Search/i]
    when /facebook/
      return page.body[/akamai/i] && !page.body[/Security Check Required/i]
    when /twitter/
      return page.body[/tweets/i]
    when /findthebest/
      return page.body[/findthebest/i] && !page.body[/Captcha/i]
    when /linkedin/
      return page.body[/linkedin/i] && !page.body[/Captcha/i]
    when /yellowpages/
      return page.body[/yellowpages/i] && !page.body[/Captcha|IP Address/i]
    when /bizapedia.com/
      return page.body[/bizapedia/i] && !page.body[/Captcha|IP Address/i]
    when /dandb.com/
      return page.body[/dandb/i] && !page.body[/Captcha/i]
    when /topdrz.com/
      return page.body[/topdrz/i] && !page.body[/Captcha/i]
    when /businessfinder\.[a-z]{2}\.com/
      return page.body[/DC.title/i]
    when /hipaaspace.com/
      return page.body[/Fax/i]
    when /manta.com/
      if page.body[/(Zscaler|Captcha|IP Address|distil_ident_block)/i]
        puts $1
        return false
      end
      return page.body[/UA-10299948/]
    when /indeed.com\/cmp.*$(?<!review)/
      return page.body[/indeed/i] && !page.body[/Captcha|IP Address/i]
    when /hoovers.com\/company-information/
      return page.body[/hoovers/i] && !page.body[/Captcha|IP Address/i]
    when /cortera.com/
      return page.body[/cortera/i] && !page.body[/Captcha|IP Address/i]
    when /yelp.com/
      return !!((page.title[/Yelp/i] && !page.title[/Captcha/i]) || page.body['yelp-biz-id'])
    when /yellowpages.com.au/
      return !!page.body['listing-name']
    when /whitepages.com\/business/
      return !!page.body['app-id=287734809']
    when /angieslist.com.*\d.htm/
      return !!page.title['Angies List']
    when /addresssearch/
      return page.body['g-plusone']



  end
  return false if page.body[/exceeded your daily request/]
  begin
    result = JSON.parse(page.body)['results'][0]
    return true if result['address_components'].find{|x|x['types'].include?('country')}['short_name'] == 'US'
  rescue
  end
  return !page.body[/zscaler|captcha/i]
  puts "no match: #{url}"
  page.body[/UA-10299948/i] && !page.body[/Authentication Required/i]
end

def clean str
  str.gsub(/[[:space:]]+/, ' ').strip
end

def check browser
  html = browser.html.to_s
  return true if html[/Pardon Our Interruption|Zscaler|captcha/i]
  return true if browser.html.length > 5000
  false
end

def download
  loop do
    Mechanize.start do |agent|
      agent.read_timeout = agent.open_timeout = agent.idle_timeout = 10000
      keep_alive = false
      agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
      ua = agent.user_agent = [
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
      ].sample

      return unless url = @queue.shift

      if is_cached?(url)
        puts 'skipping'
        next
      end
      unless proxy = @proxies.shift
        puts "no more proxies"
        exit
      end
      @proxies.push proxy
      host, port = proxy.split(':')
      if @socks
        agent.agent.set_socks host, port.to_i
      else
        agent.set_proxy host, port.to_i, 'user', 'pass'
      end
      begin
        agent.request_headers = {'Referer' => 'http://www.google.com/search'}
        page = nil
        if url[/manta/]
          html = `phantomjs --proxy=#{proxy} #{BASEDIR}/src/cookies.js #{url}`
          page = Mechanize::Page.new URI.parse(url), [], html, nil, Mechanize.new
        else
          page = agent.get url
        end

        unless response_ok?(page, url)
          # binding.pry if url[/manta/] && !page.body[/timed out|blocked|forbidden/i]
          if page.title
            puts page.title.strip
          else
            raise "no title for: #{url}"
          end
          raise 'str'
        end
        save_cache url, page.body

        @good += 1
        puts "- [#{@queue.length + @threads.select(&:alive?).length}/#{@proxies.length}] #{url}"
      rescue StandardError => e
        @failures[url] ||= 0
        @failures[url] += 1
        unless @failures[url] >= @max_failures 
          @queue.push(url) # unless e.message[/no title for/]
        end
        # binding.pry
        if e.message[/execurtion exeprrred/]
          print 'r'
        elsif e.message[/403/] && !@pattern
          if (rand * 3).to_i == 0
            @proxies -= [proxy]
            print '!'
          end
        else
          @proxies -= [proxy]
          print '!'
        end
        puts "! - #{@failures[url]} - #{e.message[0..99]}"

        agent.cookie_jar.clear!
      end
    end
  end

end

def run
  puts @queue.length
  @num_threads = [@max_threads, @queue.length].min
  puts "#{@proxies.length} proxies, #{@queue.length} urls, #{@num_threads} threads"

  @banned_for = []

  @threads = []
  @deficit = 0

  until @queue.empty? || @proxies.empty?
    @good = 0
    start_time = Time.now

    @proxies.shuffle!

    @num_threads.times do
      @threads << Thread.new { download }
    end
    @threads.each { |t| t.join }

  end
end
run

