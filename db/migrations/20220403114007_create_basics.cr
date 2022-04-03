class CreateBasics::V20220403114007 < Avram::Migrator::Migration::V1
  def migrate
    create table_for(Basic) do
      primary_key id : Int64
      add_timestamps
      add name : String
    end
  end

  def rollback
    drop table_for(Basic)
  end
end
