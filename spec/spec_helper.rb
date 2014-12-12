$LOAD_PATH << File.expand_path("../lib")
require 'voteatx'

DATABASE = File.expand_path("./voteatx.db")

def open_database(options = {})
  dbname = options.delete(:database) || DATABASE
  require 'logger'
  @log = options.delete(:log) || Logger.new($stderr)
  debug = options.has_key?(:debug) ? options.delete(:debug) : false
  @log.level = (debug ? Logger::DEBUG : Logger::INFO)

  @db = Sequel.spatialite(dbname)
  @db.logger = @log
  @db.sql_log_level = :debug

  return @db
end

