class CreateGoats::V20220403114015 < Avram::Migrator::Migration::V1
  def migrate
    create table_for(Goat) do
      primary_key id : Int64
      add_timestamps
      add name : String
      add teeth : Int32 = 0
      add job : String
    end
  end

  def rollback
    drop table_for(Goat)
  end
end
