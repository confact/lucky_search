require "./spec_helper"

describe LuckySearch::RecordIndexer do
  it "get correct document name" do
    klass = Goat
    name = LuckySearch::RecordIndexer.document_name(klass)
    name.should eq("test_goats")
  end

  it "index a document" do
    basic = BasicFactory.create
    LuckySearch::RecordIndexer.index(Basic, basic.id, basic.search_data)
    LuckySearch::Client.new.refresh("test_basics")
    result = LuckySearch::Client.new.get("test_basics", basic.id)
    result["_id"].should eq(basic.id.to_s)
    result["_source"].should eq(basic.search_data)
  end
end
