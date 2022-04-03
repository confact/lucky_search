class CreateChildren::V20220403114024 < Avram::Migrator::Migration::V1
  def migrate
    create table_for(Child) do
      primary_key id : Int64
      add_timestamps
      add hoof_treatment : String
      add age : Int32 = 0
      add visits : String = ""
      add_belongs_to goat : Goat, on_delete: :cascade
    end
  end

  def rollback
    drop table_for(Child)
  end
end
