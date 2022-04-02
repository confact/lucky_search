module LuckySearch
  class Schema
    getter language = "English"

    def self.generate_schema(search_data)
      mappings = generate_field_type(search_data)

      return {
        "settings" => {
          "number_of_shards"   => 1,
          "number_of_replicas" => 1,
          "analysis"           => analysis,
        },
        "mappings" => {
          "properties" => mappings,
        },
      }
    end

    def self.generate_field_type(search_data)
      new_data = {} of String => Hash(String, String)
      search_data.each do |key, value|
        new_data[key] = {
          "type" => field_type(value),
        }
      end
      new_data
    end

    def self.field_type(value)
      case value
      when String
        "text"
      when Int
        "integer"
      when Float
        "float"
      when Time
        "date"
      when Bool
        "boolean"
      else
        "text"
      end
    end

    # analysis from searchkick
    def analysis
      {
        analyzer: {
          searchkick_keyword: {
            type:      "custom",
            tokenizer: "keyword",
            filter:    ["lowercase"],
          },
          default_analyzer: {
            type: "custom",
            # character filters -> tokenizer -> token filters
            # https://www.elastic.co/guide/en/elasticsearch/guide/current/analysis-intro.html
            char_filter: ["ampersand"],
            tokenizer:   "standard",
            # synonym should come last, after stemming and shingle
            # shingle must come before searchkick_stemmer
            filter: ["lowercase", "asciifolding", "searchkick_index_shingle", "searchkick_stemmer"],
          },
          searchkick_search: {
            type:        "custom",
            char_filter: ["ampersand"],
            tokenizer:   "standard",
            filter:      ["lowercase", "asciifolding", "searchkick_search_shingle", "searchkick_stemmer"],
          },
          searchkick_search2: {
            type:        "custom",
            char_filter: ["ampersand"],
            tokenizer:   "standard",
            filter:      ["lowercase", "asciifolding", "searchkick_stemmer"],
          },
          # https://github.com/leschenko/elasticsearch_autocomplete/blob/master/lib/elasticsearch_autocomplete/analyzers.rb
          searchkick_autocomplete_search: {
            type:      "custom",
            tokenizer: "keyword",
            filter:    ["lowercase", "asciifolding"],
          },
          searchkick_word_search: {
            type:      "custom",
            tokenizer: "standard",
            filter:    ["lowercase", "asciifolding"],
          },
          searchkick_suggest_index: {
            type:      "custom",
            tokenizer: "standard",
            filter:    ["lowercase", "asciifolding", "searchkick_suggest_shingle"],
          },
          searchkick_text_start_index: {
            type:      "custom",
            tokenizer: "keyword",
            filter:    ["lowercase", "asciifolding", "searchkick_edge_ngram"],
          },
          searchkick_text_middle_index: {
            type:      "custom",
            tokenizer: "keyword",
            filter:    ["lowercase", "asciifolding", "searchkick_ngram"],
          },
          searchkick_text_end_index: {
            type:      "custom",
            tokenizer: "keyword",
            filter:    ["lowercase", "asciifolding", "reverse", "searchkick_edge_ngram", "reverse"],
          },
          searchkick_word_start_index: {
            type:      "custom",
            tokenizer: "standard",
            filter:    ["lowercase", "asciifolding", "searchkick_edge_ngram"],
          },
          searchkick_word_middle_index: {
            type:      "custom",
            tokenizer: "standard",
            filter:    ["lowercase", "asciifolding", "searchkick_ngram"],
          },
          searchkick_word_end_index: {
            type:      "custom",
            tokenizer: "standard",
            filter:    ["lowercase", "asciifolding", "reverse", "searchkick_edge_ngram", "reverse"],
          },
        },
        filter: {
          searchkick_index_shingle: {
            type:            "shingle",
            token_separator: "",
          },
          # lucky find https://web.archiveorange.com/archive/v/AAfXfQ17f57FcRINsof7
          searchkick_search_shingle: {
            type:                           "shingle",
            token_separator:                "",
            output_unigrams:                false,
            output_unigrams_if_no_shingles: true,
          },
          searchkick_suggest_shingle: {
            type:             "shingle",
            max_shingle_size: 5,
          },
          searchkick_edge_ngram: {
            type:     "edge_ngram",
            min_gram: 1,
            max_gram: 50,
          },
          searchkick_ngram: {
            type:     "ngram",
            min_gram: 1,
            max_gram: 50,
          },
          searchkick_stemmer: {
            # use stemmer if language is lowercase, snowball otherwise
            type:     language == language.to_s.downcase ? "stemmer" : "snowball",
            language: "English",
          },
        },
        char_filter: {
          # https://www.elastic.co/guide/en/elasticsearch/guide/current/custom-analyzers.html
          # &_to_and
          ampersand: {
            type:     "mapping",
            mappings: ["&=> and "],
          },
        },
      }
    end
  end
end
