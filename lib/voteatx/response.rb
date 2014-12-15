require_relative './message.rb'

module VoteATX

  class Response

    attr_accessor :message
    attr_reader :jurisdiction, :districts, :places

    def initialize(jurisdiction)
      @jurisdiction = jurisdiction
      @districts = {}
      @places = []
      @message = nil
      @additional = {}
    end

    def add_district(district)
      type = district.district_type
      d = district.to_h
      if d[:region].to_s.length > MAX_REGION_ON_SEARCH
        d[:region] = true
      end
      @districts[type] = d
    end

    def add_place(place)
      @places << place.to_h
    end

    def add_additional(key, value)
      @additional[key] = value
    end

    def error(message, params = {})
      @message = VoteATX::Message.new(VoteATX::Message::Severity::ERROR, message, params)
    end

    def warning(message, params = {})
      @message = VoteATX::Message.new(VoteATX::Message::Severity::WARNING, message, params)
    end

    def info(message, params = {})
      @message = VoteATX::Message.new(VoteATX::Message::Severity::INFO, message, params)
    end

    def to_h
      {
        :message => @message && @message.to_h,
        :jurisdiction => @jurisdiction.to_h,
        :districts => @districts,
        :places => @places,
        :additional => @additional,
      }
    end

  end # class Response
end # module VoteATX

