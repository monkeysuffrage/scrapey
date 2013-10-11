require 'scrapey'
require 'pry'

use_cache

# File.open("#{BASEDIR}/config/urls.txt", 'w'){|f| f<< (0..100).map{|i| "http://www.example.com/id=#{i}"} * "\n"}
@queue = File.read("#{BASEDIR}/config/urls.txt").split("\n").shuffle

def download agent
  while url = @queue.shift
    if is_cached? url
      puts 'skipping'
      next
    end
    page = agent.get url
    save_cache url, page.body
    puts url
  end
end

threads = []
5.times do
  threads << Thread.new { download Mechanize.new{|a| a.history.max_size, a.verify_mode = 10, OpenSSL::SSL::VERIFY_NONE}}
end

threads.each { |t| t.join }

binding.pry
