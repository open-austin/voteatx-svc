#!/usr/bin/env -- ruby

require 'rubygems'
require 'ostruct'
require 'bundler'
Bundler.setup
require "#{Bundler.root}/lib/voteatx/loader.rb"

raise "usage: #{$0} database\n" unless ARGV.length == 1
dbname = ARGV[0]
raise "database file \"#{dbname}\" already exists\n" if File.exist?(dbname)

DATE_EARLY_VOTING_BEGINS = Date.new(2014, 12, 1)
DATE_EARLY_VOTING_ENDS = Date.new(2014, 12, 12)
DATE_ELECTION_DAY = Date.new(2014, 12, 16)

TRAVIS = OpenStruct.new({
  :id => "TRAVIS",
  :name => "Travis County",
  :date_early_voting_begins => DATE_EARLY_VOTING_BEGINS,
  :date_early_voting_ends => DATE_EARLY_VOTING_ENDS,
  :date_election_day => DATE_ELECTION_DAY,
  :have_voting_districts => true,
  :vtd_table => "voting_districts_travis",
  :vtd_srid => 3081,
  :vtd_col_geo => "Geometry",
  :vtd_col_pct => "p_vtd",
  :have_early_voting_places => true,
  :have_election_day_voting_places => true,
  :sample_ballot_url => "http://www.traviscountyclerk.org/eclerk/content/images/ballots/GR14/%sA.pdf",
})

WILLIAMSON = OpenStruct.new({
  :id => "WILLIAMSON",
  :name => "Williamson County",
  :date_early_voting_begins => DATE_EARLY_VOTING_BEGINS,
  :date_early_voting_ends => DATE_EARLY_VOTING_ENDS,
  :date_election_day => DATE_ELECTION_DAY,
  :have_voting_districts => true,
  :vtd_table => "voting_districts_williamson",
  :vtd_srid => 2277,
  :vtd_col_geo => "Geometry",
  :vtd_col_pct => "District_1",
  :have_early_voting_places => false,
  :have_election_day_voting_places => false,
  :sample_ballot_url => nil,
})

shpl = VoteATX::ShapeFileLoader.new(:database => dbname, :log => @log)

shpl.load(:table => TRAVIS.vtd_table,
  :shapefile => "../../co.travis.voting-districts/2012/VTD2012a.shp",
  :srid => TRAVIS.vtd_srid.to_s)

shpl.load(:table => WILLIAMSON.vtd_table,
  :shapefile => "../../co.williamson.voting-districts/2012/Wilco2012_VtrPcts.shp",
  :srid => WILLIAMSON.vtd_srid.to_s)

shpl.load(:table => "council_districts",
  :shapefile => "../../ci.austin.council-districts/2014/single_member_districts.shp",
  :srid => "4269")

loader = VoteATX::VotingPlacesLoader.new(dbname, :log => @log, :debug => false)


#######
####
#### The "election_code" is used to determine sample ballots.
####
###
###loader.election_code = "GR14"
###
###
########
####
#### Key dates.
####
###
###loader.date_early_voting_begins = Date.new(2014, 12, 1)
###loader.date_early_voting_ends = Date.new(2014, 12, 12)
###loader.date_election_day = Date.new(2014, 12, 16)
###
########
####
#### A one-line description of the election
####
#### Example: "for the Nov 5, 2013 general election in Travis County"
####
#### In the VoteATX app this is displayed below the title of the
#### voting place (e.g. "Precinct 31415").
####
###
####loader.election_description = 
###
###
########
####
#### Additional information about the election.
####
#### This is included near the bottom of the info window that is
#### opened up for a voting place. Full HTML is supported. Line
#### breaks automatically inserted.
####
#### This would be a good place to put a link to the official
#### county voting page for this election.
####
###
####loader.election_info = 



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
  'V|Carver Branch Library' => [
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
# Set "explode_combined_precincts" true if the "Combined Pcts" needs to be
# exploded into multiple rows. Set it false if there will be a row
# per precinct.
#
#
loader.explode_combined_precincts = false

#####
#
# Perform the load.
#

loader.create_tables

loader.db[:jurisdictions] << TRAVIS.to_h
loader.db[:jurisdictions] << WILLIAMSON.to_h

ELECTION_DAY_HOURS = Time.new(2014, 12, 16, 7, 0) .. Time.new(2014, 12, 16, 19, 0)

loader.valid_lng_range = -97.85458 .. -97.65450
loader.valid_lat_range = 30.43829 .. 30.579288
loader.valid_zip_regexp = /^78[67]\d\d$/

P_wC = "../../co.williamson.voting-places/20141216"
loader.load_eday_places("#{P_wC}/VoteCenters_Dec2014.csv", "WILLIAMSON", ELECTION_DAY_HOURS)


loader.valid_lng_range = -98.057163 .. -97.383048
loader.valid_lat_range = 30.088999 .. 30.572025
loader.valid_zip_regexp = /^78[67]\d\d$/

P_TC = "../../co.travis.voting-places/20141216"
loader.load_evfixed_places("#{P_TC}/20141216_GR14_EVPerm.csv", "TRAVIS", EARLY_VOTING_FIXED_HOURS)
loader.load_evmobile_places("#{P_TC}/20141216_GR14_EVMobile.csv", "TRAVIS")
loader.load_eday_places("#{P_TC}/20141216_GR14_EDay.csv", "TRAVIS", ELECTION_DAY_HOURS)

loader.log.info("done")

