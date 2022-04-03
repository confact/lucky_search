ENV["LUCKY_ENV"] = "test"
require "spec"
require "avram"

database_name = "lucky_search_#{LuckyEnv.environment}"

AppDatabase.configure do |settings|
  settings.credentials = Avram::Credentials.parse?(ENV["DATABASE_URL"]?) || Avram::Credentials.new(
    database: database_name,
    hostname: ENV["DB_HOST"]? || "localhost",
    port: ENV["DB_PORT"]?.try(&.to_i) || 5432,
    # Some common usernames are "postgres", "root", or your system username (run 'whoami')
    username: ENV["DB_USERNAME"]? || "postgres",
    # Some Postgres installations require no password. Use "" if that is the case.
    password: ENV["DB_PASSWORD"]? || "postgres"
  )
end

require "../src/lucky_search"

require "./support/**"
require "./setup/**"
require "./**"
