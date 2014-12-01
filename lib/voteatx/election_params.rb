require "date"

module VoteATX
  class ElectionParams

    attr_reader :election_code
    attr_reader :election_description
    attr_reader :election_info
    attr_reader :date_early_voting_begins
    attr_reader :date_early_voting_ends
    attr_reader :date_election_day
    attr_reader :message_after_election

    def getdef(name, options = {})
      is_required = options.has_key?(:required) ? options.delete(:required) : true
      type = options.delete(:type) || :String
      unless options.empty?
        raise "unknown option(s): #{options.keys.join(', ')}"
      end

      rec = @db[:election_defs][:name => name]
      if ! rec
        raise "parameter \"#{name}\" not defined in \"election_defs\" table" if is_required
        return nil
      end

      value = rec[:value]
      case type
      when :Date
        Date.parse(value)
      when :String
        value
      else
        raise "Unknown value type \"#{type}\""
      end
    end

    def initialize(db)
      @db = db
      @election_code = getdef("ELECTION_CODE", :required => false)
      @election_description = getdef("ELECTION_DESCRIPTION", :required => false)
      @election_info = getdef("ELECTION_INFO", :required => false)
      @date_early_voting_begins = getdef("DATE_EARLY_VOTING_BEGINS", :type => :Date)
      @date_early_voting_ends = getdef("DATE_EARLY_VOTING_ENDS", :type => :Date)
      @date_election_day = getdef("DATE_ELECTION_DAY", :type => :Date)
      @message_after_election = getdef("MESSAGE_AFTER_ELECTION", :required => false) \
        || "These results are from the past #{@date_election_day.strftime("%b %-d")} election."
    end

    def to_h
      {
        :election_code => @election_code,
        :election_description => @election_description,
        :election_info => @election_info,
        :date_early_voting_begins => @date_early_voting_begins,
        :date_early_voting_ends => @date_early_voting_ends,
        :date_election_day => @date_election_day,
        :message_after_election => @message_after_election,
      }
    end

  end # class ElectionParams
end # module VoteATX

