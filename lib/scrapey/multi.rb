require 'em-http-request'

module Scrapey
  def multi_get_or_post method, all_urls, options = {}
    head = options.delete(:head) || {}
    request_options = {:redirects => 10, :head => {"User-Agent" => "Scrapey v#{Scrapey::VERSION} - #{Scrapey::URL}"}.merge(head)}
    threads = options[:threads] || 20
    on_success = options[:on_success] || :on_success
    on_error = options[:on_error] || :on_error
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
                if defined? on_success
                  send on_success, urls[i], multi.responses[:callback][i].response, multi.responses[:callback][i].response_header
                else
                  raise "#{on_success} not defined!"
                end
              end
            else
              if defined? on_error
                send on_error, urls[i], multi.requests[i].error
              else
                raise "#{on_error} not defined!"
              end
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