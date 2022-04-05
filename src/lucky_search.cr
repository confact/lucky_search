# TODO: Write documentation for `LuckySearch`
require "./lucky_search/**"
require "lucky_env"

module LuckySearch
  VERSION = "0.2.0"
end

macro add_lucky_search(model)
  class_getter(lucky_search_handler) { LuckySearch::SimpleQuery({{@type}}, {{ model }}).new({{model}}.name) }
  def self.search(q : String, params = {} of Symbol => String, filters = nil)
    query = lucky_search_handler.query(q, params, filters)
    lucky_search_handler.search(query)
  end
  def self.search(params = {} of Symbol => String, filters = nil) : NamedTuple(total: Int32, results: Array({{model}}))
    query = lucky_search_handler.query(params, filters)
    lucky_search_handler.search(query)
  end

  def self.search_query(q : String, params = {} of Symbol => String, filters = nil)
    lucky_search_handler.query(q, params, filters)
  end

  def self.search_query(params = {} of Symbol => String, filters = nil)
    lucky_search_handler.query(params, filters)
  end

  def self.search_empty_query
    lucky_search_handler.query
  end

  def self.search(query : LuckySearch::Query) : NamedTuple(total: Int32, results: Array({{model}}))
    lucky_search_handler.search(query)
  end

  def self.search_query_build
    lucky_search_handler.query.build
  end
end

macro lucky_search_reindex(model_klass)
  Log.info { "Reindexing #{{{model_klass}}}" }
  query_class = {{model_klass}}::BaseQuery

  query_class.new.each do |data|
    LuckySearch::RecordIndexer.index(data.class, data.id, data.search_data)
    Log.info {"Indexed #{data.id}"}
  end
end
