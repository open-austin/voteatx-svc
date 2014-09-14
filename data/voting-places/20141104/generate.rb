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


#####
#
# Set true to create records for all the precincts
# when a combined precinct is encountered.
# 
# If false (or undefined), there should be an entry in the
# dataset for every precinct.
#
# If true, combined precincts are represented by a single
# entry.
#
loader.explode_combined_precincts = true


#####
#
# A one-line description of the election
#
# Example: "for the Nov 5, 2013 general election in Travis County"
#
# In the VoteATX app this is displayed below the title of the
# voting place (e.g. "Precinct 31415").
#

loader.election_description = "for the Nov 4, 2014 general election in Travis County"


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

loader.election_info = %q{<b>Note:</b> Voting centers are in effect for this election.  That means on election day you can vote at <em>any</em> open Travis County polling place, not just your home precinct.

<i>(<a href="http://www.traviscountyclerk.org/eclerk/Content.do?code=E.4" target="_blank">more information ...</a>)</i>}


#####
#
# Hours voting places are open on election day.
#
# Define this as a range:  Time .. Time
#

# Nov 11, 2014 7am-7pm
# *** FIXME *** - need to verify these times are correct
ELECTION_DAY_HOURS = Time.new(2014, 11, 4, 7, 0) .. Time.new(2014, 11, 4, 19, 0)


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

  'R' => [
    # *** FIXME ***
  ],

  'V|Carver Museum' => [
    # *** FIXME ***
  ],

  'V|Del Valle ISD Admin Bldg.' => [
    # *** FIXME ***
  ],

  'V|Highland Mall' => [
    # *** FIXME ***
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
loader.load_evfixed_places("20141104_G14_Webload_FINAL_EVPerm.csv", EARLY_VOTING_FIXED_HOURS)
loader.load_evmobile_places("20141104_G14_Webload_FINAL_Mobile.csv")
loader.load_eday_places("20141104_G14_Webload_FINAL_EDay.csv", ELECTION_DAY_HOURS)
loader.log.info("done")

