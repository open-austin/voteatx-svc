require 'findit-support'

module VoteATX
  module District

    class Base
      attr_reader :id, :region
      def to_h
        {
          :id => @id,
          :region => @region.to_h,
        }
      end
    end


    class VotingPrecinct < Base

      TABLE = :voting_districts

      def initialize(db, origin)

        geo_column = db.geo_column(TABLE)
        geo_srid = db.geo_srid(TABLE)

        row = db[TABLE] \
          .select{p_vtd.as(:id)} \
          .select_append{AsGeoJSON(ST_Transform(geo_column, SRID_LATLNG)).as(:region)} \
          .filter{ST_Contains(geo_column, ST_Transform(MakePoint(origin.lng, origin.lat, SRID_LATLNG), geo_srid))} \
          .first

        return nil unless row

        @id = row[:id]
        @region = FindIt::Asset::MapRegion.from_geojson(row[:region])
      end
    end # VotingPrecinct


    class CityCouncil < Base

      TABLE = :council_districts

      def initialize(db, origin)
        geo_column = db.geo_column(TABLE)
        geo_srid = db.geo_srid(TABLE)

        row = db[TABLE] \
          .select{district_1.as(:id)} \
          .select_append{AsGeoJSON(ST_Transform(geo_column, SRID_LATLNG)).as(:region)} \
          .filter{ST_Contains(geo_column, ST_Transform(MakePoint(origin.lng, origin.lat, SRID_LATLNG), geo_srid))} \
          .first

        return nil unless row

        @id = row[:id]
        @region = FindIt::Asset::MapRegion.from_geojson(row[:region])
      end
    end # CityCouncil

  end
end
