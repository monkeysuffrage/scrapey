require 'scrapey'
require 'watir-webdriver'

use_cache

# File.open("#{BASEDIR}/config/urls.txt", 'w'){|f| f<< (0..100).map{|i| "http://www.example.com/id=#{i}"} * "\n"}
@queue = File.read("#{BASEDIR}/config/urls.txt").split("\n").reject{|url| is_cached?(url)}.shuffle
@proxies = File.read("#{BASEDIR}/config/proxies.txt").scan(/[\w.]+:\d+/)

@lock = Mutex.new

def response_ok? str
  str[/Lidnummer/] && !str[/IP address/i]
end

def clean str
  str.gsub(/[[:space:]]+/, ' ').strip
end

def download
  browser = nil
  @lock.synchronize do
    browser = Watir::Browser.new
  end
  loop do
    return unless url = @queue.shift

    if is_cached?(url)
      puts 'skipping'
      next
    end
    
    begin
      browser.goto url
      unless response_ok?(browser.html)
        raise 'str'
      end
      save_cache url, browser.html

      puts browser.html[EMAIL_REGEX]
    rescue StandardError => e
      puts e.message[0..99]
      @queue.push url
    end
  end

end

threads = []
@deficit = 0

until @queue.empty?
  @good = 0
  start_time = Time.now

  @proxies.shuffle!

  1.times do
    threads << Thread.new { download }
  end
  threads.each { |t| t.join }

end
