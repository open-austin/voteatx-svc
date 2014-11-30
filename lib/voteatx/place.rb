require 'findit-support'

module VoteATX
  module Place

    # Base class for a voting place.
    #
    # This class should not be accessed directly. Instead, a derived class such
    # as ::ElectionDay or ::Early should be used.
    #
    class Base

      attr_reader :origin, :type, :title, :location, :is_open, :info

      # Create a new voting place instance.
      #
      # Parameters:
      # * :type - one of: :ELECTION_DAY, :EARLY_VOTING_FIXED, :EARLY_VOTING_MOBILE.
      # * :title - description of what kind of voting place this is.
      # * :location - a row from the "voting_locations" table.
      # * :is_open - true if this voting place is open right now, else false.
      # * :info - text may be inserted into an "information window" for this place
      #
      # XXX - Is it possible to generate the :info value in this constructor?
      #
      def initialize(params)
        p = params.dup
        @id = p.delete(:id) or raise "required VoteATX::Place attribute \":id\" not specified"
        @type = p.delete(:type) or raise "required VoteATX::Place attribute \":type\" not specified"
        @title = p.delete(:title) or raise "required VoteATX::Place attribute \":title\" not specified"
        @location = p.delete(:location) or raise "required VoteATX::Place attribute \":location\" not specified"
        @is_open = !! p.delete(:is_open)
        @info = p.delete(:info) or raise "required VoteATX::Place attribute \":info\" not specified"

        raise "unknown initialization parameter(s) specified: #{p.keys.join(', ')}" unless p.empty?

        raise "bad voting place type \"#{@type}\"" unless [:ELECTION_DAY, :EARLY_VOTING_FIXED, :EARLY_VOTING_MOBILE].include?(@type)

      end

      def to_h
        h = {
          :id => @id,
          :type => @type,
          :title => @title,
	  :location => {
	    :name => @location[:name],
	    :address => @location[:street],
	    :city => @location[:city],
	    :state => @location[:state],
	    :zip => @location[:zip],
	    :latitude => @location[:latitude],
	    :longitude => @location[:longitude],
	  },
          :is_open => @is_open,
          :info => @info,
        }
      end

      ELECTION_TYPE_MARKER_SUFFIX = {
	:ELECTION_DAY => "",
	:EARLY_VOTING_FIXED => "_early",
	:EARLY_VOTING_MOBILE => "_mobile",
      }.freeze

      # Generate content for an info window from database record for a voting place.
      def self.format_info(place)
	info = []
	info << "<b>" + place[:title].escape_html + "</b>"
        unless @election_description.empty?
          info << "<i>" + @election_description.escape_html + "</i>"
          info << ""
        end

        a = "#{place[:name]}, #{place[:street]}, #{place[:city]}, #{place[:state]} #{place[:zip]}"
        info << "<a href=\"http://maps.google.com/?daddr=#{a.escape_uri}\" target=\"_blank\">#{place[:name].escape_html}</a>"
        info << place[:street].escape_html
        info << "#{place[:city]}, #{place[:state]} #{place[:zip]}".escape_html
	info << ""
	info << "Hours of operation:"
	info += place[:schedule_formatted].escape_html.split("\n").map {|s| "\u2022 " + s}
	unless place[:notes].empty?
	  info << ""
	  info << place[:notes].escape_html
	end
	unless @election_info.empty?
	  info << ""
	  info << @election_info
	end
	info.join("\n")
      end


      def self.is_past(db, schedule_id, now = Time.now)
        rs = db[:voting_schedule_entries] \
          .filter(:schedule_id => schedule_id) \
          .filter{closes > now}
        (rs.count == 0)
      end

      def self.is_open(db, schedule_id, now = Time.now)
        rs = db[:voting_schedule_entries] \
          .filter(:schedule_id => schedule_id) \
          .filter{opens <= now} \
          .filter{closes > now}
        (rs.count > 0)
      end

      # Convenience function to create a search query for a voting place.
      #
      # This is used in the #search methods to create a Sequel result set
      # for a query against the "voting_places" table.
      #
      def self.search_query(db, *conditions)

	# Grab the election definitions for later use, if we haven't already
	@election_description ||= db[:election_defs][:name => "ELECTION_DESCRIPTION"][:value]
	@election_info ||= db[:election_defs][:name => "ELECTION_INFO"][:value]

	db[:voting_places] \
	  .select_append(:voting_places__id.as(:place_id)) \
	  .select_append(:voting_locations__formatted.as(:location_formatted)) \
	  .select_append(:voting_schedules__formatted.as(:schedule_formatted)) \
          .select_append{ST_X(:voting_locations__geometry).as(:longitude)} \
          .select_append{ST_Y(:voting_locations__geometry).as(:latitude)} \
	  .filter(conditions) \
	  .join(:voting_locations, :id => :location_id) \
	  .join(:voting_schedules, :id => :voting_places__schedule_id)
	  #.join(:voting_schedule_entries, :schedule_id => :id)
      end

      # A derived class must override this method.
      def self.search(db, origin, options = {})
	raise "must override the search method in the derived class"
      end

    end


    # Implementation of a voting place for election day.
    class ElectionDay < Base

      # Return the voting place for the voting district that contains the indicated location.
      def self.find_by_precinct(db, precinct, options = {})

        now = options[:time] || Time.now

	rs = search_query(db, :place_type => "ELECTION_DAY", :precinct => precinct) \
	  .join(:voting_precincts, :voting_place_id => :voting_places__id)
        place = rs.first

        raise "cannot find election day voting place for precinct \"#{precinct}\"" unless place
        raise "cannot find election day voting location for precinct \"#{precinct}\"" unless place[:geometry]

        new(:id => place[:place_id],
          :type => :ELECTION_DAY,
          :title => "Voting place for precinct #{precinct}",
	  :location => place,
          :is_open => is_open(db, place[:schedule_id], now),
          :info => format_info(place))
      end

      def self.search(db, origin, options = {})

        now = options[:time] || Time.now
	max_places = options[:max_places] || VoteATX::MAX_PLACES
	max_distance = options[:max_distance] || VoteATX::MAX_DISTANCE
        ret = []

        places = search_query(db, :place_type => "ELECTION_DAY") \
	  .select_append{ST_Distance(geometry, MakePoint(origin.lng, origin.lat, SRID_LATLNG)).as(:dist)} \
	  .filter{dist <= max_distance} \
	  .order(:dist.asc) \
          .limit(max_places) \
          .all

        places.each do |place|
          params = {
            :id => place[:place_id],
            :type => place[:place_type].to_sym,
            :title => place[:title],
	    :location => place,
            :is_open => is_open(db, place[:schedule_id], now),
	    :info => format_info(place),
          }
          ret << new(params)
        end

        ret
      end


    end # ElectionDay


    # Implementation of an early voting place.
    class Early < Base

      # Return a list of early voting places for this given location.
      #
      # The list will contain the closest fixed early voting place
      # that is closest to this location, plus zero or more selected
      # mobile early voting locations.
      #
      # The selected mobile early voting locations will all be:
      # 1) closer to the specified location than the nearest fixed
      # early voting location, and 2) has not finally closed for
      # this election.
      #
      def self.search(db, origin, options = {})

        now = options[:time] || Time.now
	max_places = options[:max_places] || VoteATX::MAX_PLACES
	max_distance = options[:max_distance] || VoteATX::MAX_DISTANCE

        places = []
        closest_place = nil

	rs = search_query(db, :place_type => "EARLY_FIXED") \
	  .select_append{ST_Distance(geometry, MakePoint(origin.lng, origin.lat, SRID_LATLNG)).as(:dist)} \
	  .filter{dist <= max_distance} \
	  .order(:dist.asc)

        rs.each do |place|

          dist = place[:dist]
          if ! closest_place
            closest_place = place
          else
            break if dist > 1.5 * closest_place[:dist]
          end

          places << new(:id => place[:place_id],
            :type => :EARLY_VOTING_FIXED,
            :title => "Early voting location",
            :location => place,
            :is_open => is_open(db, place[:schedule_id], now),
            :info => format_info(place))
        end

        return [] if places.empty?

	rs = search_query(db, :place_type => "EARLY_MOBILE") \
	  .select_append{ST_Distance(geometry, MakePoint(origin.lng, origin.lat, SRID_LATLNG)).as(:dist)} \
	  .filter{dist <= 1.5 * closest_place[:dist]} \
	  .order(:dist.asc)

        rs.each do |place|
          next if is_past(db, place[:schedule_id], now)
          places << new(:id => place[:place_id],
            :type => :EARLY_VOTING_MOBILE,
            :title => "Mobile early voting location",
            :location => place,
            :is_open => is_open(db, place[:schedule_id], now),
            :info => format_info(place))
          break if places.length >= max_places
        end

        places
      end

    end

  end # Place
end # VoteATX

