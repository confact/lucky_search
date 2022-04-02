require "../spec_helper"

# Spec models
####################################################################################################
class SaveBasic < Basic::SaveOperation
  include Searchable
end

class SaveGoat < Goat::SaveOperation
  include Searchable
end

class SaveChild < Child::SaveOperation
  include Searchable
end
