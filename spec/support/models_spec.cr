require "../spec_helper"

# Spec models
####################################################################################################
class Basic < BaseModel
  table do
    column name : String
  end

  def search_data
    {name: name}
  end
end

class Goat < BaseModel
  table do
    column name : String
    column teeth : Int32 = 0
    column job : String = "being a goat"
  end

  def search_data
    {
      name:  name,
      teeth: teeth,
      job:   job,
    }
  end
end

class Child < BaseModel
  table do
    column age : Int32 = 0
    column hoof_treatment : String = "oatmeal scrub"
    column visits : Array(String) = [] of String
    belongs_to goat : Goat
  end

  def search_data
    {
      age:            age,
      hoof_treatment: hoof_treatment,
      visits:         visits,
      goat:           goat.name,
    }
  end
end
