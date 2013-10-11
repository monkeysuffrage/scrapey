require 'httpclient'

# monkey patch to remove annoying httpclient warnings
class HTTPClient; def warn str; end; end

module Scrapey
  def multi_get_or_post method, all_urls, options = {}

    # some sensible defaults
    threads         = options[:threads]         || 20
    on_success      = options[:on_success]      || :on_success
    on_error        = options[:on_error]        || :on_error
    user_agent      = options[:user_agent]      || "Scrapey v#{Scrapey::VERSION} - #{Scrapey::URL}"
    proxy           = options[:proxy]           || nil
    timeout         = options[:timeout]         || 1000
    follow_redirect = options[:follow_redirect] || true

    @lock ||= Mutex.new

    @http_clients ||= threads.times.map do
      c = HTTPClient.new proxy, user_agent
      c.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
      c.receive_timeout =  timeout
      yield c if block_given?
      c
    end

    debug 'starting multi'

    all_urls.each_slice(threads) do |urls|
      urls.each_with_index.map do |url, i|
        Thread.new do
          begin
            response = @http_clients[i].send method, url, options[:query], options[:headers], :follow_redirect => follow_redirect
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