require 'findit-support'

module VoteATX
  class VotingPlace

    # Create a new voting place instance.
    #
    def initialize(place)
      @place = place
    end

    # Generate content for an info window from database record for a voting place.
    def info_content

      info = []
      info << "<b>" + @place[:title].escape_html + "</b>"
      unless $params.election_description.empty?
        info << "<i>" + $params.election_description.escape_html + "</i>"
        info << ""
      end

      a = "#{@place[:name]}, #{@place[:street]}, #{@place[:city]}, #{@place[:state]} #{@place[:zip]}"
      info << "<a href=\"http://maps.google.com/?daddr=#{a.escape_uri}\" target=\"_blank\">#{@place[:name].escape_html}</a>"
      info << @place[:street].escape_html
      info << "#{@place[:city]}, #{@place[:state]} #{@place[:zip]}".escape_html
      info << ""
      info << "Hours of operation:"
      info += @place[:schedule_formatted].escape_html.split("\n").map {|s| "\u2022 " + s}
      unless @place[:notes].empty?
        info << ""
        info << @place[:notes].escape_html
      end
      unless $params.election_info.empty?
        info << ""
        info << $params.election_info
      end
      info.join("\n")
    end

    def to_h
      h = {
        :id => @place[:id],
        :type => @place[:place_type],
        :title => @place[:title],
        :location => {
          :name => @place[:name],
          :address => @place[:street],
          :city => @place[:city],
          :state => @place[:state],
          :zip => @place[:zip],
          :latitude => @place[:latitude],
          :longitude => @place[:longitude],
        },
        :is_open => @place[:is_open],
        :info => info_content,
      }
    end


    class Finder

      attr_accessor :db, :juris, :origin, :now, :max_places, :max_distance

      def initialize(db, juris, options = {})
        @db = db
        @juris = juris
        @origin = options.delete(:origin)
        @now = options.delete(:time) || Time.now
        @max_places = options.delete(:max_places) || VoteATX::MAX_PLACES
        @max_distance = options.delete(:max_distance) || VoteATX::MAX_DISTANCE
        raise "unknown option(s): #{options.keys.join(', ')}" unless options.empty?
      end

      def is_past(schedule_id)
        now = @now
        rs = @db[:voting_schedule_entries] \
          .filter(:schedule_id => schedule_id) \
          .filter{closes > now}
        (rs.count == 0)
      end

      def is_open(schedule_id)
        now = @now
        rs = @db[:voting_schedule_entries] \
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
      def search_query(juris, place_type)
        rs = @db[:voting_places] \
          .select_append(:voting_places__id.as(:place_id)) \
          \
          .join(:voting_locations, :id => :location_id) \
          .select_append(:voting_locations__formatted.as(:location_formatted)) \
          .select_append{ST_X(:voting_locations__geometry).as(:longitude)} \
          .select_append{ST_Y(:voting_locations__geometry).as(:latitude)} \
          \
          .join(:voting_schedules, :id => :voting_places__schedule_id) \
          .select_append(:voting_schedules__formatted.as(:schedule_formatted)) \
          \
          .filter(:voting_places__jurisdiction => juris.key) \
          .filter(:voting_places__place_type => place_type)

        if @origin
          o = @origin
          md = @max_distance
          rs = rs \
            .select_append{ST_Distance(geometry, MakePoint(o.lng, o.lat, SRID_LATLNG)).as(:dist)} \
            .filter{dist <= md} \
            .order(:dist.asc) \
        end

        rs
      end


      def find_election_day_place_by_precinct(precinct)
        rs = search_query(@juris, "ELECTION_DAY") \
          .join(:voting_precincts, :voting_place_id => :voting_places__id)
          .filter(:voting_precincts__precinct => precinct)
        place = rs.first
        return nil unless place

        place[:is_open] = is_open(place[:schedule_id])
        VoteATX::VotingPlace.new(place)
      end


      def search_election_day_places
        places = []
        max_distance = nil

        rs = search_query(@juris, "ELECTION_DAY").limit(max_places)
        rs.each do |place|
          max_distance ||= 1.5 * place[:dist]
          break if place[:dist] > max_distance
          place[:is_open] = is_open(place[:schedule_id])
          places << VoteATX::VotingPlace.new(place)
        end

        places
      end


      def search_early_places
        places = []
        max_distance = nil

        rs = search_query(@juris, "EARLY_FIXED").limit(max_places)
        rs.each do |place|
          max_distance ||= 1.5 * place[:dist]
          break if place[:dist] > max_distance
          place[:is_open] = is_open(place[:schedule_id])
          places << VoteATX::VotingPlace.new(place)
        end

        return [] if places.empty?

        rs = search_query(@juris, "EARLY_MOBILE").limit(max_places)
        rs.each do |place|
          break if place[:dist] > max_distance
          next if is_past(place[:schedule_id])
          place[:is_open] = is_open(place[:schedule_id])
          places << VoteATX::VotingPlace.new(place)
          break if places.length >= @max_places
        end

        places
      end

    end # Finder

  end # VotingPlace
end # VoteATX

