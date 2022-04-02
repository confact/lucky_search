require "../spec_helper"

class BasicQuery < Basic::BaseQuery
  luckySearchQuery(Basic)
end

class GoatQuery < Goat::BaseQuery
  luckySearchQuery(Goat)
end

class ChildQuery < Child::BaseQuery
  luckySearchQuery(Child)
end
