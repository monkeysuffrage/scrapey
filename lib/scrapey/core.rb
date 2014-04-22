require 'addressable/uri'

class URI::Parser
  def split url
    a = Addressable::URI::parse url
    [a.scheme, a.userinfo, a.host, a.port, nil, a.path, nil, a.query, a.fragment]
  end
end

class Hash
  def shuffle
    Hash[self.to_a.shuffle]
  end
end

class Nokogiri::XML::NodeSet
  def shuffle
    self.to_a.shuffle
  end
end

class Enumerator
  def shuffle
    self.to_a.shuffle
  end
end

class CSV::Table
  def shuffle
    arr = self.to_a
    k = arr.shift
    arr.map{|v| Hash[k.zip v]}.shuffle
  end
end