require 'findit-support'

module VoteATX
  class Jurisdiction

    attr_reader :id
    attr_reader :name

    attr_reader :date_early_voting_begins
    attr_reader :date_early_voting_ends
    attr_reader :date_election_day

    attr_reader :have_voting_districts
    attr_reader :vtd_table
    attr_reader :vtd_srid
    attr_reader :vtd_col_geo
    attr_reader :vtd_col_pct

    attr_reader :have_early_voting_places
    attr_reader :have_election_day_voting_places

    attr_reader :sample_ballot_url

    def initialize(vals = {})
      @id = vals[:id].to_sym
      @name = vals[:name]
      @date_early_voting_begins = vals[:date_early_voting_begins]
      @date_early_voting_ends = vals[:date_early_voting_ends]
      @date_election_day = vals[:date_election_day]
      @have_voting_districts = vals[:have_voting_districts]
      @vtd_table = vals[:vtd_table].to_sym
      @vtd_srid = vals[:vtd_srid]
      @vtd_col_geo = vals[:vtd_col_geo].to_sym
      @vtd_col_pct = vals[:vtd_col_pct].to_sym
      @have_early_voting_places = vals[:have_early_voting_places]
      @have_election_day_voting_places = vals[:have_election_day_voting_places]
      @sample_ballot_url = vals[:sample_ballot_url]
    end

    def to_h
      {
        :id => @id,
        :name => @name,
        :date_early_voting_begins => @date_early_voting_begins,
        :date_early_voting_ends => @date_early_voting_ends,
        :date_election_day => @date_election_day,
        :have_voting_districts => @have_voting_districts,
        :vtd_table => @vtd_table,
        :vtd_srid => @vtd_srid,
        :vtd_col_geo => @vtd_col_geo,
        :vtd_col_pct => @vtd_col_pct,
        :have_early_voting_places => @have_early_voting_places,
        :have_election_day_voting_places => @have_election_day_voting_places,
        :sample_ballot_url => @sample_ballot_url,
      }
    end

    def self.get(db, id)
      rec = db[:jurisdictions][:id => id.to_s.upcase]
      rec && new(rec)
    end

  end # class Jurisdiction
end # module VoteATX
