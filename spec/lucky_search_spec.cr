require "./spec_helper"

describe LuckySearch::SimpleQuery do
  before_each do
    LuckySearch::Client.new.delete_index("test_basics")
    LuckySearch::Client.new.delete_index("test_children")
    LuckySearch::Client.new.empty_indices
  end

  describe "#search" do
    it "performs a generic search" do
      # LuckySearch::RecordIndexer.new("test_basics").create_index
      basic = BasicFactory.create
      basic = SaveBasic.update!(basic, name: "test basic wuut")
      indexed = LuckySearch::RecordIndexer.index(Basic, basic.id, basic.search_data)
      indexed["_id"].should eq(basic.id.to_s)
      LuckySearch::Client.new.refresh("test_basics")
      records = BasicQuery.search("test")
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
      # LuckySearch::RecordIndexer.new("test_children").create_index
      child = ChildFactory.create
      child = SaveChild.update!(child, visits: "monthly")
      LuckySearch::Client.new.refresh("test_children")
      query = ChildQuery.search_empty_query
      query.must_not({"visits" => ["monthly"]})

      records = ChildQuery.search(query)
      records[:total].should eq 0
    end

    it "#should on a embedded document" do
      # LuckySearch::RecordIndexer.new("test_children").create_index
      child = ChildFactory.create
      child = SaveChild.update!(child, visits: "monthly")
      LuckySearch::Client.new.refresh("test_children")
      query = ChildQuery.search_empty_query
      query.should({"visits" => ["monthly", "yearly"]})

      records = ChildQuery.search(query)
      records[:total].should eq 1
    end
  end
end
