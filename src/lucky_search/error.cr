class LuckySearch::Error < Exception
  getter message

  def initialize(@message : String? = "")
    super(message)
  end

  class MalformedQuery < Error
  end

  class ElasticQueryError < Error
  end
end
