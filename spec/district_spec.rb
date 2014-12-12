require './spec_helper.rb'

describe VoteATX::District::Precinct do

  before(:each) do
    @db = open_database(:debug => true)
    @j_travis = VoteATX::Jurisdiction.get(@db, "TRAVIS")
    @j_wilco = VoteATX::Jurisdiction.get(@db, "WILLIAMSON")
  end

  describe ".get" do

    it "gets a district for a precinct id" do
      d = VoteATX::District::Precinct.get(@db, @j_travis, "101")
      expect(d).to be_instance_of(VoteATX::District::Precinct)
      expect(d.district_type).to eq(:precinct)
      expect(d.id).to eq("101")
      expect(d.region['type']).to eq("Polygon")
    end

    it "returns nil for unknown precinct id" do
      d = VoteATX::District::Precinct.get(@db, @j_travis, 999)
      expect(d).to be_nil
    end

  end # describe ".get"


  describe ".find" do

    before(:each) do
      @loc_austin_city_hall = FindIt::Location.new(30.264506, -97.848614, :DEG)
      @loc_round_rock = FindIt::Location.new(30.513174, -97.687511, :DEG)
    end

    it "finds a district containing a given location" do
      d = VoteATX::District::Precinct.find(@db, @j_travis, @loc_austin_city_hall)
      expect(d).to be_instance_of(VoteATX::District::Precinct)
      expect(d.district_type).to eq(:precinct)
      expect(d.id).to eq("314")
      expect(d.region['type']).to eq("Polygon")
    end

    it "returns nil for a location outside the area" do
      d = VoteATX::District::Precinct.find(@db, @j_travis, @loc_round_rock)
      expect(d).to be_nil
    end

    it "supports multiple counties" do
      d = VoteATX::District::Precinct.find(@db, @j_wilco, @loc_round_rock)
      expect(d).to be_instance_of(VoteATX::District::Precinct)
      expect(d.district_type).to eq(:precinct)
      expect(d.id).to eq("19")
      expect(d.region['type']).to eq("Polygon")
    end

  end # describe ".find"


end # describe VoteATX::District::Precinct

#describe VoteATX::District::Finder do
#
#  before(:each) do
#    @db = open_database(:debug => true)
#    @juris = VoteATX::Jurisdiction.get(@db, "TRAVIS")
#    @f = VoteATX::District::Finder.new(@db, @juris)
#  end
#
#  describe "new" do
#    it "creates a Finder instance" do
#      expect(@f).to be_instance_of(VoteATX::District::Finder)
#    end
#  end
#
#  describe "#find_precinct" do
#    it "
#
#  describe "#find_city_council"
#
#end # describe VoteATX::District::Finder
