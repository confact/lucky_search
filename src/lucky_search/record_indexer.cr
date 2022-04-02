require "uuid"

class LuckySearch::RecordIndexer
  getter document_name : String
  getter id : Int64 | UUID

  # the data to index
  getter search_data : Hash(String, String | Int32 | Int64 | Float32 | Float64 | Bool)

  getter client : Elastic

  def initialize(@document_name, @id, @search_data)
    @client = Elastic.new
  end

  def self.document_name(klass : Class) : String
    klass.name.split("::").last
  end

  def self.index(klass : Class, id, search_data)
    document_name = document_name(klass)
    new(document_name, id, search_data).index_record
  end

  def self.remove(klass : Class, id, search_data)
    document_name = document_name(klass)
    new(document_name, id, search_data).remove_record
  end

  def remove_record
    client.delete(document_name, id)
  end

  def index_record
    if client.index_exists?(document_name)
      index_document
    else
      create_index
      index_document
    end
  end

  def index_document
    if client.exists?(document_name, id)
      client.update(document_name, id, search_data)
    else
      client.create(document_name, id, search_data)
    end
  end

  def create_index
    schema = Schema.generate_schema(search_data)
    client.create_index(document_name, schema)
  end
end
