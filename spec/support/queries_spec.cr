require "../spec_helper"

class BasicQuery < Basic::BaseQuery
  include LuckySearch
end

class GoatQuery < Goat::BaseQuery
  include LuckySearch
end

class ChildQuery < Child::BaseQuery
  include LuckySearch
end
