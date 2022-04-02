module Searchable
  macro included
    after_save index_record
    after_delete remove_record
  end

  def remove_record(deleted_record)
    LuckySearch::RecordIndexer.remove(deleted_record.class, deleted_record.id, deleted_record.search_data)
  end

  def index_record(saved_record)
    LuckySearch::RecordIndexer.index(saved_record.class, saved_record.id, saved_record.search_data)
  end
end
