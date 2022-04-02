# TODO: Write documentation for `LuckySearch`
require "./lucky_search/**"
require "lucky_env"

module LuckySearch
  VERSION = "0.1.0"

  macro included
  {% if @type.abstract? %}
    macro inherited
      macro finished
          __generate_accessor
      end
    end
    {% else %}
    macro finished
        __generate_accessor
    end
  {% end %}
  end

  private macro __generate_accessor
    class_getter(lucky_search_handler) { LuckySearch::SimpleQuery({{@type}}).new(self.new.table_name) }
    def self.search(q : String, params = {} of Symbol => String, filters = nil)
      query = lucky_search_handler.query(q, params, filters)
      lucky_search_handler.search(query)
    end
    def self.search(params = {} of Symbol => String, filters = nil)
      query = lucky_search_handler.query(params, filters)
      lucky_search_handler.search(query)
    end

    def self.search_query(q : String, params = {} of Symbol => String, filters = nil)
      lucky_search_handler.query(q, params, filters)
    end

    def self.search_query(params = {} of Symbol => String, filters = nil)
      lucky_search_handler.query(params, filters)
    end

    def self.search(query : LuckySearch::Query)
      lucky_search_handler.search(query)
    end

    def self.search_query_build
      lucky_search_handler.query.build
    end
  end
end
