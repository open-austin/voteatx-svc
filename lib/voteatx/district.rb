require 'findit-support'

module VoteATX
  module District

    #
    # Base class for districts, such as voting precinct.
    #
    class Base

      attr_reader :id, :region

      def initialize(params)
        id = params.delete(:id) or raise "required attribute \":id\" not specified"
        @id = id.to_s
        r = params.delete(:region) or raise "required attribute \":region\" not specified"
        @region = !r.nil? && !r.empty? && JSON.parse(r)
      end

      def to_h
        {
          :type => district_type,
          :id => @id,
          :region => @region,
        }
      end

      def district_type(*args)
        raise "must override #district_type in derived class"
      end

      def self.get(*args)
        raise "must override .get in derived class"
      end

      def self.find(*args)
        raise "must override .find in derived class"
      end

    end


    class Precinct < Base

      def district_type
        :precinct
      end

      # Get the VoteATX::District::Precinct specified by precinct number.
      def self.get(db, juris, id)
        pct_column = juris.vtd_col_pct
        geo_column = juris.vtd_col_geo
        geo_srid = juris.vtd_srid

        row = db[juris.vtd_table] \
          .select{pct_column.as(:id)} \
          .select_append{AsGeoJSON(ST_Transform(geo_column, SRID_LATLNG)).as(:region)} \
          .where(pct_column => id.to_s) \
          .first

        (row.nil? || row.empty?) ? nil : new(row)
      end


      # Find the VoteATX::District::Precinct that contains a given location.
      def self.find(db, juris, location)
        pct_column = juris.vtd_col_pct
        geo_column = juris.vtd_col_geo
        geo_srid = juris.vtd_srid

        row = db[juris.vtd_table] \
          .select{pct_column.as(:id)} \
          .select_append{AsGeoJSON(ST_Transform(geo_column, SRID_LATLNG)).as(:region)} \
          .filter{ST_Contains(geo_column, ST_Transform(MakePoint(location.lng, location.lat, SRID_LATLNG), geo_srid))} \
          .first

        (row.nil? || row.empty?) ? nil : new(row)
      end

    end # Precinct


    class CityCouncil < Base

      TABLE = :council_districts

      def district_type
        :city_council
      end

      # Get the VoteATX::District::CityCouncil specified by district number.
      def self.get(db, juris, id)
        geo_column = db.geo_column(TABLE)
        geo_srid = db.geo_srid(TABLE)

        row = db[TABLE] \
          .select{district_1.as(:id)} \
          .select_append{AsGeoJSON(ST_Transform(geo_column, SRID_LATLNG)).as(:region)} \
          .filter(:id => id.to_s) \
          .first

        (row.nil? || row.empty?) ? nil : new(row)
      end

      # Find the VoteATX::District::CityCouncil that contains a given location.
      def self.find(db, juris, location)
        geo_column = db.geo_column(TABLE)
        geo_srid = db.geo_srid(TABLE)

        row = db[TABLE] \
          .select{district_1.as(:id)} \
          .select_append{AsGeoJSON(ST_Transform(geo_column, SRID_LATLNG)).as(:region)} \
          .filter{ST_Contains(geo_column, ST_Transform(MakePoint(location.lng, location.lat, SRID_LATLNG), geo_srid))} \
          .first

        (row.nil? || row.empty?) ? nil : new(row)
      end


    end # CityCouncil

  end
end
