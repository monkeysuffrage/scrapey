require 'scrapey'
require 'pry'

# sample customizations...
@agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5'
# @output = Time.now.strftime("#{BASEDIR}/Output/output_%Y_%m_%d_%H_%M_%S.csv")
@output = "template.csv"


def clean str
  str.gsub(/[[:space:]]+/, ' ').strip
end

def scrape div
  a = div.at('a')
  url = URI.join(@url, a[:href]).to_s
  return if visited? url
  item = {}
  
  save item  
  exit if defined? Ocra
rescue StandardError => e
  puts e.message, e.backtrace
  binding.pry
end


# fields 'name', 'address', 'zip'

@url = "http://www.example.com/"

use_cache

page = get @url
binding.pry


#@csv.close
#%x{call #{@output}}
