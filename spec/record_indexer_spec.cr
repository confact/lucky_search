require "./spec_helper"

describe LuckySearch::RecordIndexer do
  it "get correct document name" do
    klass = Goat
    name = LuckySearch::RecordIndexer.document_name(klass)
    name.should eq("test_goats")
  end
end
