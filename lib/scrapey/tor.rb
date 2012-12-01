require 'net/telnet'

module Scrapey
  def use_tor
    set_proxy('localhost', 8118)
  end

  def change_identity
    debug "changing identity..."
    localhost = Net::Telnet::new("Host" => "localhost", "Port" => "9051", "Timeout" => 10, "Prompt" => /250 OK\n/)
    localhost.cmd('AUTHENTICATE ""') {|c| raise "Cannot authenticate to Tor" unless "250 OK\n" == c}
    localhost.cmd('signal NEWNYM') {|c| raise "Cannot switch Tor to new route" unless "250 OK\n" == c}
    localhost.close
  end
end