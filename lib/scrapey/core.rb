
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