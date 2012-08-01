require 'em-http-request'

module Scrapey
  def multi_get all_urls, options = {}
    all_urls.reject!{|url| File.exists? cache_filename(url)} if @use_cache
    threads = options[:threads] || 20
    callback = options[:callback] || :save_cache
    @lock = Mutex.new
    all_urls.each_slice(threads) do |urls|
      next unless urls.size > 0
      EventMachine.run do
        multi = EventMachine::MultiRequest.new
        urls.each_with_index do |url, i|
          multi.add i, EventMachine::HttpRequest.new(url).get(:redirects => 10)
        end
        multi.callback do
          (0...multi.requests.length).each do |i|				
            if multi.responses[:callback][i]
              @lock.synchronize do
                send callback, urls[i], multi.responses[:callback][i].response
              end
            else
              puts "problem downloading #{urls[i]}!"
            end
          end
          EventMachine.stop
        end
      end
    end
  end
end