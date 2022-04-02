require "./spec_helper"

describe LuckySearch::Query do
  it "builds an elasticsearch query" do
    query_body = BasicQuery.search_query_build
    query_body.keys.should eq({:query, :filter, :offset, :limit, :sort})
  end

  describe "filters" do
    it "#should" do
      query = GoatQuery.search_query({"q" => "SCREAMS"})
      teeth = [1, 3, 5, 7, 11]

      query.should({"teeth" => teeth})
      filter_field = query.build[:filter].not_nil!

      expected = teeth.map { |t| ({:term => {"teeth" => t}}) }
      filter_field.dig(:filter, :bool, :should).should eq expected
    end

    it "#should string query" do
      query = GoatQuery.search_query("SCREAMS")
      teeth = [1, 3, 5, 7, 11]

      query.should({"teeth" => teeth})
      filter_field = query.build[:filter].not_nil!

      expected = teeth.map { |t| ({:term => {"teeth" => t}}) }
      filter_field.dig(:filter, :bool, :should).should eq expected
    end

    it "#must" do
      query = GoatQuery.search_query({"q" => "stands on mountain"})
      query.must({"name" => ["billy"]})
      filter_field = query.build[:filter].not_nil!

      filter_field.dig(:filter, :bool, :must).should eq [{:term => {"name" => "billy"}}]
    end

    it "#must_not" do
      query = GoatQuery.search_query({"q" => "makes good cheese"})
      query.must_not({"name" => ["gruff"]})
      filter_field = query.build[:filter].not_nil!

      filter_field.dig(:filter, :bool, :must_not).should eq [{:term => {"name" => "gruff"}}]
    end

    it "#range" do
      query = GoatQuery.search_query({"q" => "cheese time"})
      query.range({
        "teeth" => {
          :lte => 5,
        },
      })
      filter_field = query.build[:filter].not_nil!
      filter_field.dig(:filter, :bool, :filter).should contain({range: {"teeth" => {:lte => 5}}})
    end
  end
end
