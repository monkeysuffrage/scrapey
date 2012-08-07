require 'em-http-request'

module Scrapey
  def multi_get_or_post method, all_urls, options = {}
    request_options = {:redirects => 10, :head => {"User-Agent" => "Scrapey v#{Scrapey::VERSION} - #{Scrapey::URL}"}.merge(options.delete(:head))}
    threads = options[:threads] || 20
    callback = options[:callback] || :save_cache
    all_urls.reject!{|url| is_cached? url} if @use_cache
    @lock = Mutex.new
    all_urls.each_slice(threads) do |urls|
      next unless urls.size > 0
      EventMachine.run do
        multi = EventMachine::MultiRequest.new
        urls.each_with_index do |url, i|
          multi.add i, EventMachine::HttpRequest.new(url, options).send(method, request_options)
        end
        multi.callback do
          (0...multi.requests.length).each do |i|				
            if multi.responses[:callback][i]
              @lock.synchronize do
                send callback, urls[i], multi.responses[:callback][i].response, multi.responses[:callback][i].response_header
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

  def multi_get *args; multi_get_or_post 'get', *args; end
  def multi_post *args; multi_get_or_post 'post', *args; end
  def multi_head *args; multi_get_or_post 'head', *args; end

end