module Scrapey
  class Tee
    def initialize *targets
       @targets = targets
    end

    def write *args
      @targets.each {|t| t.write(*args); t.flush}
    end

    def flush *args
      @targets.each {|t| t.flush(*args)}
    end

    def close
      @targets.each(&:close)
    end
  end
end

