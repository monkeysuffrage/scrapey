require 'httpclient'

# monkey patch to remove annoying httpclient warnings
class HTTPClient; def warn str; end; end

module Scrapey
  def multi_get_or_post method, all_urls, options = {}
    all_urls.reject!{|url| is_cached? url} if @use_cache
    return unless all_urls.size > 0

    threads    = options[:threads]    || 20
    on_success = options[:on_success] || :on_success
    on_error   = options[:on_error]   || :on_error
    user_agent = options[:user_agent] || "Scrapey v#{Scrapey::VERSION} - #{Scrapey::URL}"
    proxy      = options[:proxy]      || nil
    timeout    = options[:timeout]    || 1000

    @lock ||= Mutex.new
    @http_clients ||= threads.times.map{HTTPClient.new(options[:proxies] ? options[:proxies].rotate!.first : proxy, user_agent).tap{|c| c.ssl_config.verify_mode, c.receive_timeout, c.ssl_config.verify_callback = OpenSSL::SSL::VERIFY_NONE, timeout, proc{true}}}

    debug 'starting multi'

    all_urls.each_slice(threads) do |urls|
      urls.each_with_index.map do |url, i|
        Thread.new do
          begin
            response = @http_clients[i].send method, url, options[:query], options[:headers]
          rescue Exception => e
            error = e
          end
          @lock.synchronize do
            if response
              send on_success, url, response
            else
              send on_error, url, e
            end
          end
        end
      end.each{|thread| thread.join}
    end
  end

  def multi_get *args; multi_get_or_post 'get_content', *args; end
  def multi_post *args; multi_get_or_post 'post_content', *args; end
  def multi_head *args; multi_get_or_post 'head', *args; end

end