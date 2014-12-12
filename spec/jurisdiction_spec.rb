require './spec_helper.rb'

describe VoteATX::Jurisdiction do

  describe "#get" do

    before(:each) do
      @db = open_database(:debug => true)
    end

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
end # describe VoteATX::Jurisdiction

