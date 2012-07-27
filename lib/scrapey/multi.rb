require 'em-http-request'

module Scrapey
  def multi_get all_urls, options
    threads = options[:threads] || 20
    callback = options[:callback] || :save_cache
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
              send callback, urls[i], multi.responses[:callback][i].response
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