class GoatFactory < Avram::Factory
  def initialize
    name "Test goat #{sequence("test-goat")}"
    teeth 4
    job "test job"
  end
end
