module VoteATX
  class Message

    module Severity
      ERROR = "error"
      WARNING = "warning"
      INFO = "info"
      def self.valid?(val)
        [ERROR, WARNING, INFO].include?(val)
      end
    end
      
    attr_accessor :severity, :content, :id

    def initialize(severity, content, params = {})
      raise "severity value \"#{severity}\" not valid" unless Severity.valid?(severity)
      @severity = severity
      @content = content
      @id = params.delete(:id)
      raise "unknown initializer parameter(s): #{params.keys.join(', ')}" unless params.empty?
    end

    def to_h
      {
        :severity => @severity,
        :content => @content,
        :id => @id,
      }
    end

  end # class Message
end # module VoteATX

