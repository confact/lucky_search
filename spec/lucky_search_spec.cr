require "./spec_helper"

describe LuckySearch::SimpleQuery do
  describe "#search" do
    it "performs a generic search" do
      query = BasicQuery.lucky_search_handler.query
      records = BasicQuery.search(query)
      records[:total].should eq 1
      records[:results].size.should eq 1
    end

    # it "accepts a format block" do
    #  query = BasicQuery.search.query
    #  updated_name = "Ugg"
    #  records = BasicQuery.search.search(query) do |r|
    #    r.name = updated_name
    #    r
    #  end

    #  records[:total].should eq 1
    #  records[:results].size.should eq 1
    #  records[:results][0].name.should eq updated_name
    # end

    it "#must_not on a embedded document" do
      elastic = ChildQuery.lucky_search_handler
      query = elastic.query
      query.must_not({"visits" => ["monthly"]})

      records = elastic.search(query)
      records[:total].should eq 0
    end

    it "#must_not on a embedded document" do
      elastic = ChildQuery.lucky_search_handler
      query = elastic.query
      query.must({"visits" => ["monthly", "yearly"]})

      records = elastic.search(query)
      records[:total].should eq 1
    end
  end
end
