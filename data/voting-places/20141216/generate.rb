#!/usr/bin/env -- ruby

require 'rubygems'
require 'bundler'
Bundler.setup
require "#{Bundler.root}/lib/voteatx/loader.rb"

raise "usage: #{$0} database\n" unless ARGV.length == 1
dbname = ARGV[0]
raise "database file \"#{dbname}\" already exists\n" if File.exist?(dbname)

shpl = VoteATX::ShapeFileLoader.new(:database => dbname, :log => @log)

shpl.load(:shapefile => "../../voting-districts/2012/VTD2012a.shp",
  :srid => "3081", :table => "voting_districts")

shpl.load(:shapefile => "../../council-districts/2014/single_member_districts.shp",
  :srid => "4269", :table => "council_districts")

loader = VoteATX::VotingPlacesLoader.new(dbname, :log => @log, :debug => false)



####
#
# The "election_code" is used to determine sample ballots.
#

loader.election_code = "GR14"


#####
#
# Key dates.
#

loader.date_early_voting_begins = Date.new(2014, 12, 1)
loader.date_early_voting_ends = Date.new(2014, 12, 12)
loader.date_election_day = Date.new(2014, 12, 16)

#####
#
# A one-line description of the election
#
# Example: "for the Nov 5, 2013 general election in Travis County"
#
# In the VoteATX app this is displayed below the title of the
# voting place (e.g. "Precinct 31415").
#

#loader.election_description = 


#####
#
# Additional information about the election.
#
# This is included near the bottom of the info window that is
# opened up for a voting place. Full HTML is supported. Line
# breaks automatically inserted.
#
# This would be a good place to put a link to the official
# county voting page for this election.
#

#loader.election_info = 


#####
#
# Hours voting places are open on election day.
#
# Define this as a range:  Time .. Time
#

ELECTION_DAY_HOURS = Time.new(2014, 12, 16, 7, 0) .. Time.new(2014, 12, 16, 19, 0)


#####
#
# Hours for the fixed early voting places, indexed by schedule code.
#
# The fixed early voting places spreadsheet has a column with a schedule
# code that identifies the schedule for that place.
#
# Define this as a map of schedule code to a list of open..close time ranges.
#

# EARLY VOTING LOCATIONS
EARLY_VOTING_FIXED_HOURS = {

  # Mon-Sat 7am-7pm, Sun Noon to 6pm
  'R' => [
    Time.new(2014, 12,  1,  7,  0) .. Time.new(2014, 12,  1, 19,  0), # Mo
    Time.new(2014, 12,  2,  7,  0) .. Time.new(2014, 12,  2, 19,  0), # Tu
    Time.new(2014, 12,  3,  7,  0) .. Time.new(2014, 12,  3, 19,  0), # We
    Time.new(2014, 12,  4,  7,  0) .. Time.new(2014, 12,  4, 19,  0), # Th
    Time.new(2014, 12,  5,  7,  0) .. Time.new(2014, 12,  5, 19,  0), # Fr
    Time.new(2014, 12,  6,  7,  0) .. Time.new(2014, 12,  6, 19,  0), # Sa
    Time.new(2014, 12,  7, 12,  0) .. Time.new(2014, 12,  7, 18,  0), # Su (Noon to 6p)
    Time.new(2014, 12,  8,  7,  0) .. Time.new(2014, 12,  8, 19,  0), # Mo
    Time.new(2014, 12,  9,  7,  0) .. Time.new(2014, 12,  9, 19,  0), # Tu
    Time.new(2014, 12, 10,  7,  0) .. Time.new(2014, 12, 10, 19,  0), # We
    Time.new(2014, 12, 11,  7,  0) .. Time.new(2014, 12, 11, 19,  0), # Th
    Time.new(2014, 12, 12,  7,  0) .. Time.new(2014, 12, 12, 19,  0), # Fr
  ],

  # Mon-Thur 10am-7pm, Fri Closed, Sat 10am-5pm, Sun Closed
  'V|Carver Museum' => [
    Time.new(2014, 12,  1, 10,  0) .. Time.new(2014, 12,  1, 19,  0), # Mo
    Time.new(2014, 12,  2, 10,  0) .. Time.new(2014, 12,  2, 19,  0), # Tu
    Time.new(2014, 12,  3, 10,  0) .. Time.new(2014, 12,  3, 19,  0), # We
    Time.new(2014, 12,  4, 10,  0) .. Time.new(2014, 12,  4, 19,  0), # Th
    Time.new(2014, 12,  5,  0,  0) .. Time.new(2014, 12,  5,  0,  0), # Fr (Closed)
    Time.new(2014, 12,  6, 10,  0) .. Time.new(2014, 12,  6, 17,  0), # Sa (10am-5pm)
    Time.new(2014, 12,  7,  0,  0) .. Time.new(2014, 12,  7,  0,  0), # Su (Closed)
    Time.new(2014, 12,  8, 10,  0) .. Time.new(2014, 12,  8, 19,  0), # Mo
    Time.new(2014, 12,  9, 10,  0) .. Time.new(2014, 12,  9, 19,  0), # Tu
    Time.new(2014, 12, 10, 10,  0) .. Time.new(2014, 12, 10, 19,  0), # We
    Time.new(2014, 12, 11, 10,  0) .. Time.new(2014, 12, 11, 19,  0), # Th
    Time.new(2014, 12, 12,  0,  0) .. Time.new(2014, 12, 12,  0,  0), # Fr (Closed)
  ],

  # Mon-Thurs 10am-7pm, Fri Closed, Sat 10am-5pm, Sun 2pm-6pm
  'V|Dan Ruiz Public Library' => [
    Time.new(2014, 12,  1, 10,  0) .. Time.new(2014, 12,  1, 19,  0), # Mo
    Time.new(2014, 12,  2, 10,  0) .. Time.new(2014, 12,  2, 19,  0), # Tu
    Time.new(2014, 12,  3, 10,  0) .. Time.new(2014, 12,  3, 19,  0), # We
    Time.new(2014, 12,  4, 10,  0) .. Time.new(2014, 12,  4, 19,  0), # Th
    Time.new(2014, 12,  5,  0,  0) .. Time.new(2014, 12,  5,  0,  0), # Fr (Closed)
    Time.new(2014, 12,  6, 10,  0) .. Time.new(2014, 12,  6, 17,  0), # Sa (10am-5pm)
    Time.new(2014, 12,  7, 14,  0) .. Time.new(2014, 12,  7, 16,  0), # Su (2pm-6pm)
    Time.new(2014, 12,  8, 10,  0) .. Time.new(2014, 12,  8, 19,  0), # Mo
    Time.new(2014, 12,  9, 10,  0) .. Time.new(2014, 12,  9, 19,  0), # Tu
    Time.new(2014, 12, 10, 10,  0) .. Time.new(2014, 12, 10, 19,  0), # We
    Time.new(2014, 12, 11, 10,  0) .. Time.new(2014, 12, 11, 19,  0), # Th
    Time.new(2014, 12, 12,  0,  0) .. Time.new(2014, 12, 12,  0,  0), # Fr (Closed)
  ],

  # Mon-Thurs 9am-7pm, Fri 9am - 6pm, Sat 9am-4pm, Sun Closed
  'V|Gus Garcia Recreation Center' => [
    Time.new(2014, 12,  1,  9,  0) .. Time.new(2014, 12,  1, 19,  0), # Mo
    Time.new(2014, 12,  2,  9,  0) .. Time.new(2014, 12,  2, 19,  0), # Tu
    Time.new(2014, 12,  3,  9,  0) .. Time.new(2014, 12,  3, 19,  0), # We
    Time.new(2014, 12,  4,  9,  0) .. Time.new(2014, 12,  4, 19,  0), # Th
    Time.new(2014, 12,  5,  9,  0) .. Time.new(2014, 12,  5, 18,  0), # Fr (9am - 6pm)
    Time.new(2014, 12,  6,  9,  0) .. Time.new(2014, 12,  6, 17,  0), # Sa (9am-4pm)
    Time.new(2014, 12,  7,  0,  0) .. Time.new(2014, 12,  7,  0,  0), # Su (Closed)
    Time.new(2014, 12,  8,  9,  0) .. Time.new(2014, 12,  8, 19,  0), # Mo
    Time.new(2014, 12,  9,  9,  0) .. Time.new(2014, 12,  9, 19,  0), # Tu
    Time.new(2014, 12, 10,  9,  0) .. Time.new(2014, 12, 10, 19,  0), # We
    Time.new(2014, 12, 11,  9,  0) .. Time.new(2014, 12, 11, 19,  0), # Th
    Time.new(2014, 12, 12,  9,  0) .. Time.new(2014, 12, 12, 19,  0), # Fr
  ],

  # Mon-Wed 10am-7pm, Thurs Closed, Fri 10am-6pm, Sat 10am-5pm, Sun Closed
  'V|Howson Branch Library' => [
    Time.new(2014, 12,  1, 10,  0) .. Time.new(2014, 12,  1, 19,  0), # Mo
    Time.new(2014, 12,  2, 10,  0) .. Time.new(2014, 12,  2, 19,  0), # Tu
    Time.new(2014, 12,  3, 10,  0) .. Time.new(2014, 12,  3, 19,  0), # We
    Time.new(2014, 12,  4,  0,  0) .. Time.new(2014, 12,  4,  0,  0), # Th (Closed)
    Time.new(2014, 12,  5, 10,  0) .. Time.new(2014, 12,  5, 18,  0), # Fr (10am-6pm)
    Time.new(2014, 12,  6, 10,  0) .. Time.new(2014, 12,  6, 17,  0), # Sa (10am-5pm)
    Time.new(2014, 12,  7,  0,  0) .. Time.new(2014, 12,  7,  0,  0), # Su (Closed)
    Time.new(2014, 12,  8, 10,  0) .. Time.new(2014, 12,  8, 19,  0), # Mo
    Time.new(2014, 12,  9, 10,  0) .. Time.new(2014, 12,  9, 19,  0), # Tu
    Time.new(2014, 12, 10, 10,  0) .. Time.new(2014, 12, 10, 19,  0), # We
    Time.new(2014, 12, 11, 10,  0) .. Time.new(2014, 12, 11, 19,  0), # Th
    Time.new(2014, 12, 12, 10,  0) .. Time.new(2014, 12, 12, 19,  0), # Fr
  ],

  # Mon-Thurs Noon-7pm, Fri Noon-6pm, Sat 1pm-5pm, Sun Closed
  'V|Parque Zaragoza Recreation Center' => [
    Time.new(2014, 12,  1, 12,  0) .. Time.new(2014, 12,  1, 19,  0), # Mo
    Time.new(2014, 12,  2, 12,  0) .. Time.new(2014, 12,  2, 19,  0), # Tu
    Time.new(2014, 12,  3, 12,  0) .. Time.new(2014, 12,  3, 19,  0), # We
    Time.new(2014, 12,  4, 12,  0) .. Time.new(2014, 12,  4, 19,  0), # Th
    Time.new(2014, 12,  5, 12,  0) .. Time.new(2014, 12,  5, 18,  0), # Fr (Noon-6pm)
    Time.new(2014, 12,  6, 13,  0) .. Time.new(2014, 12,  6, 17,  0), # Sa (1pm-5pm)
    Time.new(2014, 12,  7,  0,  0) .. Time.new(2014, 12,  7,  0,  0), # Su (Closed)
    Time.new(2014, 12,  8, 12,  0) .. Time.new(2014, 12,  8, 19,  0), # Mo
    Time.new(2014, 12,  9, 12,  0) .. Time.new(2014, 12,  9, 19,  0), # Tu
    Time.new(2014, 12, 10, 12,  0) .. Time.new(2014, 12, 10, 19,  0), # We
    Time.new(2014, 12, 11, 12,  0) .. Time.new(2014, 12, 11, 19,  0), # Th
    Time.new(2014, 12, 12, 12,  0) .. Time.new(2014, 12, 12, 18,  0), # Fr (Noon-6pm)
  ],

  # Mon-Fri 9am-7pm, Sat 10am - 7pm, Sun Noon to 6pm
  'V|St. Edwards University' => [
    Time.new(2014, 12,  1,  9,  0) .. Time.new(2014, 12,  1, 19,  0), # Mo
    Time.new(2014, 12,  2,  9,  0) .. Time.new(2014, 12,  2, 19,  0), # Tu
    Time.new(2014, 12,  3,  9,  0) .. Time.new(2014, 12,  3, 19,  0), # We
    Time.new(2014, 12,  4,  9,  0) .. Time.new(2014, 12,  4, 19,  0), # Th
    Time.new(2014, 12,  5,  9,  0) .. Time.new(2014, 12,  5, 19,  0), # Fr
    Time.new(2014, 12,  6, 10,  0) .. Time.new(2014, 12,  6, 19,  0), # Sa (10am - 7pm)
    Time.new(2014, 12,  7, 12,  0) .. Time.new(2014, 12,  7, 18,  0), # Su (Noon to 6pm)
    Time.new(2014, 12,  8,  9,  0) .. Time.new(2014, 12,  8, 19,  0), # Mo
    Time.new(2014, 12,  9,  9,  0) .. Time.new(2014, 12,  9, 19,  0), # Tu
    Time.new(2014, 12, 10,  9,  0) .. Time.new(2014, 12, 10, 19,  0), # We
    Time.new(2014, 12, 11,  9,  0) .. Time.new(2014, 12, 11, 19,  0), # Th
    Time.new(2014, 12, 12,  9,  0) .. Time.new(2014, 12, 12, 19,  0), # Fr
  ],

}


#####
#
# Some definitions used for input validation.
#

loader.valid_lng_range = -98.057163 .. -97.383048
loader.valid_lat_range = 30.088999 .. 30.572025
loader.valid_zip_regexp = /^78[67]\d\d$/


#####
#
# Perform the load.
#

loader.create_tables
loader.load_evfixed_places("20141216_GR14_Webload_FINAL_EVPerm.csv", EARLY_VOTING_FIXED_HOURS)
loader.load_evmobile_places("20141216_GR14_Webload_FINAL_EVMobile.csv")
loader.load_eday_places("20141216_GR14_Webload_FINAL_EDay.csv", ELECTION_DAY_HOURS)
loader.log.info("done")

