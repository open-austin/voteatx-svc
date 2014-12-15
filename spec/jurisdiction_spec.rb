require './spec_helper.rb'

describe VoteATX::Jurisdiction do

  before(:each) do
    @db = open_database(:debug => true)
  end

  describe "#get" do

    it "retrieves a jurisdiction" do
      juris = VoteATX::Jurisdiction.get(@db, "TRAVIS")
      expect(juris).to be_instance_of(VoteATX::Jurisdiction)
      expect(juris.name).to eq("Travis County")

    end

    it "tag is case insensitive" do
      juris = VoteATX::Jurisdiction.get(@db, "Travis")
      expect(juris).to be_instance_of(VoteATX::Jurisdiction)
      expect(juris.name).to eq("Travis County")
    end

    it "tag can be a symbol" do
      juris = VoteATX::Jurisdiction.get(@db, :TRAVIS)
      expect(juris).to be_instance_of(VoteATX::Jurisdiction)
      expect(juris.name).to eq("Travis County")
    end

    it "returns nil if not found" do
      juris = VoteATX::Jurisdiction.get(@db, "cupcakes")
      expect(juris).to be_nil
    end

  end # describe "#get"

  describe "#to_h" do
    before(:each) do
      @juris = VoteATX::Jurisdiction.get(@db, "TRAVIS")
    end
    it "returns a hash" do
      expect(@juris.to_h).to be_instance_of(Hash)
    end
    it "contains the id as a member" do
      expect(@juris.to_h[:id]).to eq(:TRAVIS)
    end
  end # describe "#to_h"

end # describe VoteATX::Jurisdiction

