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

# Nov 4, 2014, 7am-7pm
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

  # October 20 – October 31: Monday – Saturday 7 am – 7 pm and Sunday Noon - 6 pm
  'R' => [
    Time.new(2014, 10, 20,  7,  0) .. Time.new(2014, 10, 20, 19,  0), # Mo
    Time.new(2014, 10, 21,  7,  0) .. Time.new(2014, 10, 21, 19,  0), # Tu
    Time.new(2014, 10, 22,  7,  0) .. Time.new(2014, 10, 22, 19,  0), # We
    Time.new(2014, 10, 23,  7,  0) .. Time.new(2014, 10, 23, 19,  0), # Th
    Time.new(2014, 10, 24,  7,  0) .. Time.new(2014, 10, 24, 19,  0), # Fr
    Time.new(2014, 10, 25,  7,  0) .. Time.new(2014, 10, 25, 19,  0), # Sa
    Time.new(2014, 10, 26, 12,  0) .. Time.new(2014, 10, 26, 18,  0), # Su (12:00 - 6:00)
    Time.new(2014, 10, 27,  7,  0) .. Time.new(2014, 10, 27, 19,  0), # Mo
    Time.new(2014, 10, 28,  7,  0) .. Time.new(2014, 10, 28, 19,  0), # Tu
    Time.new(2014, 10, 29,  7,  0) .. Time.new(2014, 10, 29, 19,  0), # We
    Time.new(2014, 10, 30,  7,  0) .. Time.new(2014, 10, 30, 19,  0), # Th
    Time.new(2014, 10, 31,  7,  0) .. Time.new(2014, 10, 31, 19,  0), # Fr
  ],

  # Mon.-Thur. 10 am - 5:30 pm, Fri. 10 am - 4:30 pm, Sat. 10 am - 3:30 pm, Sun. Closed
  'V|Carver Museum' => [
    Time.new(2014, 10, 20, 10,  0) .. Time.new(2014, 10, 20, 17, 30), # Mo
    Time.new(2014, 10, 21, 10,  0) .. Time.new(2014, 10, 21, 17, 30), # Tu
    Time.new(2014, 10, 22, 10,  0) .. Time.new(2014, 10, 22, 17, 30), # We
    Time.new(2014, 10, 23, 10,  0) .. Time.new(2014, 10, 23, 17, 30), # Th
    Time.new(2014, 10, 24, 10,  0) .. Time.new(2014, 10, 24, 16, 30), # Fr (10:00 - 4:30)
    Time.new(2014, 10, 25, 10,  0) .. Time.new(2014, 10, 25, 15, 30), # Sa (10:00 - 3:30)
    Time.new(2014, 10, 26,  0,  0) .. Time.new(2014, 10, 26,  0,  0), # Su (closed)
    Time.new(2014, 10, 27, 10,  0) .. Time.new(2014, 10, 27, 17, 30), # Mo
    Time.new(2014, 10, 28, 10,  0) .. Time.new(2014, 10, 28, 17, 30), # Tu
    Time.new(2014, 10, 29, 10,  0) .. Time.new(2014, 10, 29, 17, 30), # We
    Time.new(2014, 10, 30, 10,  0) .. Time.new(2014, 10, 30, 17, 30), # Th
    Time.new(2014, 10, 31, 10,  0) .. Time.new(2014, 10, 31, 16, 30), # Fr (10:00 - 4:30)
  ],

  # October 20 – October 30: Monday – Saturday 7 am – 7 pm and Sunday Noon - 6 pm
  # Friday, Oct. 31st: closed
  #
  'V|Del Valle ISD Administration Building' => [
    Time.new(2014, 10, 20,  7,  0) .. Time.new(2014, 10, 20, 19,  0), # Mo
    Time.new(2014, 10, 21,  7,  0) .. Time.new(2014, 10, 21, 19,  0), # Tu
    Time.new(2014, 10, 22,  7,  0) .. Time.new(2014, 10, 22, 19,  0), # We
    Time.new(2014, 10, 23,  7,  0) .. Time.new(2014, 10, 23, 19,  0), # Th
    Time.new(2014, 10, 24,  7,  0) .. Time.new(2014, 10, 24, 19,  0), # Fr
    Time.new(2014, 10, 25,  7,  0) .. Time.new(2014, 10, 25, 19,  0), # Sa
    Time.new(2014, 10, 26, 12,  0) .. Time.new(2014, 10, 26, 18,  0), # Su (12:00 - 6:00)
    Time.new(2014, 10, 27,  7,  0) .. Time.new(2014, 10, 27, 19,  0), # Mo
    Time.new(2014, 10, 28,  7,  0) .. Time.new(2014, 10, 28, 19,  0), # Tu
    Time.new(2014, 10, 29,  7,  0) .. Time.new(2014, 10, 29, 19,  0), # We
    Time.new(2014, 10, 30,  7,  0) .. Time.new(2014, 10, 30, 19,  0), # Th
    Time.new(2014, 10, 31,  0,  0) .. Time.new(2014, 10, 31,  0,  0), # Fr (closed)
  ],

  # October 20 – October 30: Monday – Saturday 7 am – 7 pm and Sunday Noon – 6 pm
  # October 31: Friday 7 am – 9 pm
  'V|Highland Mall, Suite #1020' => [
    Time.new(2014, 10, 20,  7,  0) .. Time.new(2014, 10, 20, 19,  0), # Mo
    Time.new(2014, 10, 21,  7,  0) .. Time.new(2014, 10, 21, 19,  0), # Tu
    Time.new(2014, 10, 22,  7,  0) .. Time.new(2014, 10, 22, 19,  0), # We
    Time.new(2014, 10, 23,  7,  0) .. Time.new(2014, 10, 23, 19,  0), # Th
    Time.new(2014, 10, 24,  7,  0) .. Time.new(2014, 10, 24, 19,  0), # Fr
    Time.new(2014, 10, 25,  7,  0) .. Time.new(2014, 10, 25, 19,  0), # Sa
    Time.new(2014, 10, 26, 12,  0) .. Time.new(2014, 10, 26, 18,  0), # Su (12:00 - 6:00)
    Time.new(2014, 10, 27,  7,  0) .. Time.new(2014, 10, 27, 19,  0), # Mo
    Time.new(2014, 10, 28,  7,  0) .. Time.new(2014, 10, 28, 19,  0), # Tu
    Time.new(2014, 10, 29,  7,  0) .. Time.new(2014, 10, 29, 19,  0), # We
    Time.new(2014, 10, 30,  7,  0) .. Time.new(2014, 10, 30, 19,  0), # Th
    Time.new(2014, 10, 31,  7,  0) .. Time.new(2014, 10, 31, 21,  0), # Fr (7:00 - 9:00)
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

