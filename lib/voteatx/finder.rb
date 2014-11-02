require 'findit-support'
require 'cgi' # for escape_html
require_relative './place.rb'
require_relative './district.rb'

class String
  def escape_html
    CGI.escape_html(self)
  end
  def escape_uri
    URI.escape(self)
  end
end

class NilClass
  def empty?
    true
  end
end


module VoteATX

  # Default path to the VoteATX database.
  DATABASE = "db/voteatx.db"

  # Default maxmum distance (miles) of early voting places to consider.
  MAX_DISTANCE = 12

  # Default maximum number of early voting places to display.
  MAX_PLACES = 4

  # When performing a search, if a GeoJSON string for a region polygon
  # exceeds this length then return "true" for the region. The app will
  # need to make a separate request for that region if it wants the polygon.
  MAX_REGION_ON_SEARCH = 8192

  # Implementation of the VoteATX application.
  #
  # Example usage:
  #
  #    require 'voteatx'
  #    finder = VoteATX::Finder.new
  #    voting_places = finder.search(latitude, longitude))
  #
  class Finder

    attr_reader :db

    # Construct a new VoteATX app instance.
    #
    # Options:
    # * :database - Path to the VoteATX database. If not specified, the
    #   value defined by VoteATX::DATABASE is used.
    # * :max_distance - Do not select voting places that are further than
    #   this distance (in miles) from the current location. If not specified,
    #   the value defined by VoteATX::MAX_DISTANCE is used. This value may be
    #   overridden in a #search call.
    # * :max_places - Select at most this number of early voting places. If
    #   not specified, the value defined by VoteATX::MAX_PLACES is used. This
    #   value may be overridden in a #search call.
    #
    def initialize(options = {})
      @search_opts = {}
      @search__opts[:max_places] = options[:max_places] unless options[:max_places].empty?
      @search__opts[:max_distance] = options[:max_distance] unless options[:max_distance].empty?

      database = options[:database] || DATABASE
      raise "database \"#{database}\" not found" unless File.exist?(database)

      @db = Sequel.spatialite(database)
      @db.logger = options[:log] if options.has_key?(:log)
      @db.sql_log_level = :debug

    end


    # Search for features near a given location.
    #
    # Parameters:
    # * lat - the latitude (degrees) of the location, as a Float.
    # * lng - the longitude (degrees) of the location, as a Float.
    #
    # Options:
    # * :max_distance - Override :max_distance specified for constructor.
    # * :max_locations - Override :max_locations specified for constructor.
    # * :time - A date/time string that is parsed and used for the current time.
    #   This is intended for use in testing.
    #
    def search(lat, lng, options = {})
      origin = FindIt::Location.new(lat, lng, :DEG)

      #
      # FIXME - This method has been hacked to return a list of
      # nearby election day voting places. This needs to be fixed
      # to restore early voting place functionality.
      #

      search_options = {}
      options.each do |k, v|
        next if v.nil? || v.empty?
        case k
        when :time
          begin
            search_options[k] = Time.parse(v)
          rescue ArgumentError
            # ignore
          end
        when :max_distance, :max_locations
          search_options[k] = v
        else
          raise "bad option \"#{k}\" specified"
        end
      end

      response = {
        :districts => {},
        :places => [],
#        :message => {
#          :severity => :WARNING,
#          :content => "This app is displaying voting place information for the May 2014 election.  We will update this app once voting place information for the Nov 4, 2014 election is released."
#        }
      }

      precinct = VoteATX::District::Precinct.find(@db, origin)
      if precinct
        response[:districts][:precinct] = precinct.to_h
      else
        response[:message] = {
          :severity => :WARNING,
          :content => "The location you have selected is outside the Travis County voting area.",
        }
      end

      a = VoteATX::District::CityCouncil.find(@db, origin)
      if a
        response[:districts][:city_council] = a.to_h
      end

      response[:districts].keys.each do |district|
        r = response[:districts][district][:region]
        if r.to_s.length > MAX_REGION_ON_SEARCH
          response[:districts][district][:region] = true
        end
      end

      places = VoteATX::Place::ElectionDay.search(@db, origin, search_options)
      response[:places] = places.map {|a| a.to_h}

#      a = if precinct
#        VoteATX::Place::ElectionDay.find_by_precinct(@db, precinct.id, search_options)
#      else
#        VoteATX::Place::ElectionDay.find_by_location(@db, origin, search_options)
#      end
#      if a
#        response[:places] << a.to_h
#      end
#
#      a = VoteATX::Place::Early.search(@db, origin, search_options)
#      if a
#        response[:places] += a.map {|b| b.to_h}
#      end

      return response
    end

  end # module Finder
end # module VoteATX
