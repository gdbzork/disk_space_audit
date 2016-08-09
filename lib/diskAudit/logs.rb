require 'ostruct'

module DiskAudit

  # Basic logging class, used to store logs within the AuditData object so they
  # can be returned to the originator via "Marshal.dump" and "Marshal.load".
  class Logs
    # Constructor
    #
    # @param [String] the tag describing this invocation of bioinfDiskAudit
    def initialize(tag)
      @tag = tag
      @links = []
      @access = []
      @messages = []
      @exception = nil
    end

    # Accessor for the object's ID tag
    attr_reader :tag
    attr_reader :links
    attr_reader :access
    attr_reader :messages
    attr_reader :exception

    def broken_link(path)
      @links << OpenStruct.new(path: path, stamp: Time.now)
    end

    def denied(path)
      @access << OpenStruct.new(path: path, stamp: Time.now)
    end

    def message(msg)
      @messages << OpenStruct.new(msg: msg, stamp: Time.now)
    end

    def exception=(e)
      @exception = e if @exception.nil?
    end

    def exception?
      return @exception != nil
    end
  end
end
