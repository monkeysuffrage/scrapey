require 'scrapey'
require 'pry'

# some skeleton code that I like to start with
# require 'scrapey/multi' #=> requires em-http-request

# sample customizations...
# @agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'
# @output = Time.now.strftime("#{BASEDIR}/Output/output_%Y_%m_%d_%H_%M_%S.csv")

def scrape div
  a = div.at('a')
  url = URI.join(@url, a[:href]).to_s
  return unless visited? url
  item = {}
  
  save item  
  exit if defined? Ocra
rescue StandardError => e
  binding.pry
end

#use_cache :redis

fields 'name', 'address', 'zip'

@url = "http://www.example.com/"

page = get @url
scrape page.at('div')
