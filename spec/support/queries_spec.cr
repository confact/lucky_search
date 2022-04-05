require "../spec_helper"

class BasicQuery < Basic::BaseQuery
  add_lucky_search(Basic)
end

class GoatQuery < Goat::BaseQuery
  add_lucky_search(Goat)
end

class ChildQuery < Child::BaseQuery
  add_lucky_search(Child)
end
