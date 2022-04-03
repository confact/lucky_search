class BasicFactory < Avram::Factory
  def initialize
    name "Test basic #{sequence("test-basic")}"
  end
end
