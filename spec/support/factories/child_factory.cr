class ChildFactory < Avram::Factory
  def initialize
    hoof_treatment "Test treatment #{sequence("test-hoof")}"
    age 1
    visits "test"
    goat_id GoatFactory.create.id
  end
end
