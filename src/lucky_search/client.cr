require "habitat"
require "db"
require "http"
require "./error"

# borrowed from Neuroplastic - thank you Place Labs
class LuckySearch::Client
  NUM_INDICES = 10

  # Settings for elastic client
  Habitat.create do
    setting uri : URI? = Client.env_with_deprecation("ELASTIC_URI", "ES_URI").try(&->URI.parse(String))
    setting host : String = Client.env_with_deprecation("ELASTIC_HOST", "ES_HOST") || "127.0.0.1"
    setting port : Int32 = Client.env_with_deprecation("ELASTIC_PORT", "ES_PORT").try(&.to_i) || 9200
    setting tls : Bool = Client.env_with_deprecation("ELASTIC_TLS", "ES_TLS") == "true"
    setting pooled : Bool = Client.env_with_deprecation("ELASTIC_POOLED", "ES_POOLED") == "true"
    setting pool_size : Int32 = Client.env_with_deprecation("ELASTIC_CONN_POOL", "ES_CONN_POOL").try(&.to_i) || NUM_INDICES
    setting idle_pool_size : Int32 = Client.env_with_deprecation("ELASTIC_IDLE_POOL", "ES_IDLE_POOL").try(&.to_i) || NUM_INDICES // 4
    setting pool_timeout : Float64 = Client.env_with_deprecation("ELASTIC_CONN_POOL_TIMEOUT", "ES_CONN_POOL_TIMEOUT").try(&.to_f64) || 5.0
  end

  # The first argument will be treated as the correct environment variable.
  # Presence of follwoing vars will produce warnings.
  protected def self.env_with_deprecation(*args) : String?
    if correct_env = ENV[args.first]?.presence
      return correct_env
    end

    args[1..].each do |env|
      if found = ENV[env]?.presence
        Log.warn { "using deprecated env var #{env}, please use #{args.first}" }
        return found
      end
    end
  end

  def search(arguments = {} of Symbol => String) : JSON::Any
    valid_params = [
      :_source,
      :_source_exclude,
      :_source_include,
      :allow_no_indices,
      :analyze_wildcard,
      :analyzer,
      :batched_reduce_size,
      :default_operator,
      :df,
      :docvalue_fields,
      :expand_wildcards,
      :explain,
      :fielddata_fields,
      :fields,
      :from,
      :ignore_indices,
      :ignore_unavailable,
      :lenient,
      :lowercase_expanded_terms,
      :preference,
      :q,
      :query_cache,
      :request_cache,
      :routing,
      :scroll,
      :search_type,
      :size,
      :sort,
      :source,
      :stats,
      :stored_fields,
      :suggest_field,
      :suggest_mode,
      :suggest_size,
      :suggest_text,
      :terminate_after,
      :timeout,
      :typed_keys,
      :version,
    ]

    index = arguments[:index]? || "_all"
    path = "/#{index}/_search"
    method = "POST"
    body = arguments[:body]?
    params = arguments.to_h.select(valid_params)

    fields = arguments[:fields]?

    if fields
      fields = [fields] unless fields.is_a?(Array)
      params[:fields] = fields.map(&.to_s).join(',')
    end

    fielddata_fields = arguments[:fielddata_fields]?
    if fielddata_fields
      fielddata_fields = [fielddata_fields] unless fielddata_fields.is_a?(Array)
      params[:fielddata_fields] = fielddata_fields.map(&.to_s).join(',')
    end

    Log.debug { "performing search: params=#{params} body=#{body.to_json}" }
    perform_request(method: method, path: path, params: params, body: body)
  end

  def count(arguments = {} of Symbol => String)
    valid_params = [
      :allow_no_indices,
      :analyze_wildcard,
      :analyzer,
      :default_operator,
      :df,
      :expand_wildcards,
      :ignore_unavailable,
      :lenient,
      :lowercase_expanded_terms,
      :min_score,
      :preference,
      :q,
      :routing,
    ]

    index = arguments[:index]? || "_all"
    index = index.join(',') if index.is_a?(Array(String))
    path = "/#{index}/_count"
    method = "POST"
    body = arguments[:body]?
    params = arguments.to_h.select(valid_params)

    perform_request(method: method, path: path, params: params, body: body)
  end

  def refresh(index)
    path = "/#{index}/_refresh"
    method = "POST"
    body = nil

    perform_request_bool(method: method, path: path, body: body)
  end

  def exists?(index, id) : Bool
    path = "/#{index}/_doc/#{id}"
    method = "HEAD"

    perform_request_bool(method: method, path: path)
  end

  def get(index, id)
    path = "/#{index}/_doc/#{id}"
    method = "GET"

    perform_request(method: method, path: path)
  end

  def delete(index, id)
    path = "/#{index}/_doc/#{id}"
    method = "DELETE"

    perform_request(method: method, path: path)
  end

  def create(index, body)
    path = "/#{index}/_doc"
    method = "POST"

    perform_request(method: method, path: path, body: body)
  end

  def update(index, id, body)
    path = "/#{index}/_doc/#{id}"
    method = "PUT"

    perform_request(method: method, path: path, body: body)
  end

  def index_exists?(index) : Bool
    path = "/#{index}"
    method = "HEAD"

    perform_request_bool(method: method, path: path)
  end

  def delete_index(index)
    path = "/#{index}"
    method = "DELETE"

    perform_request(method: method, path: path) if index_exists?(index)
  end

  def create_index(index, body)
    path = "/#{index}"
    method = "PUT"

    perform_request(method: method, path: path, body: body)
  end

  def empty_indices(indices : Array(String)? = nil)
    query = {
      query: {
        match_all: {} of String => String,
      },
    }.to_json

    url = if indices && !indices.empty?
            "/#{indices.join(',')}/_delete_by_query"
          else
            "/_all/_delete_by_query"
          end

    perform_request_bool(method: "POST", path: url, body: query)
  end

  def perform_request(method, path, params = nil, body = nil) : JSON::Any
    post_body = body.try(&.to_json)
    response = case method.upcase
               when "GET"
                 endpoint = "#{path}?#{normalize_params(params)}"
                 if post_body
                   Client.client &.get(path: endpoint, body: post_body, headers: JSON_HEADER)
                 else
                   Client.client &.get(path: endpoint)
                 end
               when "POST"
                 Client.client &.post(path: path, body: post_body, headers: JSON_HEADER)
               when "PUT"
                 Client.client &.put(path: path, body: post_body, headers: JSON_HEADER)
               when "DELETE"
                 endpoint = "#{path}?#{normalize_params(params)}"
                 Client.client &.delete(path: endpoint)
               when "HEAD"
                 Client.client &.head(path: path)
               else
                 raise "Unsupported method: #{method}"
               end

    if response.success?
      JSON.parse(response.body)
    else
      raise Error::ElasticQueryError.new("ES error: #{response.status_code}\n#{response.body}")
    end
  end

  def perform_request_bool(method, path, params = nil, body = nil) : Bool
    post_body = body.try(&.to_json)
    response = case method.upcase
               when "GET"
                 endpoint = "#{path}?#{normalize_params(params)}"
                 if post_body
                   Client.client &.get(path: endpoint, body: post_body, headers: JSON_HEADER)
                 else
                   Client.client &.get(path: endpoint)
                 end
               when "POST"
                 Client.client &.post(path: path, body: post_body, headers: JSON_HEADER)
               when "PUT"
                 Client.client &.put(path: path, body: post_body, headers: JSON_HEADER)
               when "DELETE"
                 endpoint = "#{path}?#{normalize_params(params)}"
                 Client.client &.delete(path: endpoint)
               when "HEAD"
                 Client.client &.head(path: path)
               else
                 raise "Unsupported method: #{method}"
               end

    response.success?
  end

  # Normalize params to string and encode
  private def normalize_params(params) : String
    if params
      new_params = params.reduce({} of String => String) do |hash, kv|
        k, v = kv
        hash[k.to_s] = v.to_s
        hash
      end
      HTTP::Params.encode(new_params)
    else
      ""
    end
  end

  private JSON_HEADER = HTTP::Headers{"Content-Type" => "application/json"}

  # Client Connection Pooling
  #############################################################################

  protected class_getter pool : DB::Pool(PoolHTTP) {
    DB::Pool(PoolHTTP).new(
      initial_pool_size: settings.pool_size // 4,
      max_pool_size: settings.pool_size,
      max_idle_pool_size: settings.idle_pool_size,
      checkout_timeout: settings.pool_timeout
    ) { elastic_connection }
  }

  # Yield an elastic client
  #
  protected def self.client
    if settings.pooled
      client = pool.checkout
      result = yield client
      pool.release(client)
      result
    else
      client = elastic_connection
      result = yield client
      spawn { client.close }
      result
    end
  end

  private def self.elastic_connection
    # FIXME: ES_TLS not being pulled from env in habitat settings
    uri = settings.uri
    tls = settings.tls? || uri.try(&.scheme) == "https"

    tls_context = if tls
                    context = OpenSSL::SSL::Context::Client.new
                    context.verify_mode = OpenSSL::SSL::VerifyMode::NONE
                    context
                  else
                    nil
                  end

    pool = if uri.nil?
             PoolHTTP.new(host: settings.host, port: settings.port, tls: tls_context)
           else
             PoolHTTP.new(uri: uri, tls: tls_context)
           end
    if uri && (uri.password || uri.user)
      pool.basic_auth(uri.user, uri.password)
    end
    pool
  end

  private class PoolHTTP < HTTP::Client
    # DB::Pool stubs
    ############################################################################
    def before_checkout
    end

    def after_release
    end
  end
end
