require 'findit-support'

module VoteATX
  module District

    class Base
      attr_reader :id, :region

      def initialize(params)
        @id = params.delete(:id) or raise "required attribute \":id\" not specified"
        region = params.delete(:region) or raise "required attribute \":id\" not specified"
        @region = (region.nil? || region.empty?) ? nil : JSON.parse(region)
      end

      def to_h
        {
          :id => @id,
          :region => @region,
        }
      end

    end


    class Precinct < Base

      TABLE = :voting_districts

      def self.find(db, origin)
        geo_column = db.geo_column(TABLE)
        geo_srid = db.geo_srid(TABLE)

        row = db[TABLE] \
          .select{p_vtd.as(:id)} \
          .select_append{AsGeoJSON(ST_Transform(geo_column, SRID_LATLNG)).as(:region)} \
          .filter{ST_Contains(geo_column, ST_Transform(MakePoint(origin.lng, origin.lat, SRID_LATLNG), geo_srid))} \
          .first

        (row.nil? || row.empty?) ? nil : new(row)
      end

      def self.get(db, id)
        geo_column = db.geo_column(TABLE)
        geo_srid = db.geo_srid(TABLE)

        row = db[TABLE] \
          .select{p_vtd.as(:id)} \
          .select_append{AsGeoJSON(ST_Transform(geo_column, SRID_LATLNG)).as(:region)} \
          .filter(:id => id.to_s) \
          .first

        (row.nil? || row.empty?) ? nil : new(row)
      end

    end # Precinct


    class CityCouncil < Base

      TABLE = :council_districts

      def self.find(db, origin)
        geo_column = db.geo_column(TABLE)
        geo_srid = db.geo_srid(TABLE)

        row = db[TABLE] \
          .select{district_1.as(:id)} \
          .select_append{AsGeoJSON(ST_Transform(geo_column, SRID_LATLNG)).as(:region)} \
          .filter{ST_Contains(geo_column, ST_Transform(MakePoint(origin.lng, origin.lat, SRID_LATLNG), geo_srid))} \
          .first

        (row.nil? || row.empty?) ? nil : new(row)
      end

      def self.get(db, id)
        geo_column = db.geo_column(TABLE)
        geo_srid = db.geo_srid(TABLE)

        row = db[TABLE] \
          .select{district_1.as(:id)} \
          .select_append{AsGeoJSON(ST_Transform(geo_column, SRID_LATLNG)).as(:region)} \
          .filter(:id => id.to_s) \
          .first

        (row.nil? || row.empty?) ? nil : new(row)
      end

    end # CityCouncil

  end
end
