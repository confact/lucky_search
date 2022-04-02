require "./elastic"
require "./utils"

class LuckySearch::SimpleQuery(T)
  COUNT  = "count"
  SCORE  = ["_score"]
  ID     = "_id"
  SOURCE = "_source"
  TYPE   = "_document_type"

  HITS  = "hits"
  TOTAL = "total"
  VALUE = "value"

  # Index defaults to avram table name
  getter elastic_index : String

  # Document type defaults to class name without namespace
  getter elastic_document_name : String

  def initialize(elastic_index : String? = nil, document_name : String? = nil)
    @elastic_document_name = document_name ? document_name : Utils.document_name(elastic_index)
    @elastic_index = elastic_index
  end

  # Yields the elasticsearch client
  getter(client) { LuckySearch::Elastic.new }

  # Safely build the query
  def query(params = {} of Symbol => String, filters = nil)
    builder = Query.new(params)
    builder.filter(filters) unless filters.nil?

    builder.filter({TYPE => [elastic_document_name]})

    builder
  end

  def query(q : String, params = {} of Symbol => String, filters = nil)
    params[:q] = q
    builder = Query.new(params)
    builder.filter(filters) unless filters.nil?

    builder.filter({TYPE => [elastic_document_name]})

    builder
  end

  # Performs a count query against an index
  def count(builder)
    query = generate_body(builder)

    # Simplify the query
    body = query[:body].to_h.reject(:from, :size, :sort)
    simplified = query.merge({body: body})
    client.count(simplified)[COUNT].as_i
  end

  # Query elasticsearch with a query builder object
  def search(builder)
    _search(builder)
  end

  # Query elasticsearch with a query builder object, accepts a formatter block
  # Allows annotation/conversion of records using data from the model.
  # Nils are removed from the list.
  def search(builder, &block : Proc(T, (T?)))
    _search(builder, block)
  end

  private def _search(builder, block = nil)
    query = generate_body(builder)
    result = client.search(query.to_h)

    raw_records = get_records(result).to_a
    records = block ? raw_records.compact_map { |r| block.call r } : raw_records

    total = result_total(result: result, builder: builder, records: records, raw: raw_records)
    {
      total:   total,
      results: records,
    }
  end

  # Ensures the results total is accurate
  private def result_total(result, builder, records, raw = nil)
    total = result.dig(HITS, TOTAL, VALUE).try(&.as_i) || 0

    records_size = records.size
    raw_size = raw.try(&.size) || records_size

    total = total - (records_size - raw_size) # adjust for compaction

    offset = builder.offset
    limit = builder.limit

    # We check records against limit (pre-compaction) and total against actual result length
    # Worst case scenario is there is one additional request for results at an offset that returns no results.
    # The total results number will be accurate on the final page of results from the clients perspective.
    total = records_size + offset if raw_size < limit && total > (offset + records_size)
    total
  end

  # Filters off results that do not match the document type.
  # Returns a collection of records pulled in from the db.
  private def get_records(result)
    ids = result.dig?(HITS, HITS).try(&.as_a.compact_map(&.[ID].as_s?))

    ids ? T.new.id.in(ids) : [] of T
  end

  def generate_body(builder)
    opt = builder.build

    index = builder.index || elastic_index
    query = opt[:query]
    filter = opt[:filter]
    sort = (opt[:sort]? || [] of Array(String)) + SCORE

    query_context = {
      # Only merge in filter if it contains fields
      bool: filter ? query.merge(filter) : query,
    }

    {
      index: index,
      body:  {
        query: query_context,
        sort:  sort,
        from:  opt[:offset],
        size:  opt[:limit],
      },
    }
  end
end
